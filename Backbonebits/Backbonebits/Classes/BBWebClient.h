/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BBContants.h"

#define kBBWebClient [BBWebClient sharedWebClient]

typedef void (^successCallback)(id response, NSData *responseData);
typedef void (^failureCallback)(NSError *error);

@interface BBWebClient : NSObject <NSURLSessionDelegate>

+ (BBWebClient *)sharedWebClient;

- (void)requestWithURL:(NSString *)strUrl parameters:(NSDictionary *)parameters success:(successCallback)success failure:(failureCallback)failure;

- (void)requestWithURLWithDefaultParameters:(NSString *)strUrl parameters:(NSDictionary *)parameters success:(successCallback)success failure:(failureCallback)failure;

- (void)requestWithURLWithDefaultParameters:(NSString *)strUrl parameters:(NSDictionary *)parameters fileUrls:(NSArray *)files success:(successCallback)success failure:(failureCallback)failure;

- (NSURLSessionDownloadTask *)downloadImageWithURL:(NSString *)strUrl success:(successCallback)success failure:(failureCallback)failure;

@end
