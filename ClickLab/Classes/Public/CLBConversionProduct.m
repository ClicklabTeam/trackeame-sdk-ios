//
//  CLBConversionProduct.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBConversionProduct.h"
#import "CLBConstants.h"
#import "CLBUtils.h"
#import "CLBLogUtil.h"

@implementation CLBConversionProduct

+ (instancetype)conversionProductWithSubtransactionId:(NSString *)subtransactionId {
    CLBConversionProduct *conversionproduct = [CLBConversionProduct new];
    return [conversionproduct setSubtransactionId:subtransactionId];
}

- (CLBConversionProduct *)setSubtransactionId:(NSString *)subtransactionId {
    if ([CLBUtils isEmptyString:subtransactionId]) {
        // TODO: raise error ??
        CLBLog(@"Invalid empty subtransactionId");
        return self;
    }
    _subtransactionId = subtransactionId;
    return self;
}

- (CLBConversionProduct *)setProduct:(NSString *)product {
    _product = product;
    return self;
}

- (CLBConversionProduct *)setPrice:(NSNumber *)price {
    _price = price;
    return self;
}

- (CLBConversionProduct *)setParams:(NSDictionary<NSString *,id> *)params {
    _params = params;
    return self;
}

- (NSDictionary<NSString *,id> *)conversionProduct2JSON {
    NSMutableDictionary<NSString *,id> *json = [NSMutableDictionary new];
    [json setValue:self.subtransactionId forKey:kCLBConversionProductSubtransactionIdKey];
    [json setValue:self.product forKey:kCLBConversionProductProductKey];
    [json setValue:self.price forKey:kCLBConversionProductPriceKey];
    [json setValue:self.params forKey:kCLBConversionProductExtraParamsKey];
    return json;
}

+ (NSArray *)conversionProducts2JSON:(NSArray<CLBConversionProduct *> *)conversionProducts {
    if (!conversionProducts)
        return nil;
    
    NSMutableArray *jsonArray = [NSMutableArray new];
    for (CLBConversionProduct *p in conversionProducts) {
        NSDictionary<NSString *,id> *json = [p conversionProduct2JSON];
        [jsonArray addObject:json];
    }
    return jsonArray;
}


@end
