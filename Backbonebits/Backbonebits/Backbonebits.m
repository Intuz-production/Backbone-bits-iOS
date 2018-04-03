//
//  Backbonebits.m
//  Backbonebits
//
//  Created by Backbonebits.
//  Copyright (c) Backbonebits. All rights reserved.
//

/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "Backbonebits.h"
#import "BBContants.h"

//! Project version number for Backbonebits.
FOUNDATION_EXPORT double BackbonebitsVersionNumber;

//! Project version string for Backbonebits.
FOUNDATION_EXPORT const unsigned char BackbonebitsVersionString[];

@interface Backbonebits ()
{
    NSString *_apiKey;
    NSString *_deviceToken;
    
    BOOL _backbonClickable;
    BOOL _enableShakeGesture;
}

@end

@implementation Backbonebits

+ (Backbonebits *)sharedInstance {
    static Backbonebits *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[Backbonebits alloc] init];
    });
    return sharedInstance;
}

- (void)startWithApiKey:(NSString *)apiKey {

    // Set default value for image and video capture.
    kBBUtility.isBBEnableTakeScreenshot = NO;
    kBBUtility.isBBEnableTakeVideo = NO;
    _enableShakeGesture = TRUE;
    
    [self setApiKey:apiKey];
    [self setAppUseCount];
    [self updateDeviceTokenString:@""];
    
    if (![[NSFileManager defaultManager] fileExistsAtPath:BB_ATTACHMENT_FOLDER]) {
        [[NSFileManager defaultManager] createDirectoryAtPath:BB_ATTACHMENT_FOLDER withIntermediateDirectories:YES attributes:nil error:nil];
    }
    
}

- (void)setApiKey:(NSString *)apiKey {
    _apiKey = apiKey;
}

- (NSString *)apiKey {
    return _apiKey;
}

- (BOOL)isApiKeyEntered {
    if(kBBIsSampleApp) {
        return TRUE;
    }
    if(!([self.apiKey length] > 0)) {
        NSLog(@"%@",kBBApiKeyNotEnteredMessage);
        return FALSE;
    }
    return TRUE;
}

- (BOOL)canOpenHelpAndRespond {
    UIViewController *visibleViewController = [kBBUtility getVisibleViewControllerFrom:[kBBUtility getWindowObject].rootViewController];
    if([visibleViewController isKindOfClass:[BBBugReportOptionsView class]] ||
       [visibleViewController isKindOfClass:[BBWatchVideoViewController class]] ||
       [visibleViewController isKindOfClass:[BBReadFAQViewController class]] ||
       [visibleViewController isKindOfClass:[BBHelpScreensViewController class]] ||
       [visibleViewController isKindOfClass:[BBScreenshotEditingViewController class]] ||
       [visibleViewController isKindOfClass:[BBSendReportViewController class]] ||
       [visibleViewController isKindOfClass:[BBPastReportsViewController class]] ||
       [visibleViewController isKindOfClass:[BBRequestDetailViewController class]] ||
       kBBUtility.isBBEnableTakeScreenshot ||
       kBBUtility.isBBEnableTakeVideo) {
        return NO;
    }
    return YES;
}

- (void)setAppUseCount {
    NSUserDefaults *userDefaults = [kBBUtility userDefaults];
    if([userDefaults objectForKey:kBBShowRateAlert] == nil) {
        [userDefaults setBool:YES forKey:kBBShowRateAlert];
    }
    if([userDefaults boolForKey:kBBShowRateAlert]) {
        NSInteger appOpensNo = [userDefaults integerForKey:kBBAppOpenCountKey];
        if(!appOpensNo) {
            [userDefaults setInteger:0 forKey:kBBAppOpenCountKey];
        }
        appOpensNo++;
        [userDefaults setInteger:appOpensNo forKey:kBBAppOpenCountKey];
        [userDefaults synchronize];
    }
    [userDefaults synchronize];
}

#pragma mark - Shake Gesture

- (BOOL)enableShakeGesture {
    return _enableShakeGesture;
}

- (void)setEnableShakeGesture:(BOOL) enable {
    _enableShakeGesture = enable;
}

- (void)openHelpAndRespondOptions {
    if([self canOpenHelpAndRespond]) {
        [BBBugReportOptionsView showBugReportOptionView];
    }
}

-(void)closeBackbonebitsViewController {
    kBBUtility.isBBEnableTakeScreenshot = NO;
    kBBUtility.isBBEnableTakeVideo = NO;
    [[kBBUtility getBBNavigationController] dismissViewControllerAnimated:TRUE completion:nil];
}

#pragma mark - Open Past Reports

- (void)openPastReports:(void(^)(BOOL success))success {
    void(^pushPastRequestScreen)(NSArray *) = ^(NSArray *arrReport) {
        BBPastReportsViewController *viewPastReports = [kBBStoryboard instantiateViewControllerWithIdentifier:@"BBPastReportsViewController"];
        viewPastReports.arrReports = [[NSMutableArray alloc] initWithArray:arrReport];
        [kBBUtility pushViewController:viewPastReports animated:YES];
    };
    
    NSDictionary *dictParameters = @{@"flag":@"list",
                                     @"device_id":[BBUtility deviceUUID]
                                     };
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_GET_RESPOND parameters:dictParameters success:^(id response, NSData *responseData) {
        BOOL isSuccess = NO;
        if ([[response objectForKey:@"data"] isKindOfClass:[NSArray class]]) {
            NSArray * arrReports = [response objectForKey:@"data"];
            if (arrReports.count > 0) {
                isSuccess = YES;
                pushPastRequestScreen(arrReports);
            } else {
                [[BBUtility sharedInstance] showAlertController:@"" message:@"No past request found" actionTitles:@[@"Ok"] completionBlock:nil];
            }
        } else {
            [[BBUtility sharedInstance] showAlertController:@"" message:@"No past request found" actionTitles:@[@"Ok"] completionBlock:nil];
        }
        success(isSuccess);
    } failure:^(NSError *error) {
        [[BBUtility sharedInstance] showAlertController:@"" message:[error localizedDescription] actionTitles:@[@"Ok"] completionBlock:nil];
        success(NO);
    }];
}

- (void)openPastReportWithRequestId:(NSString *) requestId
{
    BBRequestDetailViewController *viewRequestDetail = [[BBRequestDetailViewController alloc] init];
    viewRequestDetail.requestId = requestId;
    [kBBUtility pushViewController:viewRequestDetail animated:YES];
}

#pragma mark - Remote Notification

- (void)registerForRemoteNotification {
    // iOS 10 support
    if (kBB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"10")) {
        [[UNUserNotificationCenter currentNotificationCenter] requestAuthorizationWithOptions:UNAuthorizationOptionBadge | UNAuthorizationOptionSound | UNAuthorizationOptionAlert completionHandler:^(BOOL granted, NSError * _Nullable error) {
            // Add your stuff ..
        }];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else if (kBB_SYSTEM_VERSION_GREATER_THAN_OR_EQUAL_TO(@"8")) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else {
#pragma GCC diagnostic push
#pragma GCC diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication]registerForRemoteNotificationTypes:UIRemoteNotificationTypeAlert | UIRemoteNotificationTypeSound];
#pragma GCC diagnostic pop
    }
}

- (void)updateDeviceTokenString:(NSString *)deviceToken {
    _deviceToken = deviceToken;
    [[kBBUtility userDefaults] setObject:_deviceToken forKey:kBBDeviceTokenKey];
    [[kBBUtility userDefaults] synchronize];
}

- (void)updateDeviceToken:(NSData *)deviceToken {
    NSString *tokenString = [[deviceToken description] stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]];
    tokenString = [tokenString stringByReplacingOccurrencesOfString:@" " withString:@""];
    [self updateDeviceTokenString:tokenString];
}

#pragma mark - Handle Notification

- (BOOL)handleNotification:(NSDictionary *) userInfo andOpenReportDetail:(BOOL) isYes
{
    BOOL isHandled = NO;
    if ([userInfo isKindOfClass:[NSDictionary class]]) {
        if ([userInfo objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey])
        {
            userInfo = [userInfo objectForKey:UIApplicationLaunchOptionsRemoteNotificationKey];
        }
        NSString *infoString = [kBBUtility getValidStringObject:[[userInfo valueForKey:@"aps"] valueForKey:@"data"]];
        NSData * infoData = [infoString dataUsingEncoding:NSUTF8StringEncoding];
        
        NSError * error = nil;
        NSDictionary * data = [NSJSONSerialization JSONObjectWithData:infoData options:NSJSONReadingAllowFragments error:&error];
        if (error==nil) {
            NSString * sdkName = [kBBUtility getValidStringObject:[data valueForKey:@"sdk_name"]];
            if ([[sdkName lowercaseString] isEqualToString:@"Backbonebits"])
            {
                isHandled = YES;
                if (isYes) {
                    
                    // Set Notification Count.
                    //NSInteger unreadCount = [[data valueForKey:@"unread_count"] integerValue];
                    //[self storeUpdateUnreadCount:unreadCount];
                    
                    NSString * request_id = [kBBUtility getValidStringObject:[[data valueForKey:@"request_id"] description]];
                    [self performSelector:@selector(openPastReportWithRequestId:) withObject:request_id afterDelay:.4];
                }
            }
        }
    }
    return isHandled;
}

#pragma mark - Set Logo Clickable

- (void)setBackbonClickable:(BOOL) clickable {
    _backbonClickable = clickable;
}

- (BOOL)backbonebitsClickable {
    return _backbonClickable;
}

#pragma mark - Get Unread Count

- (void)getUnreadPastRequestCount:(void(^)(NSInteger unreadCount, NSError *error))complete {
    NSDictionary * params = @{@"device_id":[BBUtility deviceUUID]};
    [kBBWebClient requestWithURLWithDefaultParameters:BB_URL_GET_REQUEST_COUNT parameters:params success:^(id response, NSData *responseData) {
        NSInteger pastRequestCount = 0;
        if (response) {
            if ([response valueForKey:@"total_unread_count"]) {
                pastRequestCount = [[response valueForKey:@"total_unread_count"] integerValue];
                if (complete) {
                    complete(pastRequestCount, nil);
                }
            }
            else {
                if (complete) {
                    complete(pastRequestCount, nil);
                }
            }
        }
        else {
            if (complete) {
                complete(pastRequestCount, nil);
            }
        }
        [self storeUpdateUnreadCount:pastRequestCount];
    } failure:^(NSError *error) {
        if (complete) {
            complete(0, error);
        }
    }];
}

- (void) storeUpdateUnreadCount:(NSInteger) unreadCount {
    NSUserDefaults *userDefaults = [kBBUtility userDefaults];
    [userDefaults setInteger:unreadCount forKey:kBBPostUnreadCount];
    [userDefaults synchronize];
}

- (NSInteger) getLastUnreadCount {
    NSUserDefaults *userDefaults = [kBBUtility userDefaults];
    if ([userDefaults integerForKey:kBBPostUnreadCount]) {
        return [userDefaults integerForKey:kBBPostUnreadCount];
    }
    return 0;
}

#pragma make - UIApplicationDelegate Handler

- (void)bbApplicationWillResignActive:(UIApplication *)application {
    // bbApplicationWillResignActive
    if (kBBUtility.isBBEnableTakeScreenshot) {
        [kBBUtility stopActivityWhenAppInBackgroundMode:BBActivityTypeImage];
    }
    else if (kBBUtility.isBBEnableTakeVideo) {
        [kBBUtility stopActivityWhenAppInBackgroundMode:BBActivityTypeVideo];
    }
    else {
        [kBBUtility stopActivityWhenAppInBackgroundMode:BBActivityTypeBackbonebits];
    }
}

- (void)bbApplicationDidEnterBackground:(UIApplication *)application {
    // bbApplicationDidEnterBackground
}

- (void)bbApplicationWillEnterForeground:(UIApplication *)application {
    // bbApplicationWillEnterForeground
}

- (void)bbApplicationDidBecomeActive:(UIApplication *)application {
    // bbApplicationDidBecomeActive
}

- (void)bbApplicationWillTerminate:(UIApplication *)application {
    // bbApplicationWillTerminate
}

@end

@interface UIWindow (BBShakeListner)

@end

@implementation UIWindow (BBShakeListner)

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)motionEnded:(UIEventSubtype)motion withEvent:(UIEvent *)event {
    [super motionEnded:motion withEvent:event];
    if (event.type == UIEventTypeMotion &&
        event.subtype == UIEventSubtypeMotionShake &&
        [[Backbonebits sharedInstance] enableShakeGesture])
    {
        [[Backbonebits sharedInstance] openHelpAndRespondOptions];
    }
}

@end
