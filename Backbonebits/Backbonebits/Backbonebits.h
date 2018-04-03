//
//  Backbonebits.h
//  Backbonebits
//  Version 1.0
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

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>


@interface Backbonebits : NSObject

/*!
 *  Singleton object for Backbonebits SDK.
 *
 *  @return return Backbonebits object.
 */
+ (Backbonebits *)sharedInstance;

/**
 *  Use this method to get configured API key.
 *
 *  @return API key in string value.
 */
- (NSString *)apiKey;


/**
 *  Use this method for checking is API key is configured or not.
 *
 *  @return return boolen value TRUE or FALSE.
 */
- (BOOL)isApiKeyEntered;

/*!
 *  To configure your app api key with Backbonebits SDK.
 *  Prefered to use this method in
 *  -application:didFinishLaunchingWithOptions:
 *
 *  @param apiKey App API key
 *
 *  @code [[Backbonebits sharedInstance] startWithApiKey:<Your-API-Key>];
 */
- (void)startWithApiKey:(NSString *)apiKey;

/*!
 *  Open help and Respond option list.
 *
 *  @code [[Backbonebits sharedInstance] openHelpAndRespondOptions];
 */
- (void)openHelpAndRespondOptions;

/*!
 *  Close backbonebitsViewController when required.
 *
 *  @code [[Backbonebits sharedInstance] closeBackbonebitsViewController];
 */
-(void)closeBackbonebitsViewController;

/*!
 *  Open all past generated reports from device.
 *
 *  @param success        success block
 *
 *  @code [[Backbonebits sharedInstance] openPastReports:<#^(BOOL success)success#>];
 */
- (void)openPastReports:(void(^)(BOOL success))success;

/*!
 *  Open past generated reports with request id.
 *
 *  @param message_id report request id
 *
 *  @code [[Backbonebits sharedInstance] openPastReportWithRequestId:<#requestId#>];
 */
- (void)openPastReportWithRequestId:(NSString *) message_id;

/*!
 *  To configure Backbonebits SDK with pushnotification.
 *  Prefered to use this method in
 *  -application:didFinishLaunchingWithOptions:
 *
 *  @code [[Backbonebits sharedInstance] registerForRemoteNotification]
 */
- (void)registerForRemoteNotification;

/*!
 *  To send updated device token string of current device to Backbonebits SDK for revceived notification.
 *  Prefered to use this method in
 *  -application:didRegisterForRemoteNotificationsWithDeviceToken:
 *
 *  @param deviceToken device token string
 *
 *  @code [[Backbonebits sharedInstance] updateDeviceTokenString:<#DeviceTokenString#>]
 */
- (void)updateDeviceTokenString:(NSString *)deviceToken;

/*!
 *  To send updated device token data of current device to Backbonebits SDK for revceived notification.
 *  Prefered to use this method in
 *  -application:didRegisterForRemoteNotificationsWithDeviceToken:
 *
 *  @param deviceToken device token data
 *
 *  @code [[Backbonebits sharedInstance] updateDeviceToken:<#DeviceTokenData#>]
 */
- (void)updateDeviceToken:(NSData *)deviceToken;

/*!
 *  Implement this method to handle notification action.
 *
 *  @param userInfo Dictionary data of push notification.
 *  @param isYes Boolean value, pass YES if you want to open report detail thread.
 *
 *  @return Boolen value if handled or not.
 *
 *  @code   // If you handle notification from (application:didReceiveRemoteNotification:) then pass "userInfo" dictionary.
 *   if (launchOptions) {
        if ([[Backbonebits sharedInstance] handleNotification:launchOptions]) {
        // Add Your Code.
        }
    }
 *
 *   // If you handle notification from (application:didFinishLaunchingWithOptions:) then pass "userInfo" dictionary.
 *   if ([[Backbonebits sharedInstance] handleNotification:userInfo]) {
    }
 *   
 *   // If you handle notification from via iOS 10 Methods (userNotificationCenter:didReceiveNotificationResponse:) then pass "userInfo" dictionary.
 *   if ([[Backbonebits sharedInstance] handleNotification:userInfo]) {
    }
 */
- (BOOL)handleNotification:(NSDictionary *) userInfo andOpenReportDetail:(BOOL) isYes;

/**
 *  Use this method for set Backbonebits clickable or not. Default value is TRUE.
 *
 *  @param clickable Pass boolean value TRUE or FALSE.
 */
- (void)setBackbonClickable:(BOOL) clickable;

/**
 *  Use this method to check is Backbonebits clickable.
 *
 *  @return return boolen value TRUE or FALSE.
 */
- (BOOL)backbonebitsClickable;

/**
 *  Use this method to get shake gesture enable and disable status.
 *  Default value is TRUE
 *
 *  @return return boolen value TRUE or FALSE.
 */
- (BOOL)enableShakeGesture;


/**
 *  Use this method to set shake gesture enable and disable.
 *  Default value is TRUE
 *
 *  @param enable pass boolen value TRUE or FALSE.
 */
- (void)setEnableShakeGesture:(BOOL) enable;

/**
 *  User this method to show unread count of Past Request.
 *
 *  @param complete        success block
 *
 *  @code [[Backbonebits sharedInstance] getUnreadPastRequestCount:<#^(NSInteger unreadCount, NSError *error)complete#>]
 */
- (void)getUnreadPastRequestCount:(void(^)(NSInteger unreadCount, NSError *error))complete;


#pragma make - UIApplicationDelegate Handler

/**
 *  Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
 *
 *  @param application <#application description#>
 */
- (void)bbApplicationWillResignActive:(UIApplication *)application;

/**
 *  Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
 *
 *  @param application <#application description#>
 */
- (void)bbApplicationDidEnterBackground:(UIApplication *)application;

/**
 *  Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
 *
 *  @param application <#application description#>
 */
- (void)bbApplicationWillEnterForeground:(UIApplication *)application;

/**
 *  Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
 *
 *  @param application <#application description#>
 */
- (void)bbApplicationDidBecomeActive:(UIApplication *)application;

/**
 *  Called when the application is about to terminate. Save data if appropriate. See also bbApplicationDidEnterBackground:.
 *
 *  @param application <#application description#>
 */
- (void)bbApplicationWillTerminate:(UIApplication *)application;


@end
