//
//  CLBHTTPClient.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBHTTPClient.h"
#import "CLBConstants.h"
#import "CLBLogUtil.h"

@implementation CLBHTTPClient {
    NSURLSession *_session;
}

+ (instancetype)HTTPClient {
    return [CLBHTTPClient new];
}

- (NSURLSessionUploadTask *)uploadEvent:(NSDictionary<NSString *,id> *)batch completionHandler:(void (^)(BOOL, NSDictionary *, BOOL))completionHandler {
    NSURL *url = [NSURL URLWithString:kCLBAPIServerEvent];
    return [self upload:batch withURL:url completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)uploadConversion:(NSDictionary<NSString *,id> *)batch completionHandler:(void (^)(BOOL, NSDictionary *, BOOL))completionHandler {
    NSURL *url = [NSURL URLWithString:kCLBAPIServerConversion];
    return [self upload:batch withURL:url completionHandler:completionHandler];
}

- (NSURLSessionUploadTask *)upload:(NSDictionary<NSString *,id> *)batch withURL:(NSURL *)url completionHandler:(void (^)(BOOL, NSDictionary *, BOOL))completionHandler {
    NSURLSessionConfiguration *config = [NSURLSessionConfiguration defaultSessionConfiguration];
    config.HTTPAdditionalHeaders = @{@"Accept" : @"application/json", @"Content-Type" : @"application/json"};
    _session = [NSURLSession sessionWithConfiguration:config];
    config = nil;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    
    // This is a workaround for an IOS 8.3 bug that causes Content-Type to be incorrectly set
    [request addValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    [request setHTTPMethod:@"POST"];
    
    NSError *error = nil;
    NSException *exception = nil;
    NSData *event = nil;
    @try {
        event = [NSJSONSerialization dataWithJSONObject:batch options:0 error:&error];
    }
    @catch (NSException *exc) {
        exception = exc;
    }
    if (error || exception) {
        CLBLog(@"Error serializing JSON for batch upload %@", error);
        completionHandler(NO, nil, NO);
        [self cleanupSession];
        return nil;
    }
    
    __weak CLBHTTPClient *weakSelf = self;
    NSURLSessionUploadTask *task = [_session uploadTaskWithRequest:request fromData:event completionHandler:^(NSData *_Nullable data, NSURLResponse *_Nullable response, NSError *_Nullable error) {
        [weakSelf cleanupSession];
        if (error) {
            CLBLog(@"Error uploading request %@.", error);
            completionHandler(NO, nil, YES);
            return;
        }
        
        NSInteger code = ((NSHTTPURLResponse *)response).statusCode;
        if (code < 300) {
            // 2xx response codes.
            NSError *error = nil;
            id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
            if (error != nil) {
                CLBLog(@"Error JSON deserialization of response: %@", error);
                completionHandler(NO, nil, NO);
                return;
            }
            completionHandler(YES, responseJSON, NO);
            return;
        }
        
        // Try to parse the response
        NSError *err = nil;
        id respJSON = [NSJSONSerialization JSONObjectWithData:data options:0 error:&err];
        if (err != nil) {
            CLBLog(@"Error JSON deserialization of response: %@", err);
        }
        
        if (code < 400) {
            // 3xx response codes.
            CLBLog(@"Server responded with unexpected HTTP code %d. Response: %@", code, respJSON);
            completionHandler(NO, nil, NO);
            return;
        }
        if (code < 500) {
            // 4xx response codes.
            CLBLog(@"Server rejected event with HTTP code %d. Response: %@", code, respJSON);
            completionHandler(NO, nil, NO);
            return;
        }
        
        // 5xx response codes.
        CLBLog(@"Server error with HTTP code %d. Response: %@", code, respJSON);
        completionHandler(NO, nil, NO);
    }];
    [task resume];
    return task;
}

- (void)cleanupSession {
    if (_session) {
        [_session finishTasksAndInvalidate];
        _session = nil;
    }
}

@end
