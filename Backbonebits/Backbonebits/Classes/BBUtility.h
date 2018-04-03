/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBContants.h"
#import "BBNaviagtionController.h"

typedef enum : NSUInteger {
    BBAssistiveControlTypeImage,
    BBAssistiveControlTypeVideo,
} BBAssistiveControlType;

typedef enum : NSUInteger {
    BBActivityTypeImage,
    BBActivityTypeVideo,
    BBActivityTypeBackbonebits
} BBActivityType;

typedef enum : NSUInteger {
    BBAttachmentTypeUndefined,
    BBAttachmentTypeScreenshot,
    BBAttachmentTypeImage,
    BBAttachmentTypeVideo
} BBAttachmentType;

#define kBBUtility [BBUtility sharedInstance]

typedef void (^BBTappedBlock)(void);
static void (^BBKeyboardWillShowNotificationBlock)(CGSize size);
static void (^BBKeyboardWillHideNotificationBlock)(CGSize size);

typedef void (^BBAlertControllerComplete)(id alertController, NSInteger buttonIndex);
typedef void (^BBConfirmationAlertBlock)(BOOL isPerform);

@class BBAssistiveControl;

@interface BBUtility : NSObject <UIGestureRecognizerDelegate>
{
    BBNaviagtionController *bbNavController;
    BBAssistiveControl *assistiveControl;
}

@property (nonatomic, retain) BBAssistiveControl *assistiveControl;

@property (nonatomic, copy) BBConfirmationAlertBlock confirmationBlock;
@property (nonatomic, copy) BBAlertControllerComplete alertControllerComplete;

@property (nonatomic, assign) BOOL isBBEnableTakeScreenshot;
@property (nonatomic, assign) BOOL isBBEnableTakeVideo;
@property (nonatomic, assign) BOOL isShowReportOption;
@property (nonatomic, assign) UIStatusBarStyle statusBarStyle;
@property (nonatomic, assign) BOOL isStatusBarHidden;

+ (BBUtility *)sharedInstance;

- (void)bbKeyboardWillShowWithCompletion:(void (^)(CGSize size))completion;
- (void)bbKeyboardWillHideWithCompletion:(void (^)(CGSize size))completion;

- (NSUserDefaults *)userDefaults;

- (UIWindow *)getWindowObject;
- (UIViewController *)getVisibleViewControllerFrom:(UIViewController *)viewController;
- (void) pushViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void) popViewControllerAnimated:(BOOL)animation;
- (void) popToRootViewControllerAnimated:(BOOL)animation;

- (BOOL) isVisibleBBNavigationController;

// Default Naviagation Controller.
- (void) shouldRotateOriantation:(BOOL) rotate;
- (UINavigationController *) getBBNavigationController;

- (void)presentViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissViewController:(UIViewController *)viewController animated:(BOOL)animated completion:(void (^)(void))completion;

- (void)presentPopupViewController:(UIViewController *)viewController animated:(BOOL)animated;
- (void)dismissPopupViewController:(UIViewController *)viewController animated:(BOOL)animated;

- (void)addPoweredByViewInView:(UIView *)view;

- (UIButton *)btnBrand;

- (UILabel *)labelWithText:(NSString *)strText;

- (void)addActivityIndicatorInView:(UIView *)view withStyle:(UIActivityIndicatorViewStyle)activityIndicatorStyle;

- (void)removeActivityIndicatorFromView:(UIView *)view;

- (NSDate *)getUTCFormateDate:(NSDate *)localDate;

- (void)convertSecondIntoWDHMS:(NSInteger)totalSeconds WithBlock:(void (^)(NSInteger weeks, NSInteger days, NSInteger hours, NSInteger minutes, NSInteger seconds))completion;

- (CGSize)labelSizeForString:(NSString *)string width:(CGFloat)textWidth font:(UIFont *)font;
- (CGSize)labelSizeForString:(NSString *)string height:(CGFloat)textHeight font:(UIFont *)font;

- (CGSize)labelSizeForAttributedString:(NSMutableAttributedString *)string width:(CGFloat)textWidth;

- (BOOL)isVideoUrl:(NSURL *)url;

#pragma mark - UIColor Utility

- (UIColor *)bb_colorWithHex:(NSUInteger) rgb;
- (UIColor *)bb_colorWithHexString:(NSString *)hexString;
- (CGFloat)bb_colorComponentFrom:(NSString *)string start:(NSUInteger)start length:(NSUInteger) length;

- (UIImage *)imageWithColor:(UIColor *)color size:(CGSize)size;

#pragma mark - Screenshot

- (UIImage *)screenshot;
- (UIImage *)screenshotOfView:(UIView *)view;
- (void)saveImageToDocumentDirectory:(UIImage *)image withName:(NSString *)imageName;
- (UIImage *)imageFromDocumentDirectoryWithName:(NSString *)imageName;

#pragma mark - Random String

- (NSString *)getDefaultUserName;

- (NSString *)randomString;
- (NSString *)getValidStringObject:(id) object;

- (NSString *)getYoutubeVideoIdFromUrlString:(NSString *)strUrl;
- (BOOL)bbValidateEmail:(NSString *)email;
- (NSString *)bbStringByStrippingHTML:(NSString *)string;

#pragma mark - Font Methods

- (UIFont *) systemFontWithSize:(CGFloat)size fixedSize:(BOOL) isYes;
- (UIFont *) boldSystemFontWithSize:(CGFloat)size fixedSize:(BOOL) isYes;

- (UIFont *) systemFontWithSize:(CGFloat) size;
- (UIFont *) boldSystemFontWithSize:(CGFloat) size;

- (CGFloat) sizeForDevice:(CGFloat) size;

#pragma mark - Tapped Block

- (void)bbTapped:(BBTappedBlock)block onView:(UIView *)view;

#pragma mark - Bundle Method

+ (NSBundle*) bundleForResource;

#pragma mark - Image Video Capture

- (void)assistiveControlWithType:(BBAssistiveControlType) type;

- (void)sendConfirmationAlert:(BBAssistiveControlType) type withComplete:(BBConfirmationAlertBlock) complete;
- (void)takeConfirmationAlert:(BBAssistiveControlType) type withComplete:(BBConfirmationAlertBlock) complete;

- (void) setIsBBEnableTakeScreenshot:(BOOL) enableTakeScreenshot;
- (void) setIsBBEnableTakeVideo:(BOOL) enableTakeVideo;
- (BOOL) isBBEnableTakeScreenshot;
- (BOOL) isBBEnableTakeVideo;

- (void) stopActivityWhenAppInBackgroundMode:(BBActivityType) type;

- (void) showAlertController:(NSString *)title message:(NSString *)message actionTitles:(NSArray *) actionTitles completionBlock:(BBAlertControllerComplete) complete;

#pragma mark - NSDateFormatter

- (NSDate *) utcDateFromDate:(NSDate *)date withFormat:(NSString *)format;
- (NSString *) stringFromDate:(NSDate *)date withFormat:(NSString *)format;
- (NSDate *) dateFromString:(NSString *)strDate withFormat:(NSString *)format;

#pragma mark - Get Device UUID

+ (NSString *) deviceUUID;

@end
