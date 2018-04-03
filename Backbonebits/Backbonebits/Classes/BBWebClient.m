/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBWebClient.h"
#import "BBURLRequest.h"



@implementation BBWebClient

#pragma mark - Shared Object

+ (BBWebClient *)sharedWebClient {
    static BBWebClient *_sharedWebClient = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedWebClient = [[BBWebClient alloc] init];
    });
    return _sharedWebClient;
}

#pragma Get Response From URL

- (void)requestWithURL:(NSString *)strUrl parameters:(NSDictionary *)parameters success:(successCallback)success failure:(failureCallback)failure {
    
    NSMutableURLRequest *urlRequest = [[BBURLRequest serializer] requestWithMethod:@"POST" URLString:strUrl parameters:parameters error:nil];
    [self request:urlRequest success:^(id response, NSData *responseData) {
        if(success) {
            success(response,responseData);
        }
    } failure:^(NSError *error) {
        if(failure) {
            failure(error);
        }
    }];
}

- (void)requestWithURLWithDefaultParameters:(NSString *)strUrl parameters:(NSDictionary *)parameters success:(successCallback)success failure:(failureCallback)failure {
    if(![[Backbonebits sharedInstance] isApiKeyEntered]) {
        if(failure) {
            failure([NSError errorWithDomain:@"Error" code:kBBAPIKeyErrorCode userInfo:@{NSLocalizedDescriptionKey : kBBApiKeyNotEnteredMessage}]);
        }
        return;
    }
    
    NSMutableDictionary *dictParameters = [self addDefaultParametersToDictionary:parameters];
    NSMutableURLRequest * urlRequest = [[BBURLRequest serializer] requestWithMethod:@"POST" URLString:strUrl parameters:dictParameters error:nil];
    [self request:urlRequest success:^(id response, NSData *responseData) {
        if([[response objectForKey:@"status"] isEqualToNumber:[NSNumber numberWithBool:YES]] || [strUrl isEqualToString:BB_URL_GET_STATUS_MENU]) {
            if(success) {
                success(response, responseData);
            }
        }
        else {
            if(failure) {
                if ([response objectForKey:@"msg"]) {
                    failure([NSError errorWithDomain:@"Error" code:kBBDefaulErrorCode userInfo:@{NSLocalizedDescriptionKey :[response objectForKey:@"msg"]}]);
                } else {
                    failure([NSError errorWithDomain:@"Error" code:kBBDefaulErrorCode userInfo:@{NSLocalizedDescriptionKey :@"The network connection was lost."}]);
                }
            }
        }
    } failure:^(NSError *error) {
        if(failure) {
            failure(error);
        }
    }];

}

- (void)requestWithURLWithDefaultParameters:(NSString *)strUrl parameters:(NSDictionary *)parameters fileUrls:(NSArray *)files success:(successCallback)success failure:(failureCallback)failure {
    NSMutableDictionary *dictParameters = [self addDefaultParametersToDictionary:parameters];
    
    NSMutableURLRequest *urlRequest = [[BBURLRequest serializer] multipartFormRequestWithMethod:@"POST" URLString:strUrl parameters:dictParameters constructingBodyWithBlock:^(id<BBMultipartFormData>  _Nonnull formData) {
        [files enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            NSString *name = @"attachments[]";
            NSString *fileName = [obj lastPathComponent];
            NSString *mimeType = BBContentTypeForPathExtension([obj pathExtension]);
            [formData appendPartWithFileURL:obj name:name fileName:fileName mimeType:mimeType error:nil];
        }];
    } error:nil];
    [self request:urlRequest success:^(id response, NSData *responseData) {
        if ([response isKindOfClass:[NSDictionary class]]) {
            if(success) {
                success(response, responseData);
            }
        } else {
            if(failure) {
                failure([NSError errorWithDomain:@"Error" code:kBBDefaulErrorCode userInfo:@{NSLocalizedDescriptionKey :@"Request time out."}]);
            }
        }
    } failure:^(NSError *error) {
        if(failure) {
            failure(error);
        }
    }];
}

#pragma mark - Download Image From URL

- (NSURLSessionDownloadTask *)downloadImageWithURL:(NSString *)strUrl success:(successCallback)success failure:(failureCallback)failure {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    NSURL * url = [NSURL URLWithString:[strUrl stringByAddingPercentEscapesUsingEncoding:NSASCIIStringEncoding]];
    
    NSURLSessionDownloadTask *downloadTask = [defaultSession downloadTaskWithURL:url completionHandler:^(NSURL *location, NSURLResponse *response, NSError *error) {
        if(!error) {
            NSData *data = [NSData dataWithContentsOfURL:location];
            UIImage *downloadedImage = [UIImage imageWithData:data];
            if(success) {
                success(downloadedImage,data);
            }
        }
        else {
            if(failure) {
                failure(error);
            }
        }
    }];
    [downloadTask resume];
    return downloadTask;
}

#pragma mark -

- (NSMutableDictionary *)addDefaultParametersToDictionary:(NSDictionary *)parameters {
    if(!parameters) {
        parameters = [[NSMutableDictionary alloc] init];
    }
    NSDictionary *defaultParameters = @{@"secret_key":[[Backbonebits sharedInstance] apiKey],
                                        @"app_id":kBBBundleIdentifier};
    NSMutableDictionary *dictParameters = [[NSMutableDictionary alloc] init];
    [dictParameters addEntriesFromDictionary:defaultParameters];
    if(parameters) {
        [dictParameters addEntriesFromDictionary:parameters];
    }
    return dictParameters;
}

#pragma mark -

- (void)request:(NSMutableURLRequest *)urlRequest success:(successCallback)success failure:(failureCallback)failure {
    NSURLSessionConfiguration *defaultConfigObject = [NSURLSessionConfiguration defaultSessionConfiguration];
    NSURLSession *defaultSession = [NSURLSession sessionWithConfiguration: defaultConfigObject delegate:self delegateQueue: [NSOperationQueue mainQueue]];
    NSURLSessionDataTask *dataTask = [defaultSession dataTaskWithRequest:urlRequest completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if(!error) {
            NSDictionary *dictResponse = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
            if(success) {
                success(dictResponse,data);
            }
        }
        else {
            if(failure) {
                failure(error);
            }
        }
    }];
    [dataTask resume];
}
@end
