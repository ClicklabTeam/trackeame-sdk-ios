//
//  CLBInstallEvent.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBEvent.h"

@interface CLBInstallEvent : CLBEvent

@property (nonatomic, strong, readonly) NSString *referer;

/**
 A new instance of an Install Event.

 @return A new instance of the event
 */
+ (instancetype)installEvent;

/**
 Set the referer of the install event.

 @param referer Referer of the installation
 @return The modified instance of the event
 */
- (CLBInstallEvent *)setReferer:(NSString *)referer;

@end
