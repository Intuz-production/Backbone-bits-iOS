/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBUtility.h"

#define kActivityIndicatorTag 12345678

@implementation BBUtility

@synthesize assistiveControl;

#pragma mark - Shared Instance

+ (BBUtility *)sharedInstance {
    static BBUtility *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BBUtility alloc] init];
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(bbKeyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
        [[NSNotificationCenter defaultCenter] addObserver:sharedInstance selector:@selector(bbKeyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    });
    return sharedInstance;
}

#pragma mark - UIKeyboard Notification

- (void)bbKeyboardWillShowWithCompletion:(void (^)(CGSize size))completion {
    BBKeyboardWillShowNotificationBlock = completion;
}

- (void)bbKeyboardWillShow:(NSNotification *)notification {
    if (BBKeyboardWillShowNotificationBlock) {
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        BBKeyboardWillShowNotificationBlock(keyboardSize);
    }
}

- (void)bbKeyboardWillHideWithCompletion:(void (^)(CGSize size))completion {
    BBKeyboardWillHideNotificationBlock = completion;
}

- (void)bbKeyboardWillHide:(NSNotification *)notification {
    if (BBKeyboardWillHideNotificationBlock) {
        CGSize keyboardSize = [[[notification userInfo] objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
        BBKeyboardWillHideNotificationBlock(keyboardSize);
    }
}

-(void)dealloc {
    [[NSNotificationCenter defaultCenter]removeObserver:self];
}

#pragma mark - USER Defaults

- (NSUserDefaults *)userDefaults {
    static NSUserDefaults *userDefaults = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        userDefaults = [[NSUserDefaults alloc] initWithSuiteName:kBBUserDefaultSuiteName];
    });
    return userDefaults;
}

#pragma mark - UINavigation

- (void) shouldRotateOriantation:(BOOL) rotate {
    [(BBNaviagtionController *)[kBBUtility getBBNavigationController] setIsShouldRotate:rotate];
}

- (BBNaviagtionController *) getBBNavigationController {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        BBBugReportOptionsView *viewBugReportOptions = [kBBStoryboard instantiateViewControllerWithIdentifier:@"BBBugReportOptionsView"];
        bbNavController = [[BBNaviagtionController alloc] initWithRootViewController:viewBugReportOptions];
        [bbNavController setNavigationBarHidden:YES];
    });
    return bbNavController;
}

- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated {
    if ([kBBUtility isVisibleBBNavigationController]) {
        __block BOOL isAvailable = NO;
        [bbNavController.viewControllers enumerateObjectsUsingBlock:^(__kindof UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            if ([obj isKindOfClass:[viewController class]]) {
                isAvailable = YES;
                [bbNavController popToViewController:viewController animated:YES];
                *stop = YES;
            }
        }];
        
        if (!isAvailable) {
            [bbNavController pushViewController:viewController animated:animated];
        }
    } else {
        [[kBBUtility getBBNavigationController] popToRootViewControllerAnimated:NO];
        [[kBBUtility getBBNavigationController] pushViewController:viewController animated:NO];
        [kBBUtility presentViewController:[kBBUtility getBBNavigationController] animated:YES completion:nil];
    }
}

- (void) popViewControllerAnimated:(BOOL)animation {
    [bbNavController popViewControllerAnimated:YES];
}

- (void) popToRootViewControllerAnimated:(BOOL)animation {
    [bbNavController popToRootViewControllerAnimated:YES];
}

- (BOOL) isVisibleBBNavigationController {
    UIViewController *viewController = [self getVisibleViewControllerFrom:[self getWindowObject].rootViewController];
    if ([NSStringFromClass([viewController.navigationController class]) isEqualToString:NSStringFromClass([bbNavController class])])
    {
        return YES;
    }
    return NO;
}

#pragma mark -

- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]]) {
        return [self getVisibleViewControllerFrom:[((UINavigationController *) viewController) visibleViewController]];
    } else if ([viewController isKindOfClass:[UITabBarController class]]) {
        return [self getVisibleViewControllerFrom:[((UITabBarController *) viewController) selectedViewController]];
    } else {
        if (viewController.presentedViewController) {
            return [self getVisibleViewControllerFrom:viewController.presentedViewController];
        } else {
            return viewController;
        }
    }
}

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion{
    UIApplication *application = [UIApplication sharedApplication];
    self.statusBarStyle = [application statusBarStyle];
    self.isStatusBarHidden = [application isStatusBarHidden];
    UIViewController *presentFromViewController = [self getVisibleViewControllerFrom:[self getWindowObject].rootViewController];
    [presentFromViewController presentViewController:viewController animated:animated completion:^{
        [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
        [application setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
        if(completion) {
            completion();
        }
    }];
}

- (void)dismissViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion{
    [[UIApplication sharedApplication] setStatusBarHidden:self.isStatusBarHidden withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:YES];
    [viewController dismissViewControllerAnimated:animated completion:^{
        if(completion) {
            completion();
        }
    }];
}


- (void)presentPopupViewController:(UIViewController *)viewController animated:(BOOL)animated {
    UIApplication *application = [UIApplication sharedApplication];
    self.statusBarStyle = [application statusBarStyle];
    self.isStatusBarHidden = [application isStatusBarHidden];
    UIViewController *presentFrom = [self getVisibleViewControllerFrom:[self getWindowObject].rootViewController];
    [[BBPopupViewController sharedInstance:presentFrom] presentPopupViewController:viewController animationType:BBPopupViewAnimationSlideBottomTop backgroundTouch:NO dismissed:nil];
    
    [application setStatusBarHidden:NO withAnimation:UIStatusBarAnimationFade];
    [application setStatusBarStyle:UIStatusBarStyleLightContent animated:YES];
}

- (void)dismissPopupViewController:(UIViewController *)viewController animated:(BOOL)animated {
    [[UIApplication sharedApplication] setStatusBarHidden:self.isStatusBarHidden withAnimation:UIStatusBarAnimationFade];
    [[UIApplication sharedApplication] setStatusBarStyle:self.statusBarStyle animated:YES];
    [[BBPopupViewController sharedInstance:viewController] dismissPopupViewControllerWithanimationType:BBPopupViewAnimationSlideTopBottom];
}

#pragma mark - Activity Indicator View

- (void)addActivityIndicatorInView:(UIView *)view withStyle:(UIActivityIndicatorViewStyle)activityIndicatorStyle{
    [self removeActivityIndicatorFromView:view];
    UIActivityIndicatorView *activity = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:activityIndicatorStyle];
    [activity setTag:kActivityIndicatorTag];
    [activity setCenter:CGPointMake(view.frame.size.width/2, view.frame.size.height/2)];
    [activity startAnimating];
    [view addSubview:activity];
}

- (void)removeActivityIndicatorFromView:(UIView *)view {
    [[view viewWithTag:kActivityIndicatorTag] removeFromSuperview];
}

#pragma mark - Other Methods

- (BOOL)isVideoUrl:(NSURL *)url {
    CFStringRef fileExtension = (__bridge CFStringRef) [url pathExtension];
    CFStringRef fileUTI = UTTypeCreatePreferredIdentifierForTag(kUTTagClassFilenameExtension, fileExtension, NULL);
    return UTTypeConformsTo(fileUTI, kUTTypeMovie);
}

- (CGSize)labelSizeForString:(NSString *)string width:(CGFloat)textWidth font:(UIFont *)font {
    CGSize size = [string boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    return size;
}

- (CGSize)labelSizeForAttributedString:(NSMutableAttributedString *)string width:(CGFloat)textWidth {
    CGSize size = [string boundingRectWithSize:CGSizeMake(textWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil].size;
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    return size;
}

- (CGSize)labelSizeForString:(NSString *)string height:(CGFloat)textHeight font:(UIFont *)font {
    CGSize size = [string boundingRectWithSize:CGSizeMake(CGFLOAT_MAX, textHeight) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName : font} context:nil].size;
    size.width = ceilf(size.width);
    size.height = ceilf(size.height);
    return size;
}

- (NSDate *)getUTCFormateDate:(NSDate *)localDate
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
    NSTimeZone *timeZone = [NSTimeZone timeZoneWithName:@"UTC"];
    [dateFormatter setTimeZone:timeZone];
    [dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
    NSString *dateString = [dateFormatter stringFromDate:localDate];
    NSDate *date = [dateFormatter dateFromString:dateString];
    return date;
}

- (void)convertSecondIntoWDHMS:(NSInteger)totalSeconds WithBlock:(void (^)(NSInteger weeks, NSInteger days, NSInteger hours, NSInteger minutes, NSInteger seconds))completion {
    
    static const NSInteger SECONDS_PER_MINUTE = 60;
    static const NSInteger MINUTES_PER_HOUR = 60;
    static const NSInteger SECONDS_PER_HOUR = 3600;
    static const NSInteger HOURS_PER_DAY = 24;
    static const NSInteger SECONDS_PER_WEEK = 604800;
    static const NSInteger SECONDS_PER_DAY = 86400;
    
    NSInteger wholeSeconds = totalSeconds;
    
    NSInteger aweeks = (wholeSeconds / SECONDS_PER_WEEK);
    NSInteger adays = ((wholeSeconds % SECONDS_PER_WEEK) / SECONDS_PER_DAY);
    NSInteger ahours = (wholeSeconds / SECONDS_PER_HOUR) % HOURS_PER_DAY;
    NSInteger aminutes = (wholeSeconds / SECONDS_PER_MINUTE) % MINUTES_PER_HOUR;
    NSInteger aseconds = wholeSeconds % SECONDS_PER_MINUTE;
    
    if(completion) {
        completion(aweeks,adays,ahours,aminutes,aseconds);
    }
}

- (UIWindow *)getWindowObject {
    NSEnumerator *frontToBackWindows = [[[UIApplication sharedApplication] windows] reverseObjectEnumerator];
    UIWindow *appWindow = nil;
    for (UIWindow *window in frontToBackWindows) {
        if (window.windowLevel == UIWindowLevelNormal) {
            appWindow = window;
            break;
        }
    }
    
    if (appWindow) {
        if (appWindow.rootViewController) {
            return appWindow;
        }
        else {
            return [[[UIApplication sharedApplication] delegate] window];
        }
    }
    return nil;
}

- (void)addPoweredByViewInView:(UIView *)view {
    CGFloat height = kBottomBarHeight;
    UIView *viewPoweredBy = [[UIView alloc] initWithFrame:CGRectMake(0, view.frame.size.height - height, view.frame.size.width, height)];
    [viewPoweredBy setBackgroundColor:[UIColor clearColor]];
    [viewPoweredBy setAutoresizingMask:UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleWidth];
    [view addSubview:viewPoweredBy];
    
    [viewPoweredBy addSubview:({
        UIButton *btnPoweredBy = [UIButton buttonWithType:UIButtonTypeCustom];
        [btnPoweredBy setFrame:CGRectMake(viewPoweredBy.frame.size.width - height, 0, height, height)];
        [btnPoweredBy setBackgroundColor:[UIColor clearColor]];
        [btnPoweredBy setImage:[UIImage imageNamed:@"bb_logo"] forState:UIControlStateNormal];
        [btnPoweredBy setImageEdgeInsets:UIEdgeInsetsMake(3, 3, 3, 3)];
        [btnPoweredBy setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
        [btnPoweredBy addTarget:self action:@selector(btnPoweredByTapped:) forControlEvents:UIControlEventTouchUpInside];
        if (![[Backbonebits sharedInstance] backbonebitsClickable]) {
            [btnPoweredBy setUserInteractionEnabled:NO];
        }
        btnPoweredBy;
    })];
}

- (UIButton *)btnBrand {
    UIButton *btnLogo = [UIButton buttonWithType:UIButtonTypeCustom];
    [btnLogo setFrame:CGRectMake(0, 0, 30, 30)];
    [btnLogo setBackgroundColor:[UIColor clearColor]];
    [btnLogo setImage:[UIImage imageNamed:@"bb_logo"] forState:UIControlStateNormal];
    [btnLogo addTarget:self action:@selector(btnPoweredByTapped:) forControlEvents:UIControlEventTouchUpInside];
    if (![[Backbonebits sharedInstance] backbonebitsClickable]) {
        [btnLogo setUserInteractionEnabled:NO];
    }
    return btnLogo;
}

- (UILabel *)labelWithText:(NSString *)strText {
    UILabel *lblTitle = [[UILabel alloc] init];
    [lblTitle setText:strText];
    [lblTitle setTextAlignment:NSTextAlignmentCenter];
    [lblTitle setTextColor:[UIColor whiteColor]];
    [lblTitle setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleTopMargin];
    return lblTitle;
}

- (void)btnPoweredByTapped:(id)sender {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:kBackbonebitsSDKURL]];
}

#pragma mark - UIColor Utility

- (UIColor *)bb_colorWithHex:(NSUInteger)rgb {
    return [UIColor colorWithRed:(rgb >> 16) / 255.0f green:(0xff & ( rgb >> 8)) / 255.0f blue:(0xff & rgb) / 255.0f alpha:1.0];
}

- (UIColor *)bb_colorWithHexString: (NSString *)hexString {
    NSString *colorString = [[hexString stringByReplacingOccurrencesOfString: @"#" withString: @""] uppercaseString];
    CGFloat alpha, red, blue, green;
    switch ([colorString length])
    {
        case 3: // #RGB
            alpha = 1.0f;
            red   = [self bb_colorComponentFrom: colorString start: 0 length: 1];
            green = [self bb_colorComponentFrom: colorString start: 1 length: 1];
            blue  = [self bb_colorComponentFrom: colorString start: 2 length: 1];
            break;
        case 4: // #ARGB
            alpha = [self bb_colorComponentFrom: colorString start: 0 length: 1];
            red   = [self bb_colorComponentFrom: colorString start: 1 length: 1];
            green = [self bb_colorComponentFrom: colorString start: 2 length: 1];
            blue  = [self bb_colorComponentFrom: colorString start: 3 length: 1];
            break;
        case 6: // #RRGGBB
            alpha = 1.0f;
            red   = [self bb_colorComponentFrom: colorString start: 0 length: 2];
            green = [self bb_colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self bb_colorComponentFrom: colorString start: 4 length: 2];
            break;
        case 8: // #AARRGGBB
            red   = [self bb_colorComponentFrom: colorString start: 0 length: 2];
            green = [self bb_colorComponentFrom: colorString start: 2 length: 2];
            blue  = [self bb_colorComponentFrom: colorString start: 4 length: 2];
            alpha = [self bb_colorComponentFrom: colorString start: 6 length: 2];
            break;
        default:
            return nil;
            //            [NSException raise:@"Invalid color value" format: @"Color value %@ is invalid.  It should be a hex value of the form #RBG, #ARGB, #RRGGBB, or #AARRGGBB", hexString];
            break;
    }
    return [UIColor colorWithRed: red green: green blue: blue alpha: alpha];
}

- (CGFloat)bb_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger)length {
    NSString *substring = [string substringWithRange: NSMakeRange(start, length)];
    NSString *fullHex = length == 2 ? substring : [NSString stringWithFormat: @"%@%@", substring, substring];
    unsigned hexComponent;
    [[NSScanner scannerWithString: fullHex] scanHexInt: &hexComponent];
    return hexComponent / 255.0;
}

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size
{
    UIGraphicsBeginImageContextWithOptions(size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) return nil;
    
    [color set];
    CGContextFillRect(context, CGRectMake(0.f, 0.f, size.width, size.height));
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
}

#pragma mark - Screenshot

- (UIImage *)screenshot {
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)])
        UIGraphicsBeginImageContextWithOptions(window.bounds.size, NO, [UIScreen mainScreen].scale);
    else
        UIGraphicsBeginImageContext(window.bounds.size);
    
    [window.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

- (UIImage *)screenshotOfView:(UIView *)view {
    UIGraphicsBeginImageContextWithOptions(view.frame.size, NO, [UIScreen mainScreen].scale);
    CGContextRef context = UIGraphicsGetCurrentContext();
    if (context == NULL) return nil;
    CGContextTranslateCTM(context, -view.frame.origin.x, -view.frame.origin.y);
    
    [view layoutIfNeeded];
    [view.layer renderInContext:context];
    
    UIImage *screenshotImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenshotImage;
}

- (void)saveImageToDocumentDirectory:(UIImage *)image withName:(NSString *)imageName {
    NSString *filePath = BB_ATTACHMENT_FILE(imageName);
//    [UIImagePNGRepresentation(image) writeToFile:filePath atomically:YES];
    [UIImageJPEGRepresentation(image, 0.5) writeToFile:filePath atomically:YES];
}

- (UIImage *)imageFromDocumentDirectoryWithName:(NSString *)imageName {
    NSString *filePath = BB_ATTACHMENT_FILE(imageName);
    return [UIImage imageWithContentsOfFile:filePath];
}

#pragma mark - Random String

- (NSString *)getDefaultUserName {
    NSString * strUdid = [[UIDevice currentDevice] identifierForVendor].UUIDString;
    NSString *username = @"user";
    if (strUdid.length > 6) {
        username = [username stringByAppendingString:[strUdid substringFromIndex:strUdid.length-6]];
    }
    return username;
}

NSString *letters = @"abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789";
u_int32_t lenth = 10;

- (NSString *)randomString {
    NSMutableString *randomString = [NSMutableString stringWithCapacity:lenth];
    for (int i=0; i<lenth; i++) {
        [randomString appendFormat: @"%C", [letters characterAtIndex: arc4random_uniform(lenth)]];
    }
    return randomString;
}

- (NSString *)getValidStringObject:(id) object
{
    if ([object isEqual:[NSNull null]] ||
        object == nil)
    {
        return @"";
    }
    if ([object isKindOfClass:[NSString class]])
    {
        if ([[object stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]] isEqualToString:@""] ||
            [object isEqualToString:@"(null)"] ||
            [object isEqualToString:@"<null>"] ||
            [object isEqualToString:@"<nil>"])
        {
            return @"";
        }
    }
    return object;
}

- (NSString *)getYoutubeVideoIdFromUrlString:(NSString *)strUrl {
    NSString *strYoutubeVideoID = @"";
    
    
    if([strUrl rangeOfString:@"?v="].location != NSNotFound) {
        NSArray *arr = [strUrl componentsSeparatedByString:@"?v="];
        if([arr count] > 1) {
            strYoutubeVideoID = [arr objectAtIndex:1];
        }
    }
    else {
        if([strUrl rangeOfString:@"/"].location != NSNotFound) {
            strYoutubeVideoID = [strUrl lastPathComponent];
        }
    }
    return strYoutubeVideoID;
}

- (BOOL)bbValidateEmail:(NSString *)email
{
    NSString *emailValid = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *emailTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@",emailValid];
    return [emailTest evaluateWithObject:email];
}

- (NSString *)bbStringByStrippingHTML:(NSString *)string {
    if ([string isKindOfClass:[NSString class]]) {
        NSRange r;
        while ((r = [string rangeOfString:@"<[^>]+>" options:NSRegularExpressionSearch]).location != NSNotFound)
            string = [string stringByReplacingCharactersInRange:r withString:@""];
        return string;
    }
    return string;
}

#pragma mark - Font Methods

- (UIFont *) systemFontWithSize:(CGFloat)size fixedSize:(BOOL) isYes {
    return [UIFont systemFontOfSize:(isYes)?size:[self sizeForDevice:size]];
}

- (UIFont *) boldSystemFontWithSize:(CGFloat)size fixedSize:(BOOL) isYes {
    return [UIFont boldSystemFontOfSize:(isYes)?size:[self sizeForDevice:size]];
}


- (UIFont *) systemFontWithSize:(CGFloat)size {
    return [self systemFontWithSize:size fixedSize:NO];
}

- (UIFont *) boldSystemFontWithSize:(CGFloat)size {
    return [self boldSystemFontWithSize:size fixedSize:NO];
}

- (CGFloat) sizeForDevice:(CGFloat) size {
    if (kBB_IS_IPHONE_6) {
        size += 2;
    } else if (kBB_IS_IPHONE_6P) {
        size += 2;
    }
    return size;
}

#pragma mark - Tapped Block

static char kBBTappedBlockKey;

- (void)runBBBlockForKey:(void *)blockKey onView:(UIView *)view {
    BBTappedBlock block = objc_getAssociatedObject(view, blockKey);
    if (block) block();
}

- (void)setBBBlock:(BBTappedBlock)block forKey:(void *)blockKey onView:(UIView *)view {
    view.userInteractionEnabled = YES;
    objc_setAssociatedObject(view, blockKey, block, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (void)bbTapped:(BBTappedBlock)block onView:(UIView *)view {
    view.userInteractionEnabled = YES;
    
    UITapGestureRecognizer* tapGesture;
    tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewWasTapped:)] ;
    tapGesture.delegate = self;
    tapGesture.numberOfTapsRequired = 1;
    
    [view addGestureRecognizer:tapGesture];
    
    [self setBBBlock:block forKey:&kBBTappedBlockKey onView:view];
}

- (void)viewWasTapped:(id)sender {
    [self runBBBlockForKey:&kBBTappedBlockKey onView:[(UIGestureRecognizer *)sender view]];
}

#pragma mark - Bundle Methods.

+ (NSBundle*) bundleForResource {
    return [NSBundle bundleForClass:self];
//    return [NSBundle bundleWithPath:[[NSBundle mainBundle] pathForResource:@"BBResource" ofType:@"bundle"]];
}

#pragma mark - Capture Image & Video Methods

- (void)assistiveControlWithType:(BBAssistiveControlType) type
{
    CGRect frame = CGRectMake([kBBUtility getWindowObject].frame.size.width/2 - 50, [kBBUtility getWindowObject].frame.size.height - 120, 100, 100);
    assistiveControl = [[BBAssistiveControl alloc] initWithFrame:frame];
    assistiveControl.backgroundColor = [UIColor clearColor];
    assistiveControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin;
    
    if (type == BBAssistiveControlTypeImage)
    {
        kBBUtility.isBBEnableTakeScreenshot = YES;
        [assistiveControl addTarget:self action:@selector(assitiveImageCaptureTapped:) forControlEvents:UIControlEventTouchUpInside];
        [assistiveControl setImage:[UIImage imageNamed:@"bb_capture_btn"]];
        [[kBBUtility getWindowObject] addSubview:assistiveControl];
    }
    else
    {
        if ([self isShowVideoAlert]) {
            [self showAlertController:@"" message:@"Maximum 10 sec video allowed for recording!" actionTitles:@[@"Got it"] completionBlock:^(id alertController, NSInteger buttonIndex) {
                
                // Save & Start Video Capture.
                NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
                [prefs setValue:@"NO" forKey:@"isShowVideoAlert"];
                [prefs synchronize];
                [self startScreenRecording];
                
            }];
        } else {
            [self startScreenRecording];
        }
    }
}

- (void)sendConfirmationAlert:(BBAssistiveControlType) type withComplete:(BBConfirmationAlertBlock) complete {
    _confirmationBlock = [complete copy];
    NSString *message;
    if (type == BBAssistiveControlTypeImage) {
        message = @"Are you sure you want to send screenshot?";
    } else {
        message = @"Are you sure you want to send video?";
    }
    
    [self showAlertController:@"" message:message actionTitles:@[@"No", @"Yes"] completionBlock:^(id alertController, NSInteger buttonIndex) {
        
        if (_confirmationBlock) {
            if (buttonIndex == 1) {
                _confirmationBlock(YES);
            } else {
                _confirmationBlock(NO);
            }
        }
    }];
}

- (void)takeConfirmationAlert:(BBAssistiveControlType) type withComplete:(BBConfirmationAlertBlock) complete {
    _confirmationBlock = [complete copy];
    
    NSString *message;
    if (type == BBAssistiveControlTypeImage) {
        message = @"Are you sure you want to take screenshot?";
    } else {
        message = @"Are you sure you want to take video?";
    }
    [self showAlertController:@"" message:message actionTitles:@[@"No", @"Yes"] completionBlock:^(id alertController, NSInteger buttonIndex) {
        
        if (_confirmationBlock) {
            if (buttonIndex == 1) {
                _confirmationBlock(YES);
            } else {
                _confirmationBlock(NO);
            }
        }
    }];
}

- (BOOL) isShowVideoAlert {
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![prefs valueForKey:@"isShowVideoAlert"]) {
        [prefs setValue:@"YES" forKey:@"isShowVideoAlert"];
        [prefs synchronize];
    }
    
    if ([[prefs valueForKey:@"isShowVideoAlert"] isEqualToString:@"YES"]) {
        return YES;
    } else {
        return NO;
    }
}

- (void) assitiveImageCaptureTapped:(id)sender {
    kBBUtility.isBBEnableTakeScreenshot = NO;
    [assistiveControl removeFromSuperview];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBBDefaulAlertWaitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        BBScreenshotEditingViewController *viewScreenshotEditing = [[BBScreenshotEditingViewController alloc] init];
        viewScreenshotEditing.imgScreenshot = [kBBUtility screenshot];
        [kBBUtility pushViewController:viewScreenshotEditing animated:YES];
    });
}

- (void) startScreenRecording {
    
    kBBUtility.isBBEnableTakeVideo = YES;
    // Remove Already Created File.
    NSString *filePath = BB_ATTACHMENT_FILE(kBBVideoFileName);
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath]) {
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
    
    BBWindowRecorder *recorder = [BBWindowRecorder sharedInstance];
    if (!recorder.isRecording) {
        [recorder startRecording];
        
        [assistiveControl addTarget:self action:@selector(assitiveVideoCaptureTapped:) forControlEvents:UIControlEventTouchUpInside];
        [assistiveControl setImage:[UIImage imageNamed:@"bb_stop_btn"]];
        [[kBBUtility getWindowObject] addSubview:assistiveControl];
        
        [assistiveControl startProgressWithSecounds:10 completion:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBBDefaulAlertWaitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self assitiveVideoCaptureTapped:nil];
            });
        }];
    }
}

- (void) assitiveVideoCaptureTapped:(id)sender {
    BOOL forceStop = NO;
    if (sender==nil) {
        forceStop = YES;
    }
    
    kBBUtility.isBBEnableTakeVideo = NO;
    [self stopScreenRecording:YES];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBBDefaulAlertWaitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [assistiveControl removeFromSuperview];
    });
}

- (void)stopScreenRecording:(BOOL) isOpen {
    // Stop Timer.
    if (assistiveControl.isRunningTimer) {
        [assistiveControl stopProgress];
    }
    
    BBWindowRecorder *recorder = [BBWindowRecorder sharedInstance];
    if (recorder.isRecording) {
        [BBLoadingView show];
        [recorder stopRecording:^{
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBBDefaulAlertWaitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [BBLoadingView dismiss];
                if (isOpen) {
                    NSLog(@"Finished recording");
                    NSURL *fileURL = [NSURL fileURLWithPath:BB_ATTACHMENT_FILE(kBBVideoFileName)];
                    [BBSendReportViewController showViewWithFileUrl:fileURL attachmentType:@(BBAttachmentTypeVideo)];
                }
            });
        }];
    }
}

- (void) stopActivityWhenAppInBackgroundMode:(BBActivityType) type {
    if (type == BBActivityTypeImage) {
        kBBUtility.isBBEnableTakeScreenshot = NO;
        [assistiveControl removeFromSuperview];
    }
    else if (type == BBActivityTypeVideo) {
        kBBUtility.isBBEnableTakeVideo = NO;
        [self stopScreenRecording:NO];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(kBBDefaulAlertWaitTime * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [assistiveControl removeFromSuperview];
        });
    }
}

#pragma mark - Alert View Methods

- (void) showAlertController:(NSString *)title message:(NSString *)message actionTitles:(NSArray *)actionTitles completionBlock:(BBAlertControllerComplete) complete
{
    _alertControllerComplete = complete;
    
    if (kBB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8.0")) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:title message:message preferredStyle:UIAlertControllerStyleAlert];
        
        if ([actionTitles isKindOfClass:[NSArray class]]) {
            for (int i=0; i<actionTitles.count; i++) {
                NSString *actionTitle = [actionTitles objectAtIndex:i];
                UIAlertAction* action = [UIAlertAction
                                         actionWithTitle:actionTitle
                                         style:UIAlertActionStyleDefault
                                         handler:^(UIAlertAction * action)
                                         {
                                             if (_alertControllerComplete) {
                                                 NSNumber *index = objc_getAssociatedObject(action, @"actionTag");
                                                 _alertControllerComplete(alertController, index.integerValue);
                                             }
                                         }];
                objc_setAssociatedObject(action, @"actionTag", @(i), OBJC_ASSOCIATION_RETAIN);
                [alertController addAction:action];
            }
        }
        
        dispatch_async(dispatch_get_main_queue(), ^{
            UIViewController *visibleViewContr = [kBBUtility getVisibleViewControllerFrom:[kBBUtility getWindowObject].rootViewController];
            [visibleViewContr presentViewController:alertController animated:YES completion:nil];
        });
    }
    else {
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:title message:message delegate:self cancelButtonTitle:nil otherButtonTitles:nil];
        if ([actionTitles isKindOfClass:[NSArray class]]) {
            for (int i=0; i<actionTitles.count; i++) {
                [alertView addButtonWithTitle:[actionTitles objectAtIndex:i]];
            }
        }
        [alertView setTag:18262];
        [alertView show];
    }
}

#pragma mark - Alert View Delegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if ([alertView tag] == 18262) {
        if (_alertControllerComplete) {
            _alertControllerComplete(alertView, buttonIndex);
        }
    }
}

#pragma mark - NSDateFormatter

- (NSDate *) utcDateFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *strDate = [dateFormatter stringFromDate:date];
    NSDate *utcDate = [dateFormatter dateFromString:strDate];
    dateFormatter = nil;
    return utcDate;
}

- (NSString *) stringFromDate:(NSDate *)date withFormat:(NSString *)format {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSString *strDate = [dateFormatter stringFromDate:date];
    dateFormatter = nil;
    return strDate;
}

- (NSDate *) dateFromString:(NSString *)strDate withFormat:(NSString *)format
{
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:format];
    [dateFormatter setTimeZone:[NSTimeZone timeZoneForSecondsFromGMT:0]];
    NSDate *date = [dateFormatter dateFromString:strDate];
    dateFormatter = nil;
    return date;
}

#pragma mark - Get Device UUID

+ (NSString *) deviceUUID {
    // Create Keychain Access
    BBKeyChainStore *keychain = [BBKeyChainStore keyChainStoreWithService:kBBUserDefaultSuiteName];
    
    // Get Previous store UUID.
    NSString *deviceUUID = [keychain stringForKey:kBBDeviceUUID];
    if (!deviceUUID) {
        [keychain setString:kBB_UUIDSTRING forKey:kBBDeviceUUID error:nil];
        return kBB_UUIDSTRING;
    }
    return deviceUUID;
}

@end
