//
//  CLBConversionProduct.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CLBConversionProduct : NSObject

@property (nonatomic, strong, readonly) NSString *subtransactionId;
@property (nonatomic, strong, readonly) NSString *product;
@property (nonatomic, strong, readonly) NSNumber *price;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id> *params;

/**
 A new instance of a product contained in the conversion cart.

 @param subtransactionId Identifier of the subtransaction
 @return A new instance of the conversion product
 */
+ (instancetype)conversionProductWithSubtransactionId:(NSString *)subtransactionId;

/**
 Set the product name contained in the conversion cart.

 @param product Name of the product
 @return The modified instance of the conversion product
 */
- (CLBConversionProduct *)setProduct:(NSString *)product;

/**
 Set the product price contained in the conversion cart.

 @param price Price of the product expressed in local currency
 @return The modified instance of the conversion product
 */
- (CLBConversionProduct *)setPrice:(NSNumber *)price;

/**
 Set the extra parameters contained in the conversion cart.

 @param params The extra parameters that need to be tracked
 @return The modified instance of the conversion product
 */
- (CLBConversionProduct *)setParams:(NSDictionary<NSString *,id> *)params;

/**
 JSON representation of the product.

 @return JSON object
 */
- (NSDictionary<NSString *,id> *)conversionProduct2JSON;

/**
 Create a new instance of the product from the JSON array list.

 @param conversionProducts JSON array list that represents the products
 @return A new instance of the conversion product
 */
+ (NSArray *)conversionProducts2JSON:(NSArray<CLBConversionProduct *> *)conversionProducts;

@end
