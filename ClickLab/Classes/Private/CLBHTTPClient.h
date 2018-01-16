//
//  CLBHTTPClient.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLBHTTPClient : NSObject

+ (instancetype)HTTPClient;
- (NSURLSessionUploadTask *)uploadEvent:(NSDictionary<NSString *,id> *)batch completionHandler:(void (^)(BOOL success, NSDictionary *response, BOOL retry))completionHandler;
- (NSURLSessionUploadTask *)uploadConversion:(NSDictionary<NSString *,id> *)batch completionHandler:(void (^)(BOOL success, NSDictionary *response, BOOL retry))completionHandler;

@end
