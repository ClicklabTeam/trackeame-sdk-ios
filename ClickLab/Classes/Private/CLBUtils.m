//
//  CLBUtils.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBUtils.h"
#import "CLBLogUtil.h"
#import <CommonCrypto/CommonDigest.h>

@implementation CLBUtils

+ (id)alloc {
    // Util class cannot be instantiated.
    return nil;
}

+ (NSString *)generateUUID {
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    NSString *UUIDString = (__bridge_transfer NSString *)CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return UUIDString;
}

+ (id)makeJSONSerializable:(id)obj {
    if (obj == nil) {
        return [NSNull null];
    }
    if ([obj isKindOfClass:[NSString class]] ||
        [obj isKindOfClass:[NSNull class]]) {
        return obj;
    }
    if ([obj isKindOfClass:[NSNumber class]]) {
        if (!isfinite([obj floatValue])) {
            return [NSNull null];
        } else {
            return obj;
        }
    }
    if ([obj isKindOfClass:[NSDate class]]) {
        return [obj description];
    }
    if ([obj isKindOfClass:[NSArray class]]) {
        NSMutableArray *arr = [NSMutableArray array];
        id objCopy = [obj copy];
        for (id i in objCopy) {
            [arr addObject:[self makeJSONSerializable:i]];
        }
        return [NSArray arrayWithArray:arr];
    }
    if ([obj isKindOfClass:[NSDictionary class]]) {
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        id objCopy = [obj copy];
        for (id key in objCopy) {
            NSString *coercedKey = [self coerceToString:key withName:@"property key"];
            dict[coercedKey] = [self makeJSONSerializable:objCopy[key]];
        }
        return [NSDictionary dictionaryWithDictionary:dict];
    }
    NSString *str = [obj description];
    CLBLog(@"WARNING: Invalid property value type, received %@, coercing to %@", [obj class], str);
    return str;
}

+ (BOOL)isEmptyString:(NSString *) str {
    return (str == nil || [str isKindOfClass:[NSNull class]] || [str length] == 0);
}

+ (NSString *)coerceToString:(id)obj withName:(NSString *)name {
    NSString *coercedString;
    if (![obj isKindOfClass:[NSString class]]) {
        coercedString = [obj description];
        CLBLog(@"WARNING: Non-string %@, received %@, coercing to %@", name, [obj class], coercedString);
    } else {
        coercedString = obj;
    }
    return coercedString;
}

+ (NSString *)platformDataDirectory {
    return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) objectAtIndex:0];
}

+ (BOOL)isValidCountryCode:(NSString *)countryCode {
    for (NSString *isoCode in [NSLocale ISOCountryCodes]) {
        if ([isoCode isEqualToString:countryCode])
            return YES;
    }
    return NO;
}

+ (NSString *)generateMD5:(NSString *)str {
    // Create pointer to the string as UTF8
    const char *ptr = [str UTF8String];
    // Create byte array of unsigned chars
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    // Create 16 byte MD5 hash value, store in buffer
    CC_MD5(ptr, (int)strlen(ptr), md5Buffer);
    // Convert MD5 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+ (NSString *)generateSHA1:(NSString *)str {
    // Data from string
    NSData *data = [str dataUsingEncoding:NSUTF8StringEncoding];
    // Create byte array of unsigned chars
    unsigned char sha1Buffer[CC_SHA1_DIGEST_LENGTH];
    CC_SHA1(data.bytes, (int)data.length, sha1Buffer);
    // Convert SHA1 value in the buffer to NSString of hex values
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    for (int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", sha1Buffer[i]];
    
    return output;
}


@end
