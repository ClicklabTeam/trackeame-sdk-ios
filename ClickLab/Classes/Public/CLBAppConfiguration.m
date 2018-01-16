//
//  CLBAppConfiguration.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBAppConfiguration.h"
#import "CLBUtils.h"

@implementation CLBAppConfiguration

+ (instancetype)configurationWithKey:(NSString *)key andAppName:(NSString *)appName {
    return [[CLBAppConfiguration alloc] initWithKey:key andAppName:appName];
}

- (instancetype)initWithKey:(NSString *)key andAppName:(NSString *)appName {
    self = [super init];
    if (self) {
        _apiKey = key;
        _appName = appName;
    }
    return self;
}

- (void)setCountry:(NSString *)country {
    if (![CLBUtils isValidCountryCode:country]) {
        @throw [NSException exceptionWithName:@"Bad Country Code"
                                       reason:@"Please use ISO 3166 country code."
                                     userInfo:nil];
    }
    _country = country;
}

@end
