//
//  BBWindowRecorder.m
//  Backbonebits
//
//  Created by Backbonebits
//

/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBWindowRecorder.h"
#import "BBContants.h"

#ifndef APPSTORE_SAFE
#define APPSTORE_SAFE 1
#endif

#define DEFAULT_FRAME_INTERVAL 2
#define DEFAULT_AUTOSAVE_DURATION 600
#define TIME_SCALE 600

static NSInteger counter;

#if !APPSTORE_SAFE
CGImageRef UICreateCGImageFromIOSurface(CFTypeRef surface);
CVReturn CVPixelBufferCreateWithIOSurface(
                                          CFAllocatorRef allocator,
                                          CFTypeRef surface,
                                          CFDictionaryRef pixelBufferAttributes,
                                          CVPixelBufferRef *pixelBufferOut);
@interface UIWindow (BBWindowRecorder)
+ (CFTypeRef)createScreenIOSurface;
@end

@interface UIScreen (BBWindowRecorder)
- (CGRect)_boundsInPixels;
@end

@implementation UIScreen (BBWindowRecorder)
- (CGRect)_boundsInPixels {
    return self.bounds;
}
@end
#endif

@interface BBWindowRecorder ()

@property (strong, nonatomic) AVAssetWriter *writer;
@property (strong, nonatomic) AVAssetWriterInput *writerInput;
@property (strong, nonatomic) AVAssetWriterInputPixelBufferAdaptor *writerInputPixelBufferAdaptor;
@property (strong, nonatomic) CADisplayLink *displayLink;

@end

@implementation BBWindowRecorder {
	CFAbsoluteTime firstFrameTime;
    CFTimeInterval startTimestamp;
    BOOL shouldRestart;
    
    dispatch_queue_t queue;
    UIBackgroundTaskIdentifier backgroundTask;
    
    CGColorSpaceRef _rgbColorSpace;
    CVPixelBufferPoolRef _outputBufferPool;
    
    CGSize _viewSize;
    CGFloat _scale;
}

+ (BBWindowRecorder *)sharedInstance
{
    static BBWindowRecorder *sharedInstance = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        sharedInstance = [[BBWindowRecorder alloc] init];
    });
    return sharedInstance;
}

- (id)init
{
    self = [super init];
    if (self) {
        _frameInterval = DEFAULT_FRAME_INTERVAL;
        _autosaveDuration = DEFAULT_AUTOSAVE_DURATION;
        
        counter++;
        NSString *label = [NSString stringWithFormat:@"com.kishikawakatsumi.screen_recorder-%ld", (long)counter];
        queue = dispatch_queue_create([label cStringUsingEncoding:NSUTF8StringEncoding], NULL);
        
        [self setupNotifications];
    }
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
    [self stopRecording];
    
    [super dealloc];
}

#pragma mark Setup

- (void)setupAssetWriterWithURL:(NSURL *)outputURL
{
    NSError *error = nil;
    if (self.writer) {
        [self.writer release];
        self.writer = nil;
    }
    
    UIScreen *mainScreen = [UIScreen mainScreen];
#if APPSTORE_SAFE
    CGSize size = mainScreen.bounds.size;
#else
    CGRect boundsInPixels = [mainScreen _boundsInPixels];
    CGSize size = boundsInPixels.size;
#endif

    _viewSize = [UIApplication sharedApplication].delegate.window.bounds.size;
    _scale = [UIScreen mainScreen].scale;
    
    _rgbColorSpace = CGColorSpaceCreateDeviceRGB();
    
    NSDictionary *bufferAttributes = @{(id)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32BGRA),
                                       (id)kCVPixelBufferCGBitmapContextCompatibilityKey : @YES,
                                       (id)kCVPixelBufferWidthKey : @(size.width * _scale),
                                       (id)kCVPixelBufferHeightKey : @(size.height * _scale),
                                       (id)kCVPixelBufferBytesPerRowAlignmentKey : @(size.width * _scale * 4)
                                       };
    _outputBufferPool = NULL;
    CVPixelBufferPoolCreate(NULL, NULL, (__bridge CFDictionaryRef)(bufferAttributes), &_outputBufferPool);
    
    self.writer = [[AVAssetWriter alloc] initWithURL:outputURL fileType:AVFileTypeQuickTimeMovie error:&error];
    NSParameterAssert(self.writer);
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
    }
    
    NSDictionary *outputSettings = @{AVVideoCodecKey : AVVideoCodecH264, AVVideoWidthKey : @(size.width), AVVideoHeightKey : @(size.height)};
    self.writerInput = [AVAssetWriterInput assetWriterInputWithMediaType:AVMediaTypeVideo outputSettings:outputSettings];
	self.writerInput.expectsMediaDataInRealTime = YES;
    
    NSDictionary *sourcePixelBufferAttributes = @{(NSString *)kCVPixelBufferPixelFormatTypeKey : @(kCVPixelFormatType_32ARGB)};
    self.writerInputPixelBufferAdaptor = [AVAssetWriterInputPixelBufferAdaptor assetWriterInputPixelBufferAdaptorWithAssetWriterInput:self.writerInput
                                   sourcePixelBufferAttributes:sourcePixelBufferAttributes];
    NSParameterAssert(self.writerInput);
    NSParameterAssert([self.writer canAddInput:self.writerInput]);
    
    [self.writer addInput:self.writerInput];
    
	firstFrameTime = CFAbsoluteTimeGetCurrent();
    
    [self.writer startWriting];
    [self.writer startSessionAtSourceTime:kCMTimeZero];
}

- (void)setupNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidEnterBackground:) name:UIApplicationDidEnterBackgroundNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationWillEnterForeground:) name:UIApplicationWillEnterForegroundNotification object:nil];
}

- (void)setupTimer
{
    self.displayLink = [CADisplayLink displayLinkWithTarget:self selector:@selector(captureFrame:)];
    self.displayLink.frameInterval = self.frameInterval;
    [self.displayLink addToRunLoop:[NSRunLoop currentRunLoop] forMode:NSRunLoopCommonModes];
}

#pragma mark Recording

- (void)startRecording
{
    if (!_isRecording) {
        NSLog(@"Start Recording");
        _isRecording = YES;
        [self setupAssetWriterWithURL:[self outputFileURL]];
        
        [self setupTimer];
    }
}

- (void) stopRecording {
    [self stopRecording:nil];
}

- (void)stopRecording:(BBWindowRecorderCompletionBlock) complete
{
    if (_isRecording) {
        NSLog(@"Stop Recording");
        
        _isRecording = NO;
        [self.displayLink removeFromRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
        startTimestamp = 0.0;
        
        dispatch_async(dispatch_queue_create(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^ {
                           if (self.writer.status != AVAssetWriterStatusCompleted && self.writer.status != AVAssetWriterStatusUnknown) {
                               [self.writerInput markAsFinished];
                           }
                           if ([self.writer respondsToSelector:@selector(finishWritingWithCompletionHandler:)]) {
                               [self.writer finishWritingWithCompletionHandler:^
                                {
                                    [self finishBackgroundTask:complete];
                                }];
                           } else {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wdeprecated-declarations"
                               if ([self.writer respondsToSelector:@selector(finishWriting)]) {
                                   [self.writer finishWriting];
                                   
                                   [self finishBackgroundTask:complete];
                               }
#pragma clang diagnostic pop
                           }
                       });
    }
}

- (void)restartRecordingIfNeeded
{
    if (shouldRestart) {
        shouldRestart = NO;
        dispatch_async(queue, ^
                       {
                           dispatch_async(dispatch_get_main_queue(), ^
                                          {
                                              [self startRecording];
                                          });
                       });
    }
}

- (void)rotateFile
{
    shouldRestart = YES;
    dispatch_async(queue, ^
                   {
                       [self stopRecording];
                   });
}

- (void)captureFrame:(CADisplayLink *)displayLink
{
    dispatch_async(queue, ^
                   {
                       if (self.writerInput.readyForMoreMediaData && _isRecording) {
                           CVReturn status = kCVReturnSuccess;
                           CVPixelBufferRef buffer = NULL;
                           CFTypeRef backingData;

                           UIImage *screenshot = nil;
                           [self getScreenShot:&screenshot];
                           
                           CGImageRef image = screenshot.CGImage;
                           CGDataProviderRef dataProvider = CGImageGetDataProvider(image);
                           CFDataRef data = CGDataProviderCopyData(dataProvider);
                           backingData = CFDataCreateMutableCopy(kCFAllocatorDefault, CFDataGetLength(data), data);
                           CFRelease(data);
                           
                           const UInt8 *bytePtr = CFDataGetBytePtr(backingData);
                           
                           status = CVPixelBufferCreateWithBytes(kCFAllocatorDefault,
                                                                 CGImageGetWidth(image),
                                                                 CGImageGetHeight(image),
                                                                 kCVPixelFormatType_32BGRA,
                                                                 (void *)bytePtr,
                                                                 CGImageGetBytesPerRow(image),
                                                                 NULL,
                                                                 NULL,
                                                                 NULL,
                                                                 &buffer);
                           NSParameterAssert(status == kCVReturnSuccess && buffer);
                           
                          if (buffer) {
                               CFAbsoluteTime currentTime = CFAbsoluteTimeGetCurrent();
                               CFTimeInterval elapsedTime = currentTime - firstFrameTime;
                               
                               CMTime presentTime =  CMTimeMake(elapsedTime * TIME_SCALE, TIME_SCALE);
                               
                               if(![self.writerInputPixelBufferAdaptor appendPixelBuffer:buffer withPresentationTime:presentTime]) {
                                   [self stopRecording];
                               }
                              
                               CVPixelBufferUnlockBaseAddress(buffer, 0);
                               CVPixelBufferRelease(buffer);
                          } else {
                              CVPixelBufferUnlockBaseAddress(buffer, 0);
                              CVPixelBufferRelease(buffer);
                          }
                           
                           if (screenshot.retainCount > 0) {
                               [screenshot release];
                           }
                           CFRelease(backingData);
                       }
                   });
    
    if (startTimestamp == 0.0) {
        startTimestamp = displayLink.timestamp;
    }
}

- (void) getScreenShot:(UIImage **) screenshot
{
    CVPixelBufferRef pixelBuffer = NULL;
    CVPixelBufferPoolCreatePixelBuffer(NULL, _outputBufferPool, &pixelBuffer);
    CVPixelBufferLockBaseAddress(pixelBuffer, 0);
    
    CGContextRef bitmapContext = NULL;
    bitmapContext = CGBitmapContextCreate(CVPixelBufferGetBaseAddress(pixelBuffer),
                                          CVPixelBufferGetWidth(pixelBuffer),
                                          CVPixelBufferGetHeight(pixelBuffer),
                                          8, CVPixelBufferGetBytesPerRow(pixelBuffer), _rgbColorSpace,
                                          kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst
                                          );
    CGContextScaleCTM(bitmapContext, _scale, _scale);
    CGAffineTransform flipVertical = CGAffineTransformMake(1, 0, 0, -1, 0, _viewSize.height);
    CGContextConcatCTM(bitmapContext, flipVertical);
    
    dispatch_sync(dispatch_get_main_queue(), ^{
        UIGraphicsPushContext(bitmapContext); {
            for (UIWindow *window in [[UIApplication sharedApplication] windows]) {
                [window drawViewHierarchyInRect:CGRectMake(0, 0, _viewSize.width, _viewSize.height) afterScreenUpdates:NO];
            }
        } UIGraphicsPopContext();
    });
    
    CGImageRef imgRef = CGBitmapContextCreateImage(bitmapContext);
    *screenshot = [[UIImage alloc] initWithCGImage:imgRef];
    
    CGImageRelease(imgRef);
    CVPixelBufferRelease(pixelBuffer);
    CGContextRelease(bitmapContext);
}

- (UIImage *)screenshot
{
    UIScreen *mainScreen = [UIScreen mainScreen];
    CGSize imageSize = mainScreen.bounds.size;
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        UIGraphicsBeginImageContextWithOptions(imageSize, NO, [UIScreen mainScreen].scale);
    } else {
        UIGraphicsBeginImageContext(imageSize);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    NSMutableArray *windows = [[NSMutableArray alloc] init];
    // This will allow keyboard capturing
    [windows addObjectsFromArray:[[UIApplication sharedApplication] windows]];
    
    //below code will allow UIAlertview capturing
    if (kBB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8"))
    {
        if ([[[UIApplication sharedApplication].keyWindow description] hasPrefix:@"<_UIAlertControllerShimPresenterWin"])
        {
            [windows addObject:[UIApplication sharedApplication].keyWindow];
        }
    } else {
        if ([[[UIApplication sharedApplication].keyWindow description] hasPrefix:@"<_UIModalItemHostingWin"])
        {
            [windows addObject:[UIApplication sharedApplication].keyWindow];
        }
    }
    
    for (UIWindow *window in windows) {
        if (![window respondsToSelector:@selector(screen)] || window.screen == mainScreen) {
            CGContextSaveGState(context);
            if ([[window description] hasPrefix:@"<_UIModalItemHostingWin"] ||
                [[window description] hasPrefix:@"<_UIAlertControllerShimPresenterWin"]) {
                // Center the context around the window's anchor point
                CGContextTranslateCTM(context, [window center].x, [window center].y);
                // Apply the window's transform about the anchor point
                CGContextConcatCTM(UIGraphicsGetCurrentContext(), [window transform]);
                
                // Y-offset for the status bar (if it's showing)
                NSInteger yOffset = 0;
                if (![UIApplication sharedApplication].statusBarHidden &&
                    !kBB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"7"))
                    yOffset = -20;
                
                // Offset by the portion of the bounds left of and above the anchor point
                CGContextTranslateCTM(context,
                                      -[window bounds].size.width * [[window layer] anchorPoint].x,
                                      -[window bounds].size.height * [[window layer] anchorPoint].y + yOffset);
                
                // Restore the context
                [[window layer] renderInContext:context];
            } else {
                CGContextTranslateCTM(context, window.center.x, window.center.y);
                CGContextConcatCTM(context, [window transform]);
                CGContextTranslateCTM(context,
                                      -window.bounds.size.width * window.layer.anchorPoint.x,
                                      -window.bounds.size.height * window.layer.anchorPoint.y);
                [window.layer.presentationLayer renderInContext:context];
            }
            CGContextRestoreGState(context);
        }
    }
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

#pragma mark Background tasks

- (void)applicationDidEnterBackground:(NSNotification *)notification
{
    UIApplication *application = [UIApplication sharedApplication];
    
    UIDevice *device = [UIDevice currentDevice];
    BOOL backgroundSupported = NO;
    if ([device respondsToSelector:@selector(isMultitaskingSupported)]) {
        backgroundSupported = device.multitaskingSupported;
    }
    
    if (backgroundSupported) {
        backgroundTask = [application beginBackgroundTaskWithExpirationHandler:^{
            [self finishBackgroundTask:nil];
        }];
    }
    
    [self stopRecording];
}

- (void)applicationWillEnterForeground:(NSNotification *)notification
{
    [self finishBackgroundTask:nil];
    [self startRecording];
}

- (void)finishBackgroundTask:(BBWindowRecorderCompletionBlock) completion
{
    if (backgroundTask != UIBackgroundTaskInvalid) {
        [[UIApplication sharedApplication] endBackgroundTask:backgroundTask];
        backgroundTask = UIBackgroundTaskInvalid;
    }
    
    if (self.writer) {
        [self.writer release];
        self.writer = nil;
    }
    
    CGColorSpaceRelease(_rgbColorSpace);
    CVPixelBufferPoolRelease(_outputBufferPool);
    
    if (completion) {
        completion();
    }
}

#pragma mark Utility methods

- (NSString *)documentDirectory
{
	NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
	NSString *documentsDirectory = [paths objectAtIndex:0];
	return [documentsDirectory stringByAppendingPathComponent:@"Backbonebits Files"];
}

- (NSString *)defaultFilename
{
    time_t timer;
    time(&timer);
    return [NSString stringWithFormat:@"%@",kBBVideoFileName];
}

- (BOOL)existsFile:(NSString *)filename
{
    NSString *path = [self.documentDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    BOOL isDirectory;
    return [fileManager fileExistsAtPath:path isDirectory:&isDirectory] && !isDirectory;
}

- (BOOL)removeFile:(NSString *)filename
{
    NSString *path = [self.documentDirectory stringByAppendingPathComponent:filename];
    NSFileManager *fileManager = [NSFileManager defaultManager];
    return [fileManager removeItemAtPath:path error:nil];
}

- (NSString *)nextFilename:(NSString *)filename
{
    static NSInteger fileCounter;
    
    fileCounter++;
    NSString *pathExtension = [filename pathExtension];
    filename = [[[filename stringByDeletingPathExtension] stringByAppendingString:[NSString stringWithFormat:@"-%ld", (long)fileCounter]] stringByAppendingPathExtension:pathExtension];
    
    if ([self existsFile:filename]) {
        return [self nextFilename:filename];
    }
    
    return filename;
}

- (NSURL *)outputFileURL
{    
    if (!self.filenameBlock) {
        __block BBWindowRecorder *wself = self;
        self.filenameBlock = ^(void) {
            return [wself defaultFilename];
        };
    }
    
    NSString *filename = self.filenameBlock();
    if ([self existsFile:filename]) {
        [self removeFile:filename];
    }
    
    NSString *path = [self.documentDirectory stringByAppendingPathComponent:filename];
    NSLog(@"path:%@",path);
    return [NSURL fileURLWithPath:path];
}

@end
