//
//  CLBEvent.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBEvent.h"
#import "CLBUtils.h"
#import "CLBConstants.h"

@implementation CLBEvent

- (instancetype)init {
    self = [super init];
    if (self) {
        _postId = [CLBUtils generateUUID];
        _postRetryCount = [NSNumber numberWithInt:0];
        _moment = [NSNumber numberWithLongLong:[[NSDate new] timeIntervalSince1970] * 1000];
    }
    return self;
}

- (CLBEventType)getEventType {
    return CLBEventTypeUndefined;
}

- (NSDictionary<NSString *,id> *)event2JSON {
    NSString *eventType = [CLBEvent nameFromEventType:[self getEventType]];
    
    NSMutableDictionary<NSString *,id> *json = [NSMutableDictionary new];
    [json setValue:eventType forKey:kCLBEventTypeKey];
    [json setValue:self.postId forKey:kCLBEventPostIdKey];
    [json setValue:self.postRetryCount forKey:kCLBEventPostRetryCountKey];
    [json setValue:self.moment forKey:kCLBEventMomentKey];
    return json;
}

+ (NSString *)nameFromEventType:(CLBEventType)eventtype {
    switch (eventtype) {
        case CLBEventTypeGeneric:
            return @"generic";
        case CLBEventTypeOpenApp:
            return @"openapp";
        case CLBEventTypeInstall:
            return @"install";
        case CLBEventTypeConversion:
            return @"conversion";
        case CLBEventTypeUndefined:
        default:
            return @"undefined";
    }
}

@end
