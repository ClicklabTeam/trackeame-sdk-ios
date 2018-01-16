//
//  CLBApp.h
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CLBAppConfiguration.h"
#import "CLBGenericEvent.h"
#import "CLBOpenAppEvent.h"
#import "CLBInstallEvent.h"
#import "CLBConversion.h"


@interface CLBApp : NSObject

#pragma mark - Properties

/**
 * Used by the ClickLab client to configure various options.
 */
@property (nonatomic, strong, readonly) CLBAppConfiguration *configuration;

/**
 Your ClickLab ApiKey.
 */
@property (nonatomic, strong, readonly) NSString *apiKey;

/**
 Your application name.
 */
@property (nonatomic, strong, readonly) NSString *appName;

/**
 The country of the current user.
 */
@property (nonatomic, strong) NSString *country;

/**
 The email of the current user.
 */
@property (nonatomic, strong) NSString *email;


#pragma mark - Methods

/**
 * Returns the shared ClickLab client.
 */
+ (instancetype)shared;

/**
 * Setup the ClickLab client.
 *
 * @param configuration The configuration used to setup the client.
 */
+ (void)setupWithConfiguration:(CLBAppConfiguration *)configuration;

/**
 * Enables/disables debug logging to trace your data going through the SDK.
 *
 * @param showDebugLogs `YES` to enable logging, `NO` otherwise. `NO` by default.
 */
+ (void)showDebugLog:(BOOL)showDebugLogs;

/**
 Logs the Generic Event that is provided. It saves the event and tries to send it as soon as possible.

 @param event Generic event to be tracked
 */
- (void)logGenericEvent:(CLBGenericEvent *)event;

/**
 Logs the Open App Event that is provided. It saves the event and tries to send it as soon as possible.

 @param event Open App event to be tracked
 */
- (void)logOpenAppEvent:(CLBOpenAppEvent *)event;

/**
 Logs the Conversion Event that is provided. It saves the event and tries to send it as soon as possible.

 @param event Conversion event to be tracked
 */
- (void)logConversion:(CLBConversion *)event;

@end
