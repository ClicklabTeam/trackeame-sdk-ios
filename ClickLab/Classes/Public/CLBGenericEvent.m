//
//  CLBGenericEvent.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBGenericEvent.h"
#import "CLBConstants.h"
#import "CLBUtils.h"
#import "CLBLogUtil.h"

@implementation CLBGenericEvent

+ (instancetype)genericEventWithName:(NSString *)name {
    CLBGenericEvent *event = [CLBGenericEvent new];
    return [event setName:name];
}

+ (instancetype)genericEventWithName:(NSString *)name andParams:(NSDictionary<NSString *,id> *)params {
    CLBGenericEvent *event = [CLBGenericEvent new];
    event.name = name;
    return [event setParams:params];
}

- (CLBEventType)getEventType {
    return CLBEventTypeGeneric;
}

- (CLBGenericEvent *)setName:(NSString *)name {
    if ([CLBUtils isEmptyString:name]) {
        // TODO: raise error ??
        CLBLog(@"Invalid empty name");
        return self;
    }
    _name = name;
    return self;
}

- (CLBGenericEvent *)setParams:(NSDictionary<NSString *,id> *)params {
    _params = params;
    return self;
}

- (NSDictionary<NSString *,id> *)event2JSON {
    NSMutableDictionary<NSString *,id> *json = [NSMutableDictionary dictionaryWithDictionary:[super event2JSON]];
    [json setValue:self.name forKey:kCLBGenericEventCustomTypeKey];
    [json setValue:self.params forKey:kCLBGenericEventExtraParamsKey];
    return json;
}

@end
