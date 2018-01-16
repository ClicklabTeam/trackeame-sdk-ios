//
//  CLBEvent.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSInteger, CLBEventType) {
    CLBEventTypeUndefined,
    CLBEventTypeGeneric,
    CLBEventTypeOpenApp,
    CLBEventTypeInstall,
    CLBEventTypeConversion
};

@interface CLBEvent : NSObject

@property (nonatomic, readonly) NSString *postId;
@property (nonatomic, readonly) NSNumber *postRetryCount;
@property (nonatomic, readonly) NSNumber *moment;

- (CLBEventType)getEventType;
- (NSDictionary<NSString *, id> *)event2JSON;
+ (NSString *)nameFromEventType:(CLBEventType)eventtype;

@end
