
/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <objc/runtime.h>

#import <UserNotifications/UserNotifications.h>
#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <CoreGraphics/CoreGraphics.h>
#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#import "BBPopupViewController.h"
#import "BBYoutubePlayerView.h"
#import "BBMaterialTextfield.h"
#import "BBKeyChainStore.h"

#import "BBWindowRecorder.h"
#import "Backbonebits.h"
#import "BBUtility.h"
#import "BBTopView.h"
#import "BBMessageInputView.h"
#import "BBDrawableView.h"
#import "BBLoadingView.h"
#import "BBAssistiveControl.h"

#import "BBPlaceHolderTextView.h"
#import "BBWebClient.h"
#import "BBPreviewView.h"

#import "BBFAQFilterViewController.h"
#import "BBScreenshotEditingViewController.h"
#import "BBSendReportViewController.h"
#import "BBBugReportOptionsView.h"
#import "BBScreenRecorder.h"
#import "BBPastReportsViewController.h"
#import "BBReadFAQViewController.h"
#import "BBHelpScreensViewController.h"
#import "BBWatchVideoViewController.h"
#import "BBRequestDetailViewController.h"
#import "BBRequestDetailCell.h"
#import "BBAttachmentCell.h"

#define kBBIsSampleApp NO

// Main Menu Options.
#define BB_URL_GET_STATUS_MENU                          @"get-status-menu.php"

// Responder API.
#define BB_URL_SAVE_RESPOND                             @"save-respond.php"
#define BB_URL_GET_RESPOND                              @"get-respond.php"
#define BB_URL_GET_RESPOND_DETAIL                       @"get-respond-detail.php"
#define BB_URL_GET_REQUEST_COUNT                        @"get-message-count.php"

// Get Help API.
#define BB_URL_GET_HELP                                 @"get-help.php"


/**********************************************************************************/

#pragma mark -

#define kBBBundleIdentifier                             [[NSBundle mainBundle] bundleIdentifier]
#define kBBCurrentVersionNumber                         [[[NSBundle mainBundle] infoDictionary] valueForKey:@"CFBundleShortVersionString"]

#define kBB_IS_IPAD (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad)
#define kBB_IS_IPHONE (UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPhone)
#define kBB_IS_RETINA ([[UIScreen mainScreen] scale] >= 2.0)

#define kBB_SCREEN_WIDTH ([[UIScreen mainScreen] bounds].size.width)
#define kBB_SCREEN_HEIGHT ([[UIScreen mainScreen] bounds].size.height)
#define kBB_SCREEN_MAX_LENGTH (MAX(kBB_SCREEN_WIDTH, kBB_SCREEN_HEIGHT))
#define kBB_SCREEN_MIN_LENGTH (MIN(kBB_SCREEN_WIDTH, kBB_SCREEN_HEIGHT))

#define kBB_IS_IPHONE_4_OR_LESS (kBB_IS_IPHONE && kBB_SCREEN_MAX_LENGTH < 568.0)
#define kBB_IS_IPHONE_5 (kBB_IS_IPHONE && kBB_SCREEN_MAX_LENGTH == 568.0)
#define kBB_IS_IPHONE_6 (kBB_IS_IPHONE && kBB_SCREEN_MAX_LENGTH == 667.0)
#define kBB_IS_IPHONE_6P (kBB_IS_IPHONE && kBB_SCREEN_MAX_LENGTH == 736.0)

#define kBB_IS_GRATER_THEN_IPHONE_5 (kBB_IS_IPHONE && kBB_SCREEN_MAX_LENGTH > 568.0)


#define kBB_UUIDSTRING                                  [[[UIDevice currentDevice] identifierForVendor] UUIDString]

#define kBBScreenWidth                                  [UIScreen mainScreen].bounds.size.width
#define kBBScreenHeight                                 [UIScreen mainScreen].bounds.size.height

#define BB_DOCUMENTS_FOLDER                             [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"]
#define BB_ATTACHMENT_FOLDER                            [BB_DOCUMENTS_FOLDER stringByAppendingPathComponent:@"Backbonebits Files"]
#define BB_ATTACHMENT_FILE(filename)                    [BB_ATTACHMENT_FOLDER stringByAppendingPathComponent:filename]

#define BB_TEMP_DIRECOTORY                              NSTemporaryDirectory()
#define BB_TEMP_DIRECOTORY_ATTACHMENTS                  [BB_DOCUMENTS_FOLDER stringByAppendingPathComponent:@"Backbonebits Files"]
#define BB_TEMP_DIRECOTORY_ATTACHMENT_FILE(filename)    [BB_TEMP_DIRECOTORY_ATTACHMENTS stringByAppendingPathComponent:filename]

#define kBB_INTERFACE_ORIENTATION                       [[UIApplication sharedApplication] statusBarOrientation]
#define kBB_DEVICE_ORIENTATION                          [[UIDevice currentDevice] orientation]
#define kBB_DEVICE_MODEL                                [[UIDevice currentDevice] model]
#define kBB_SYSTEM_VERSION                              [[UIDevice currentDevice] systemVersion]
#define kBB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(v)  ([kBB_SYSTEM_VERSION compare:v options:NSNumericSearch] != NSOrderedAscending)

#define kBB_APP_VERSION_NUMBER_STRING                   [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"]
#define KBB_OS_TYPE                                     @"ios"

#define kBackbonebitsSDKURL                             @"http:/www.appscue.com"
#define kBBUserDefaultSuiteName                         @"com.Backbonebits.userdefaults"

#define kBBRGBCOLOR(r,g,b)                              [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:1]
#define kBBRGBACOLOR(r,g,b,a)                           [UIColor colorWithRed:(r)/255.0f green:(g)/255.0f blue:(b)/255.0f alpha:(a)]

#define kBBDefaultAnimationDuration                     0.5
#define kBottomBarHeight                                33

#define kBBDeviceTokenKey                               @"DeviceTokenKey"
#define kBBShowRateAlert                                @"ShowRateAlert"
#define kBBAppOpenCountKey                              @"AppOpenCountKey"
#define kBBAppDownloded                                 @"AppDownloded"
#define kBBAppDownlodedVersion                          @"AppDownlodedVersion"
#define kBBSavedEmail                                   @"SavedEmailValue"
#define kBBPostUnreadCount                              @"BBPostUnreadCount"
#define kBBDeviceUUID                                   @"BBDeviceUUID"
#define kBBActiveUserUpdateDate                         @"BBActiveUserUpdateDate"

#define KBBImageFileName                                @"screenshot.jpg"
#define kBBVideoFileName                                @"screencapture.mp4"

static NSString *const kGetHelp = @"Get Help";
static NSString *const kWatchVideo = @"Watch a Video";
static NSString *const kReadFAQ = @"FAQ";
static NSString *const kViewHelpScreens = @"View Help Screens";
static NSString *const kSendTextRequest = @"Send Request";
static NSString *const kSendScreenshot = @"Send Screenshot";
static NSString *const kSendVideo = @"Send Video";
static NSString *const kPastRequests = @"Past Requests";

#define kBBAPIKeyErrorCode 1232
#define kBBApiKeyNotEnteredMessage @"Please enter Api key..."
#define kBBApiUrlNotEnteredMessage @"Please enter Api url..."
#define kBBDefaulErrorCode 1234

#define kBBDefaulAlertWaitTime .3

#define kBBStoryboardName @"BBUIStoryboard"
#define kBBStoryboard [UIStoryboard storyboardWithName:kBBStoryboardName bundle:nil]

