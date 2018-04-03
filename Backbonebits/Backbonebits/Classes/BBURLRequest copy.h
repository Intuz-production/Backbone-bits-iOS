

#import <Foundation/Foundation.h>

@interface BBURLRequest : NSObject

+ (NSMutableURLRequest *)requestWithUrl:(NSString *)strUrl parameters:(NSDictionary *)parameters;

+ (NSMutableURLRequest *)multiPartRequestWithUrl:(NSString *)strUrl parameters:(NSDictionary *)parameters files:(NSArray *)files;

@end
