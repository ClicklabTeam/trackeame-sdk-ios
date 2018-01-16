//
//  CLBConstants.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import <Foundation/Foundation.h>

extern NSString *const kCLBVersion;
extern NSString *const kCLBDefaultInstance;

extern NSString *const kCLBOSName;
extern NSString *const kCLBDeviceManufacturer;
extern NSString *const kCLBVersionKey;
extern NSString *const kCLBBuildKey;

extern const int kCLBEventUploadThreshold;
extern const int kCLBEventMaxCount;

extern NSString *const kCLBBackgroundQueueName;
extern const int kCLBEventUploadMaxBatchSize;
extern const int kCLBEventRemoveBatchSize;
extern const int kCLBEventUploadPeriodSeconds;
extern const int kCLBMaxStringLength;
extern const int kCLBMaxPropertyKeys;

// Event Type
extern NSString *const kCLBEventTypeGeneric;
extern NSString *const kCLBEventTypeOpenApp;
extern NSString *const kCLBEventTypeInstall;
extern NSString *const kCLBEventTypeConversion;
extern NSString *const kCLBEventTypeUndefined;

// JSON Log
extern NSString *const kCLBCookieKey;
extern NSString *const kCLBCountryKey;
extern NSString *const kCLBEmailKey;
extern NSString *const kCLBApiKey;
extern NSString *const kCLBExecutionIdKey;
extern NSString *const kCLBSDKOSKey;
extern NSString *const kCLBSDKVersionKey;
extern NSString *const kCLBOSBrandKey;
extern NSString *const kCLBOSVersionKey;
extern NSString *const kCLBAppNameKey;
extern NSString *const kCLBAppPackageKey;
extern NSString *const kCLBAppVersionKey;
extern NSString *const kCLBBrandKey;
extern NSString *const kCLBModelKey;
extern NSString *const kCLBCarrierKey;
extern NSString *const kCLBScreenResolutionKey;
extern NSString *const kCLBIPKey;
extern NSString *const kCLBIDFAKey;
extern NSString *const kCLBTimeZoneKey;
extern NSString *const kCLBDeviceCountryKey;
extern NSString *const kCLBLanguageKey;
// JSON Aux
extern NSString *const kCLBEventIdKey;
extern NSString *const kCLBEventMomentKey;
// JSON Event
extern NSString *const kCLBEventTypeKey;
extern NSString *const kCLBEventPostIdKey;
extern NSString *const kCLBEventPostRetryCountKey;
extern NSString *const kCLBEventDelayKey;
extern NSString *const kCLBGenericEventCustomTypeKey;
extern NSString *const kCLBGenericEventExtraParamsKey;
extern NSString *const kCLBOpenAppEventURLKey;
extern NSString *const kCLBOpenAppEventRefererKey;
extern NSString *const kCLBOpenAppEventExtraParamsKey;
extern NSString *const kCLBInstallEventRefererKey;
// JSON Conversion
extern NSString *const kCLBConversionTransactionIdKey;
extern NSString *const kCLBConversionProductKey;
extern NSString *const kCLBConversionPriceKey;
extern NSString *const kCLBConversionExchangeKey;
extern NSString *const kCLBConversionCurrencyKey;
extern NSString *const kCLBConversionCartKey;
extern NSString *const kCLBConversionExtraParamsKey;
extern NSString *const kCLBConversionProductSubtransactionIdKey;
extern NSString *const kCLBConversionProductProductKey;
extern NSString *const kCLBConversionProductPriceKey;
extern NSString *const kCLBConversionProductExtraParamsKey;

// API Server
extern NSString *const kCLBAPIServerEvent;
extern NSString *const kCLBAPIServerConversion;
