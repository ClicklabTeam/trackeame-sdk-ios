//
//  CLBOpenAppEvent.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBEvent.h"

@interface CLBOpenAppEvent : CLBEvent

@property (nonatomic, strong, readonly) NSString *url;
@property (nonatomic, strong, readonly) NSString *referer;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id> *params;

/**
 A new instance of an Open App Event.

 @return A new instance of the event
 */
+ (instancetype)openAppEvent;

/**
 Set the URL of the open app event

 @param url URL that generated the app opening
 @return The modified instance of the event
 */
- (CLBOpenAppEvent *)setUrl:(NSString *)url;

/**
 Set the referer of the open app event

 @param referer Referer of the opening
 @return The modified instance of the event
 */
- (CLBOpenAppEvent *)setReferer:(NSString *)referer;

/**
 Set the params of the generic event.

 @param params The extra parameters that need to be tracked
 @return The modified instance of the event
 */
- (CLBOpenAppEvent *)setParams:(NSDictionary<NSString *,id> *)params;

@end
