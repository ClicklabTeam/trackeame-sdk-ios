//
//  CLBDeviceInfo.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLBDeviceInfo : NSObject

@property (readonly) NSString *appVersion;
@property (readonly) NSString *osName;
@property (readonly) NSString *osVersion;
@property (readonly) NSString *osBrand;
@property (readonly) NSString *manufacturer;
@property (readonly) NSString *model;
@property (readonly) NSString *carrier;
@property (readonly) NSString *country;
@property (readonly) NSString *language;
@property (readonly) NSString *timezone;
@property (readonly) NSString *advertiserID;
@property (readonly) NSString *vendorID;
@property (readonly) NSString *screenResolution;

+ (NSString *)generateUUID;
+ (NSString *)getIDFA;
+ (NSString *)getIPAddress;

@end
