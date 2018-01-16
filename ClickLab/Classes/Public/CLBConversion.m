//
//  CLBConversion.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBConversion.h"
#import "CLBConstants.h"
#import "CLBUtils.h"
#import "CLBLogUtil.h"

@implementation CLBConversion

- (CLBEventType)getEventType {
    return CLBEventTypeConversion;
}

+ (instancetype)conversionWithTransactionId:(NSString *)transactionId {
    CLBConversion *conversion = [CLBConversion new];
    return [conversion setTransactionId:transactionId];
}

- (CLBConversion *)setTransactionId:(NSString *)transactionId {
    if ([CLBUtils isEmptyString:transactionId]) {
        // TODO: raise error ??
        CLBLog(@"Invalid empty transactionId");
        return self;
    }
    
    _transactionId = transactionId;
    return self;
}

- (CLBConversion *)setProduct:(NSString *)product {
    _product = product;
    return self;
}

- (CLBConversion *)setPrice:(NSNumber *)price {
    _price = price;
    return self;
}

- (CLBConversion *)setExchange:(NSNumber *)exchange {
    _exchange = exchange;
    return self;
}

- (CLBConversion *)setCurrency:(NSString *)currency {
    if ([CLBUtils isEmptyString:currency]) {
        // TODO: raise error ??
        CLBLog(@"Invalid empty currency.");
        return self;
    }
    
    if (currency.length != 3) {
        // TODO: raise error ??
        CLBLog(@"Invalid currency. An ISO 4217 Currency Code must be three characters long.");
        return self;
    }
    
    NSLocale *locale = [[NSLocale alloc] initWithLocaleIdentifier:currency];
    if (!locale) {
        // TODO: raise error ??
        CLBLog(@"Invalid currency. An ISO 4217 Currency Code must be three characters long.");
        return self;
    }
    _currency = [currency uppercaseString];
    return self;
}

- (CLBConversion *)setCart:(NSArray<CLBConversionProduct *> *)cart {
    _cart = cart;
    return self;
}

- (CLBConversion *)setParams:(NSDictionary<NSString *,id> *)params {
    _params = params;
    return self;
}

- (NSDictionary<NSString *,id> *)event2JSON {
    NSMutableDictionary<NSString *,id> *json = [NSMutableDictionary dictionaryWithDictionary:[super event2JSON]];
    [json setValue:self.transactionId forKey:kCLBConversionTransactionIdKey];
    [json setValue:self.product forKey:kCLBConversionProductKey];
    [json setValue:self.price forKey:kCLBConversionPriceKey];
    [json setValue:self.exchange forKey:kCLBConversionExchangeKey];
    [json setValue:self.currency forKey:kCLBConversionCurrencyKey];
    NSArray *jsonCart = [CLBConversionProduct conversionProducts2JSON:self.cart];
    [json setValue:jsonCart forKey:kCLBConversionCartKey];
    [json setValue:self.params forKey:kCLBConversionExtraParamsKey];
    return json;
}

@end
