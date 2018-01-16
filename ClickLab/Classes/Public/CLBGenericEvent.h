//
//  CLBGenericEvent.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBEvent.h"

@interface CLBGenericEvent : CLBEvent

@property (nonatomic, strong, readonly) NSString *name;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id> *params;

/**
 A new instance of a Generic Event with a custom name.

 @param name Name of the Generic Event
 @return A new instance of the event
 */
+ (instancetype)genericEventWithName:(NSString *)name;

/**
 A new instance of a Generic Event with a custom name and parameters.

 @param name Name of the Generic Event
 @param params The extra parameters that need to be tracked
 @return A new instance of the event
 */
+ (instancetype)genericEventWithName:(NSString *)name andParams:(NSDictionary<NSString *,id> *)params;

/**
 Set the params of the generic event.

 @param params The extra parameters that need to be tracked
 @return The modified instance of the event
 */
- (CLBGenericEvent *)setParams:(NSDictionary<NSString *,id> *)params;

@end
