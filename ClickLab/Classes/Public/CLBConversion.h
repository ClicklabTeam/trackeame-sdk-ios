//
//  CLBConversion.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBEvent.h"
#import "CLBConversionProduct.h"

@interface CLBConversion : CLBEvent

@property (nonatomic, strong, readonly) NSString *transactionId;
@property (nonatomic, strong, readonly) NSString *product;
@property (nonatomic, strong, readonly) NSNumber *price;
@property (nonatomic, strong, readonly) NSNumber *exchange;
@property (nonatomic, strong, readonly) NSString *currency;
@property (nonatomic, strong, readonly) NSArray<CLBConversionProduct *> *cart;
@property (nonatomic, strong, readonly) NSDictionary<NSString *, id> *params;

/**
 A new instance of a Conversion Event.

 @param transactionId Identifier of the transaction
 @return A new instance of the conversion event
 */
+ (instancetype)conversionWithTransactionId:(NSString *)transactionId;

/**
 Set the product of the conversion event.

 @param product Name of the product that produced the transaction
 @return The modified instance of the conversion
 */
- (CLBConversion *)setProduct:(NSString *)product;

/**
 Set the price of the product in the conversion event.

 @param price Price of the product expressed in local currency
 @return The modified instance of the conversion
 */
- (CLBConversion *)setPrice:(NSNumber *)price;

/**
 Set the exchange rate of the product price in the conversion event.

 @param exchange Exchange rate between the currency and USD
 @return The modified instance of the conversion
 */
- (CLBConversion *)setExchange:(NSNumber *)exchange;

/**
 Set the currency of the product price in the conversion event.

 @param currency The currency in which the transaction was made
 @return The modified instance of the conversion
 */
- (CLBConversion *)setCurrency:(NSString *)currency;

/**
 Set the product list contained in the conversion event cart.

 @param cart The product list contained in the cart
 @return The modified instance of the conversion
 */
- (CLBConversion *)setCart:(NSArray<CLBConversionProduct *> *)cart;

/**
 Set the params of the conversion event.

 @param params The extra parameters that need to be tracked
 @return The modified instance of the conversion
 */
- (CLBConversion *)setParams:(NSDictionary<NSString *,id> *)params;

@end
