//
//  CLBUtils.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLBUtils : NSObject

+ (NSString *)generateUUID;
+ (id)makeJSONSerializable:(id)obj;
+ (BOOL)isEmptyString:(NSString *)str;
+ (NSString *)platformDataDirectory;
+ (BOOL)isValidCountryCode:(NSString *)countryCode;
+ (NSString *)generateMD5:(NSString *)str;
+ (NSString *)generateSHA1:(NSString *)str;

@end
