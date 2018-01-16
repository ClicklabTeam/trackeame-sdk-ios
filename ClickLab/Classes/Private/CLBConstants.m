//
//  CLBConstants.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBConstants.h"

NSString *const kCLBVersion = @"1.0.7";
NSString *const kCLBDefaultInstance = @"default";

// iOS
const int kCLBEventUploadThreshold = 30;
const int kCLBEventMaxCount = 1000;

// Device
NSString *const kCLBOSName = @"ios";
NSString *const kCLBDeviceManufacturer = @"Apple";
NSString *const kCLBVersionKey = @"CLBVersionKey";
NSString *const kCLBBuildKey = @"CLBBuildKey";

NSString *const kCLBBackgroundQueueName = @"BACKGROUND";
const int kCLBEventUploadMaxBatchSize = 100;
const int kCLBEventRemoveBatchSize = 20;
const int kCLBEventUploadPeriodSeconds = 0; // Delay time to send an event [seconds]
const int kCLBMaxStringLength = 1024;
const int kCLBMaxPropertyKeys = 1000;

// Event type
NSString *const kCLBEventTypeGeneric = @"generic";
NSString *const kCLBEventTypeOpenApp = @"openapp";
NSString *const kCLBEventTypeInstall = @"install";
NSString *const kCLBEventTypeConversion = @"conversion";
NSString *const kCLBEventTypeUndefined = @"undefined";

// JSON Log
NSString *const kCLBCookieKey = @"trackeame_cookie";
NSString *const kCLBCountryKey = @"country";
NSString *const kCLBEmailKey = @"hm";
NSString *const kCLBApiKey = @"key";
NSString *const kCLBExecutionIdKey = @"execution_id";
NSString *const kCLBSDKOSKey = @"sdk_os";
NSString *const kCLBSDKVersionKey = @"sdk_version";
NSString *const kCLBOSBrandKey = @"os_brand";
NSString *const kCLBOSVersionKey = @"os_version";
NSString *const kCLBAppNameKey = @"app_name";
NSString *const kCLBAppPackageKey = @"app_package";
NSString *const kCLBAppVersionKey = @"app_version";
NSString *const kCLBBrandKey = @"hw_brand";
NSString *const kCLBModelKey = @"hw_version";
NSString *const kCLBCarrierKey = @"hw_carrier";
NSString *const kCLBScreenResolutionKey = @"hw_screen_res";
NSString *const kCLBIPKey = @"ip";
NSString *const kCLBIDFAKey = @"mobile_id";
NSString *const kCLBTimeZoneKey = @"hw_timezone";
NSString *const kCLBDeviceCountryKey = @"hw_country";
NSString *const kCLBLanguageKey = @"hw_language";
// JSON Aux
NSString *const kCLBEventIdKey = @"event_id";
NSString *const kCLBEventMomentKey = @"moment";
// JSON Event
NSString *const kCLBEventTypeKey = @"clicklab_event_type";
NSString *const kCLBEventPostIdKey = @"post_id";
NSString *const kCLBEventPostRetryCountKey = @"post_retry_count";
NSString *const kCLBEventDelayKey = @"delay";
NSString *const kCLBGenericEventCustomTypeKey = @"custom_event_type";
NSString *const kCLBGenericEventExtraParamsKey = @"extra_params";
NSString *const kCLBOpenAppEventURLKey = @"url";
NSString *const kCLBOpenAppEventRefererKey = @"referer";
NSString *const kCLBOpenAppEventExtraParamsKey = @"extra_params";
NSString *const kCLBInstallEventRefererKey = @"referer";
// JSON Conversion
NSString *const kCLBConversionTransactionIdKey = @"id_tr";
NSString *const kCLBConversionProductKey = @"pr";
NSString *const kCLBConversionPriceKey = @"pri";
NSString *const kCLBConversionExchangeKey = @"exch";
NSString *const kCLBConversionCurrencyKey = @"cur";
NSString *const kCLBConversionCartKey = @"cart";
NSString *const kCLBConversionExtraParamsKey = @"extra_params";
NSString *const kCLBConversionProductSubtransactionIdKey = @"id_subtr";
NSString *const kCLBConversionProductProductKey = @"pr";
NSString *const kCLBConversionProductPriceKey = @"pri";
NSString *const kCLBConversionProductExtraParamsKey = @"extra_params";

// API Server
NSString *const kCLBAPIServerEvent = @"https://www.trackeame.com/sem-tracker-web/sdk/event";
NSString *const kCLBAPIServerConversion = @"https://www.trackeame.com/sem-tracker-web/sdk/conversion";
