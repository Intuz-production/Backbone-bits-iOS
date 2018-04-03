/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBPreviewView.h"


@implementation BBPreviewView

+ (void)showViewWithFileUrl:(NSURL *)fileUrl {
    BBPreviewView *viewPreview = [[BBPreviewView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    viewPreview.fileUrl = fileUrl;
    [viewPreview setData];
    UIWindow *window = [kBBUtility getWindowObject];
    [viewPreview setCenter:window.center];
    [[kBBUtility getVisibleViewControllerFrom:[kBBUtility getWindowObject].rootViewController].view addSubview:viewPreview];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self loadLayout];
    }
    return self;
}

#pragma mark - Other Methods

- (void)loadLayout {
    [self setBackgroundColor:[UIColor blackColor]];
    [self addSubview:({
        btnClose = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnClose setFrame:CGRectMake(kBBScreenWidth - 50, 27 , 30, 30)];
        btnClose.backgroundColor = [UIColor clearColor];
        [btnClose.layer setCornerRadius:15];
        [btnClose.layer setBorderColor:[UIColor whiteColor].CGColor];
        [btnClose.layer setBorderWidth:2];
        [btnClose setTitleColor:[UIColor colorWithRed:0.0 green:204.0/255.0 blue:204.0 alpha:1.0] forState:UIControlStateNormal];
        [btnClose setTitleColor:[UIColor colorWithRed:0.0 green:204.0/255.0 blue:204.0/255.0 alpha:1.0] forState:UIControlStateHighlighted];
        [btnClose setImage:[UIImage imageNamed:@"bb_close_selected_red"] forState:UIControlStateNormal];
        [btnClose addTarget:self action:@selector(btnCloseTapped:) forControlEvents:UIControlEventTouchUpInside];
        btnClose;
    })];
}

- (void)setData {
    BOOL isVideoSelected = [kBBUtility isVideoUrl:_fileUrl];
    if(isVideoSelected) {
        _moviePlayerController = [[MPMoviePlayerController alloc] initWithContentURL:_fileUrl];
        [_moviePlayerController setControlStyle:MPMovieControlStyleFullscreen];
        [_moviePlayerController.view setFrame:self.bounds];
        _moviePlayerController.scalingMode = MPMovieScalingModeAspectFit;
        [self addSubview:_moviePlayerController.view];
        [_moviePlayerController prepareToPlay];
        [_moviePlayerController play];
        
        [self setNotification];
    }
    else {
        [self addSubview:({
            scrollViewImage = [[UIScrollView alloc] initWithFrame:self.bounds];
            [scrollViewImage setDelegate:self];
            [scrollViewImage setClipsToBounds:YES];
            scrollViewImage;
        })];
        
        [scrollViewImage addSubview:({
            imgViewScreenshot = [[UIImageView alloc] initWithFrame:scrollViewImage.bounds];
            imgViewScreenshot;
        })];
        
        [kBBUtility addActivityIndicatorInView:scrollViewImage withStyle:UIActivityIndicatorViewStyleWhite];
        void(^setImageInScrollView)(UIImage *) = ^(UIImage *image) {
            [kBBUtility removeActivityIndicatorFromView:scrollViewImage];
            [imgViewScreenshot setImage:image];
            [imgViewScreenshot setFrame:(CGRect){.origin=CGPointMake(0.0f, 0.0f), .size=image.size}];
            [scrollViewImage setContentSize:image.size];
            
            CGRect scrollViewFrame = scrollViewImage.frame;
            CGFloat scaleWidth = scrollViewFrame.size.width / scrollViewImage.contentSize.width;
            CGFloat scaleHeight = scrollViewFrame.size.height / scrollViewImage.contentSize.height;
            CGFloat minScale = MIN(scaleWidth, scaleHeight);
            
            scrollViewImage.minimumZoomScale = minScale;
            scrollViewImage.maximumZoomScale = 2.0;
            scrollViewImage.zoomScale = minScale;
            [self centeredFrameForScrollView:scrollViewImage andUIView:imgViewScreenshot];
            [self bringSubviewToFront:btnClose];
        };
        
        if([_fileUrl.path isEqualToString:BB_ATTACHMENT_FILE(KBBImageFileName)]) {
            UIImage *image = [UIImage imageWithContentsOfFile:_fileUrl.path];
            setImageInScrollView(image);
            return;
        }
        
        NSString *fileName = [NSString stringWithFormat:@"FULL_%@",[_fileUrl lastPathComponent]];
        NSString *filePath = BB_TEMP_DIRECOTORY_ATTACHMENT_FILE(fileName);
        if ([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
            UIImage *image = [UIImage imageWithContentsOfFile:filePath];
            setImageInScrollView(image);
        }else {
            [kBBWebClient downloadImageWithURL:_fileUrl.absoluteString success:^(id response, NSData *responseData) {
                NSFileManager *fileManager = [NSFileManager defaultManager];
                [fileManager createFileAtPath:filePath contents:responseData attributes:nil];
                UIImage *image = (UIImage *)response;
                setImageInScrollView(image);
            } failure:^(NSError *error) {
                [kBBUtility removeActivityIndicatorFromView:scrollViewImage];
            }];
        }
    }
}

#pragma mark - Notification Handlers

- (void) setNotification {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(videoDidFinishedPlaying:) name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willEnterFullScreen:) name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(willExitFullScreen:) name:MPMoviePlayerWillExitFullscreenNotification object:nil];
}

- (void)videoDidFinishedPlaying:(NSNotification *)notification {
    //NSLog(@"Did Finished Playing");
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerPlaybackDidFinishNotification object:nil];
    
    [self exitFromFullScreenMode];
    [_moviePlayerController stop];
    [_moviePlayerController.view removeFromSuperview];
    _moviePlayerController = nil;
    [self removeFromSuperview];
}

- (void) willEnterFullScreen:(NSNotification *)notification {
    NSLog(@"Will Enter Full Screen");
    [self enterInFullScreenMode];
}

- (void) willExitFullScreen:(NSNotification *)notification {
    NSLog(@"Will Exit Full Screen");
    [self exitFromFullScreenMode];
}

- (void) enterInFullScreenMode
{
    if (!_moviePlayerController.isFullscreen)
    {
        [_moviePlayerController setFullscreen:YES animated:YES];
    }
}

- (void) exitFromFullScreenMode
{
    if (_moviePlayerController.isFullscreen)
    {
        [_moviePlayerController setFullscreen:NO animated:YES];
    }
}

- (void) dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerWillEnterFullscreenNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:MPMoviePlayerWillExitFullscreenNotification object:nil];
}

#pragma mark - Buttons

- (void)btnCloseTapped:(UIButton *)sender {
    [self removeFromSuperview];
}

#pragma mark - ScrollView

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
    return [self getImageViewFromScrollView:scrollView];
}

- (void)scrollViewDidZoom:(UIScrollView *)scrollView {
    UIImageView *imgView = [self getImageViewFromScrollView:scrollView];
    [self centeredFrameForScrollView:scrollView andUIView:imgView];
}

#pragma mark - Image

- (UIImageView *)getImageViewFromScrollView:(UIScrollView *)scrollView {
    __block UIImageView *imgView;
    [scrollView.subviews enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([obj isKindOfClass:[UIImageView class]]) {
            imgView = obj;
            *stop = YES;
        }
    }];
    return imgView;
}

- (void)centeredFrameForScrollView:(UIScrollView *)scrollView andUIView:(UIImageView *)imgView {
    CGSize boundsSize = scrollView.bounds.size;
    CGRect contentsFrame = imgView.frame;
    
    if (contentsFrame.size.width < boundsSize.width) {
        contentsFrame.origin.x = (boundsSize.width - contentsFrame.size.width) / 2.0f;
    } else {
        contentsFrame.origin.x = 0.0f;
    }
    
    if (contentsFrame.size.height < boundsSize.height) {
        contentsFrame.origin.y = (boundsSize.height - contentsFrame.size.height) / 2.0f;
    } else {
        contentsFrame.origin.y = 0.0f;
    }
    [imgView setFrame:contentsFrame];
}

@end
