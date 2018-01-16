//
//  CLBInstallEvent.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBInstallEvent.h"
#import "CLBConstants.h"

@implementation CLBInstallEvent

+ (instancetype)installEvent {
    return [CLBInstallEvent new];
}

- (CLBEventType)getEventType {
    return CLBEventTypeInstall;
}

- (CLBInstallEvent *)setReferer:(NSString *)referer {
    _referer = referer;
    return self;
}

- (NSDictionary<NSString *,id> *)event2JSON {
    NSMutableDictionary<NSString *,id> *json = [NSMutableDictionary dictionaryWithDictionary:[super event2JSON]];
    [json setValue:self.referer forKey:kCLBOpenAppEventRefererKey];
    return json;
}

@end
