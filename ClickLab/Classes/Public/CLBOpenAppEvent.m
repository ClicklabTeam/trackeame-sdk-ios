//
//  CLBOpenAppEvent.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBOpenAppEvent.h"
#import "CLBConstants.h"

@implementation CLBOpenAppEvent

+ (instancetype)openAppEvent {
    return [CLBOpenAppEvent new];
}

- (CLBEventType)getEventType {
    return CLBEventTypeOpenApp;
}

- (CLBOpenAppEvent *)setUrl:(NSString *)url {
    _url = url;
    return self;
}

- (CLBOpenAppEvent *)setReferer:(NSString *)referer {
    _referer = referer;
    return self;
}

- (CLBOpenAppEvent *)setParams:(NSDictionary<NSString *,id> *)params {
    _params = params;
    return self;
}

- (NSDictionary<NSString *,id> *)event2JSON {
    NSMutableDictionary<NSString *,id> *json = [NSMutableDictionary dictionaryWithDictionary:[super event2JSON]];
    [json setValue:self.url forKey:kCLBOpenAppEventURLKey];
    [json setValue:self.referer forKey:kCLBOpenAppEventRefererKey];
    [json setValue:self.params forKey:kCLBGenericEventExtraParamsKey];
    return json;
}

@end
