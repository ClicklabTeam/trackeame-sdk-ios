//
//  CLBApp.m
//  ClickLab
//
//  Copyright © 2017 ClickLab. All rights reserved.
//

#import "CLBApp.h"
#import "CLBConstants.h"
#import "CLBDeviceInfo.h"
#import "CLBDatabaseHelper.h"
#import "CLBUtils.h"
#import "CLBLogUtil.h"
#import "CLBEvent.h"
#import "CLBHTTPClient.h"
#import "CLBReachability.h"
@import iAd;


static CLBApp *__sharedInstance = nil;

@interface CLBApp ()

@property (nonatomic, strong) NSOperationQueue *backgroundQueue;
@property (nonatomic, strong) NSOperationQueue *initializerQueue;
@property (nonatomic, strong) CLBDatabaseHelper *dbHelper;
@property (nonatomic, strong) CLBHTTPClient *httpClient;
@property (nonatomic, assign) BOOL initialized;
@property (nonatomic, assign) BOOL backoffUpload;
@property (nonatomic, assign) int backoffUploadBatchSize;
@property (nonatomic, assign) int eventUploadThreshold;
@property (nonatomic, assign) int eventUploadMaxBatchSize;
@property (nonatomic, assign) int eventMaxCount;
@property (nonatomic, assign) int eventUploadPeriodSeconds;

@end

@implementation CLBApp {
    
    BOOL _updateScheduled;
    BOOL _updatingCurrently;
    UIBackgroundTaskIdentifier _uploadTaskID;
    BOOL _uploadSuccessful;
    
    CLBDeviceInfo *_deviceInfo;
    NSDictionary *_staticContext;
    
    BOOL _inForeground;
    NSString *_executionId;
    NSString *_cookie;
}

#pragma mark - Static methods

+ (instancetype)shared {
    if (!__sharedInstance) {
        @throw [NSException exceptionWithName:@"Bad Initization" reason:@"Please init CLBApp using setupWithConfiguration:" userInfo:nil];
    }
    return __sharedInstance;
}

+ (void)showDebugLog:(BOOL)showDebugLogs {
    CLBShowDebugLogs(showDebugLogs);
}

+ (void)setupWithConfiguration:(CLBAppConfiguration *)configuration {
    if (__sharedInstance) {
        @throw [NSException exceptionWithName:@"Bad Initization" reason:@"CLBApp is already initialized." userInfo:nil];
    }
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __sharedInstance = [[CLBApp alloc] initWithConfiguration:configuration];
    });
}

#pragma mark - Main class configuration

- (id)initWithConfiguration:(CLBAppConfiguration *)configuration {
    
    // TODO: validate configuracion
    
    self = [super init];
    if (self) {
        
        _configuration = configuration;
        
        _initialized = NO;
        _updateScheduled = NO;
        _updatingCurrently = NO;
        _backoffUpload = NO;
        _dbHelper = [CLBDatabaseHelper getDatabaseHelper];
        _httpClient = [CLBHTTPClient HTTPClient];
        _executionId = [CLBUtils generateUUID];
        _cookie = [_dbHelper getValue:kCLBCookieKey];
        _country = [_dbHelper getValue:kCLBCountryKey];
        _email = [_dbHelper getValue:kCLBEmailKey];
        
        self.eventUploadThreshold = kCLBEventUploadThreshold;
        self.eventMaxCount = kCLBEventMaxCount;
        self.eventUploadMaxBatchSize = kCLBEventUploadMaxBatchSize;
        self.eventUploadPeriodSeconds = kCLBEventUploadPeriodSeconds;
        _backoffUploadBatchSize = self.eventUploadMaxBatchSize;
        
        // Configuration values
        _appName = configuration.appName;
        if (configuration.country)
            [self setCountry:configuration.country];
        if (configuration.email)
            [self setEmail:configuration.email];
        
        _initializerQueue = [[NSOperationQueue alloc] init];
        _backgroundQueue = [[NSOperationQueue alloc] init];
        // Force method calls to happen in FIFO order by only allowing 1 concurrent operation
        [_backgroundQueue setMaxConcurrentOperationCount:1];
        // Ensure initialize finishes running asynchronously before other calls are run
        [_backgroundQueue setSuspended:YES];
        // Name the queue so runOnBackgroundQueue can tell which queue an operation is running
        _backgroundQueue.name = kCLBBackgroundQueueName;
        
        [_initializerQueue addOperationWithBlock:^{
            _deviceInfo = [[CLBDeviceInfo alloc] init];
            _uploadTaskID = UIBackgroundTaskInvalid;
            [_backgroundQueue setSuspended:NO];
        }];
        
        [self addObservers];
        
        // Init
        [self initializeApiKey:configuration.apiKey];
        
        // Load static context after init the SDK
        _staticContext = [self staticContext];
    }
    return self;
}

- (void)addObservers {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc addObserver:self
               selector:@selector(enterForeground)
                   name:UIApplicationWillEnterForegroundNotification
                 object:nil];
    [nc addObserver:self
               selector:@selector(enterBackground)
                   name:UIApplicationDidEnterBackgroundNotification
                 object:nil];
    
    // Allocate a reachability object
    CLBReachability *reach = [CLBReachability reachabilityWithHostname:@"www.google.com"];
    // Here we set up a NSNotification observer. The Reachability that caused the notification is passed in the object parameter
    [nc addObserver:self
           selector:@selector(reachabilityChanged:)
               name:kCLBReachabilityChangedNotification
             object:nil];
    [reach startNotifier];
    
    UIApplication *application = [self getSharedApplication];
    if (application) {
        for (NSString *name in @[ UIApplicationDidEnterBackgroundNotification,
                                  UIApplicationDidFinishLaunchingNotification,
                                  UIApplicationWillEnterForegroundNotification,
                                  UIApplicationWillTerminateNotification,
                                  UIApplicationWillResignActiveNotification,
                                  UIApplicationDidBecomeActiveNotification ]) {
            [nc addObserver:self selector:@selector(handleAppStateNotification:) name:name object:application];
        }
    }
}

- (void)handleAppStateNotification:(NSNotification *)note {
    if ([note.name isEqualToString:UIApplicationDidFinishLaunchingNotification]) {
        [self _applicationDidFinishLaunchingWithOptions:note.userInfo];
    } else if ([note.name isEqualToString:UIApplicationWillEnterForegroundNotification]) {
        [self _applicationWillEnterForeground];
    }
}

- (void)_applicationDidFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Get version and build stored by the SDK
    NSString *previousBuild = [[NSUserDefaults standardUserDefaults] stringForKey:kCLBBuildKey];
    
    // Get version and build of the app
    NSString *currentVersion = [[NSBundle mainBundle] infoDictionary][@"CFBundleShortVersionString"];
    NSString *currentBuild = [[NSBundle mainBundle] infoDictionary][@"CFBundleVersion"];
    
    // Check if the app was installed
    if (!previousBuild) {
        
        // Track install event
        CLBInstallEvent *installEvent = [CLBInstallEvent installEvent];
        [installEvent setReferer:launchOptions[UIApplicationLaunchOptionsSourceApplicationKey]];
        [self logEvent:installEvent];
        
    } else if (![currentBuild isEqualToString:previousBuild]) {
        // TODO: track app update ???
    }
    
    // Track open app event
    CLBOpenAppEvent *openAppEvent = [CLBOpenAppEvent openAppEvent];
    [openAppEvent setUrl:launchOptions[UIApplicationLaunchOptionsURLKey]];
    [openAppEvent setReferer:launchOptions[UIApplicationLaunchOptionsSourceApplicationKey]];
    [self logEvent:openAppEvent];
    
    // Save the current version of the app
    [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:kCLBVersionKey];
    [[NSUserDefaults standardUserDefaults] setObject:currentBuild forKey:kCLBBuildKey];
    [[NSUserDefaults standardUserDefaults] synchronize];
}

- (void)_applicationWillEnterForeground {
    // Track open app event
    CLBOpenAppEvent *openAppEvent = [CLBOpenAppEvent openAppEvent];
    // TODO: the url isn't showed on this event. The url is only showed on the openURL: UIApplicationDelegate method.
    [self logEvent:openAppEvent];
}

- (void)reachabilityChanged:(NSNotification *)note {
    // Nothing to do
//    CLBReachability *reach = (CLBReachability *)[note object];
}

- (void)removeObservers {
    NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
    [nc removeObserver:self name:UIApplicationWillEnterForegroundNotification object:nil];
    [nc removeObserver:self name:UIApplicationDidEnterBackgroundNotification object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)dealloc {
    [self removeObservers];
}

- (void)initializeApiKey:(NSString *)apiKey {
    
    if ([CLBUtils isEmptyString:apiKey]) {
        CLBLog(@"ERROR: apiKey cannot be nil or blank in initializeApiKey:");
        @throw [NSException exceptionWithName:@"Bad apiKey" reason:@"The apiKey cannot be nil or blank" userInfo:nil];
    }
    
    CLBLog(@"CLBApp initialized with apiKey: %@", apiKey);
    
    if (!_initialized) {
        _apiKey = apiKey;
        UIApplication *app = [self getSharedApplication];
        if (app != nil) {
            UIApplicationState state = app.applicationState;
            if (state != UIApplicationStateBackground) {
                // If this is called while the app is running in the background, for example via a push notification, don't call enterForeground
                [self enterForeground];
            }
        }
        _initialized = YES;
    }
}

- (UIApplication *)getSharedApplication {
    Class UIApplicationClass = NSClassFromString(@"UIApplication");
    if (UIApplicationClass && [UIApplicationClass respondsToSelector:@selector(sharedApplication)]) {
        return [UIApplication performSelector:@selector(sharedApplication)];
    }
    return nil;
}

/**
 * Run a block in the background. If already in the background, run immediately.
 */
- (BOOL)runOnBackgroundQueue:(void (^)(void))block {
    if ([[NSOperationQueue currentQueue].name isEqualToString:kCLBBackgroundQueueName]) {
        CLBLog(@"Already running in the background.");
        block();
        return NO;
    }
    else {
        [_backgroundQueue addOperationWithBlock:block];
        return YES;
    }
}

#pragma mark - Track events

- (void)logGenericEvent:(CLBGenericEvent *)event {
    [self logEvent:event];
}

- (void)logOpenAppEvent:(CLBOpenAppEvent *)event {
    [self logEvent:event];
}

- (void)logInstallEvent:(CLBInstallEvent *)event {
    [self logEvent:event];
}

- (void)logConversion:(CLBConversion *)event {
    if (event.price && (!event.currency || !event.exchange)) {
        CLBLog(@"ERROR: All Price Exchange rate and Currency should be set");
        return;
    }
    
    [self logEvent:event];
}

- (void)logEvent:(CLBEvent *)event {
    if (_apiKey == nil) {
        CLBLog(@"ERROR: apiKey cannot be nil or empty, set apiKey with setupWithConfiguration: before calling logEvent");
        return;
    }
    
    [self runOnBackgroundQueue:^{
        
        NSMutableDictionary *eventJSON = [NSMutableDictionary dictionaryWithDictionary:[event event2JSON]];
        
        // Add extra parameters for all events
        [self annotateEvent:eventJSON];
        
        // Convert event dictionary to JSON String
        NSError *error = nil;
        NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[CLBUtils makeJSONSerializable:eventJSON] options:0 error:&error];
        if (error != nil) {
            CLBLog(@"ERROR: could not JSONSerialize event type %@: %@", [CLBEvent nameFromEventType:[event getEventType]], error);
            return;
        }
        NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
        if ([CLBUtils isEmptyString:jsonString]) {
            CLBLog(@"ERROR: JSONSerializing event type %@ resulted in an NULL string", [CLBEvent nameFromEventType:[event getEventType]]);
            return;
        }
        (void) [self.dbHelper addEvent:jsonString];
        
        CLBLog(@"Logged %@ Event", eventJSON[kCLBEventTypeKey]);
        
        [self truncateEventQueues];
        
        int eventCount = [self.dbHelper getEventCount]; // refetch since events may have been deleted
        if ((eventCount % self.eventUploadThreshold) == 0 && eventCount >= self.eventUploadThreshold) {
            [self uploadEvents];
        } else {
            [self uploadEventsWithDelay:self.eventUploadPeriodSeconds];
        }
    }];
}

- (void)truncateEventQueues {
    int numEventsToRemove = MIN(MAX(1, self.eventMaxCount/10), kCLBEventRemoveBatchSize);
    int eventCount = [self.dbHelper getEventCount];
    if (eventCount > self.eventMaxCount) {
        [self.dbHelper removeEvents:([self.dbHelper getNthEventId:numEventsToRemove])];
    }
}

- (void)annotateEvent:(NSMutableDictionary *)event {
    [event addEntriesFromDictionary:_staticContext];
    [event addEntriesFromDictionary:[self liveContext]];
}

#pragma mark - Upload events

- (void)uploadEventsWithDelay:(int)delay {
    if (!_updateScheduled) {
        _updateScheduled = YES;
        __block __weak CLBApp *weakSelf = self;
        [_backgroundQueue addOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(), ^{
                [weakSelf performSelector:@selector(uploadEventsInBackground) withObject:nil afterDelay:delay];
            });
        }];
    }
}

- (void)uploadEventsInBackground {
    _updateScheduled = NO;
    [self uploadEvents];
}

- (void)uploadEvents {
    int limit = (_backoffUpload ? _backoffUploadBatchSize : self.eventUploadMaxBatchSize);
    [self uploadEventsWithLimit:limit];
}

- (void)uploadEventsWithLimit:(int)limit {
    if (_apiKey == nil) {
        CLBLog(@"ERROR: apiKey cannot be nil or empty, set apiKey with setupWithConfiguration: before calling uploadEvents:");
        return;
    }
    
    @synchronized (self) {
        if (_updatingCurrently) {
            return;
        }
        _updatingCurrently = YES;
    }
    
    [self runOnBackgroundQueue:^{
        
        long eventCount = [self.dbHelper getEventCount];
        long numEvents = limit > 0 ? fminl(eventCount, limit) : eventCount;
        if (numEvents == 0) {
            _updatingCurrently = NO;
            return;
        }
        NSMutableArray *events = [self.dbHelper getEvents:-1 limit:numEvents];
        [self startEventUploadPostRequestOfEvents:events];
    }];
}

- (void)startEventUploadPostRequestOfEvents:(NSArray *)events {
    _uploadSuccessful = YES;
    [self makeEventUploadPostRequestOfEvents:events];
}

- (void)makeEventUploadPostRequestOfEvents:(NSArray *)events {
    CLBLog(@"Pending events: %i", events.count);
    
    if (events.count > 0 && _uploadSuccessful) {
        NSMutableDictionary *event = [NSMutableDictionary dictionaryWithDictionary:[events firstObject]];
        
        NSNumber *eventId = [event valueForKey:kCLBEventIdKey];
        NSNumber *moment = [event valueForKey:kCLBEventMomentKey];
        NSNumber *now = [NSNumber numberWithLongLong:[[self currentTime] timeIntervalSince1970] * 1000];
        NSNumber *delay = [NSNumber numberWithLongLong:([now longLongValue] - [moment longLongValue]) / 1000];
        
        // Add pending values
        [event setValue:_cookie forKey:kCLBCookieKey];
        [event setValue:delay forKey:kCLBEventDelayKey];
        // Remove internal values
        [event removeObjectForKey:kCLBEventIdKey];
        [event removeObjectForKey:kCLBEventMomentKey];
        
        // Events for next call
        NSMutableArray *cleanedEvents = [NSMutableArray arrayWithArray:events];
        [cleanedEvents removeObjectAtIndex:0];
        
        CLBLog(@"Event to upload: %@", event);
        
        // Completion handler for events and conversion
        __weak CLBApp *weakSelf = self;
        id completionHandler = ^(BOOL success, NSDictionary *response, BOOL retry) {
            if (success && response) {
                // Check the new cookie
                [weakSelf setCookie:[response valueForKey:kCLBCookieKey]];
                // Remove event from DB
                [_dbHelper removeEvent:[eventId longLongValue]];
                // Send the next event
                [weakSelf makeEventUploadPostRequestOfEvents:cleanedEvents];
                
            } else if (retry) {
                // Increment the retry count value
                NSNumber *retryCount = [NSNumber numberWithInt:([[event valueForKey:kCLBEventPostRetryCountKey] intValue] + 1)];
                [event setValue:retryCount forKey:kCLBEventPostRetryCountKey];
                [event setValue:moment forKey:kCLBEventMomentKey];
                
                // Convert event dictionary to JSON String
                NSError *error = nil;
                NSData *jsonData = [NSJSONSerialization dataWithJSONObject:[CLBUtils makeJSONSerializable:event] options:0 error:&error];
                if (error != nil) {
                    CLBLog(@"ERROR: could not JSONSerialize eventId %@: %@", eventId, error);
                    return;
                }
                NSString *jsonString = [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
                if ([CLBUtils isEmptyString:jsonString]) {
                    CLBLog(@"ERROR: JSONSerializing eventId %@ resulted in an NULL string", eventId);
                    return;
                }
                
                // Update the event
                [_dbHelper updateEvent:jsonString eventId:[eventId longLongValue]];
                // Finish upload
                [weakSelf finishEventUploadPostRequest];
            } else {
                // Remove event from DB
                [_dbHelper removeEvent:[eventId longLongValue]];
                // Send the next event
                [weakSelf makeEventUploadPostRequestOfEvents:cleanedEvents];
            }
        };
        
        // Post request
        if ([[event valueForKey:kCLBEventTypeKey] isEqualToString:kCLBEventTypeConversion])
            [self.httpClient uploadConversion:event completionHandler:completionHandler];
        else
            [self.httpClient uploadEvent:event completionHandler:completionHandler];
        
    } else {
        
        [self finishEventUploadPostRequest];
    }
}

- (void)finishEventUploadPostRequest {
    _updatingCurrently = NO;
    
    // FIXME: has internet??
    if (_uploadSuccessful && [self.dbHelper getEventCount] > self.eventUploadThreshold) {
        int limit = _backoffUpload ? _backoffUploadBatchSize : 0;
        [self uploadEventsWithLimit:limit];
        
    } else if (_uploadTaskID != UIBackgroundTaskInvalid) {
        if (_uploadSuccessful) {
            _backoffUpload = NO;
            _backoffUploadBatchSize = self.eventUploadMaxBatchSize;
        }
        
        // Upload finished, allow background task to be ended
        UIApplication *app = [self getSharedApplication];
        if (app != nil) {
            [app endBackgroundTask:_uploadTaskID];
            _uploadTaskID = UIBackgroundTaskInvalid;
        }
    }
}

#pragma mark - Application lifecycle methods

- (void)enterForeground {
    UIApplication *app = [self getSharedApplication];
    if (app == nil) {
        return;
    }
    
    // Stop uploading
    if (_uploadTaskID != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:_uploadTaskID];
        _uploadTaskID = UIBackgroundTaskInvalid;
    }
    [self runOnBackgroundQueue:^{
        _inForeground = YES;
        [self uploadEvents];
    }];
}

- (void)enterBackground {
    UIApplication *app = [self getSharedApplication];
    if (app == nil) {
        return;
    }
    
    // Stop uploading
    if (_uploadTaskID != UIBackgroundTaskInvalid) {
        [app endBackgroundTask:_uploadTaskID];
    }
    _uploadTaskID = [app beginBackgroundTaskWithExpirationHandler:^{
        //Took too long, manually stop
        if (_uploadTaskID != UIBackgroundTaskInvalid) {
            [app endBackgroundTask:_uploadTaskID];
            _uploadTaskID = UIBackgroundTaskInvalid;
        }
    }];
    [self runOnBackgroundQueue:^{
        _inForeground = NO;
        [self uploadEventsWithLimit:0];
    }];
}

#pragma mark - Configurations

- (void)setEventUploadMaxBatchSize:(int)eventUploadMaxBatchSize {
    _eventUploadMaxBatchSize = eventUploadMaxBatchSize;
    _backoffUploadBatchSize = eventUploadMaxBatchSize;
}

- (NSDictionary *)replaceWithEmptyJSON:(NSDictionary *)dictionary {
    return dictionary == nil ? [NSMutableDictionary dictionary] : dictionary;
}

- (BOOL)isArgument:(id)argument validType:(Class)class methodName:(NSString *)methodName {
    if ([argument isKindOfClass:class]) {
        return YES;
    } else {
        CLBLog(@"ERROR: Invalid type argument to method %@, expected %@, received %@, ", methodName, class, [argument class]);
        return NO;
    }
}

- (NSDate *)currentTime {
    return [NSDate date];
}

#pragma mark - Event log serialization

- (NSDictionary *)staticContext {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSMutableDictionary *infoDictionary = [[[NSBundle mainBundle] infoDictionary] mutableCopy];
    [infoDictionary addEntriesFromDictionary:[[NSBundle mainBundle] localizedInfoDictionary]];
    
    dict[kCLBApiKey] = _apiKey;
    dict[kCLBExecutionIdKey] = _executionId;
    dict[kCLBSDKOSKey] = kCLBOSName;
    dict[kCLBSDKVersionKey] = kCLBVersion;
    dict[kCLBOSBrandKey] = [_deviceInfo.osBrand lowercaseString];
    dict[kCLBOSVersionKey] = _deviceInfo.osVersion;
    dict[kCLBAppNameKey] = _appName;
    dict[kCLBAppPackageKey] = [NSBundle mainBundle].bundleIdentifier ?: @"";
    dict[kCLBAppVersionKey] = infoDictionary[@"CFBundleShortVersionString"] ?: @"";
    dict[kCLBBrandKey] = _deviceInfo.manufacturer;
    dict[kCLBModelKey] = _deviceInfo.model;
    dict[kCLBCarrierKey] = _deviceInfo.carrier;
    dict[kCLBScreenResolutionKey] = _deviceInfo.screenResolution;

    return dict;
}

- (NSDictionary *)liveContext {
    NSMutableDictionary *dict = [NSMutableDictionary new];
    
    NSMutableDictionary *infoDictionary = [[[NSBundle mainBundle] infoDictionary] mutableCopy];
    [infoDictionary addEntriesFromDictionary:[[NSBundle mainBundle] localizedInfoDictionary]];
    // FIXME: agregar estos valores a constantes
    
    ADClient *adClient = [ADClient sharedClient];
    if ([adClient respondsToSelector:@selector(requestAttributionDetailsWithBlock:)]) {
        // iOS 9+
        [adClient requestAttributionDetailsWithBlock:^(NSDictionary *attributionDetails, NSError *error) {
            if (!error) {
                dict[@"app_install_store"] = @"iad";
            }
        }];
    } else if ([adClient respondsToSelector:@selector(lookupAdConversionDetails:)]) {
        [adClient lookupAdConversionDetails:^(NSDate *appPurchaseDate, NSDate *iAdImpressionDate) {
            BOOL appInstallationWasAttributedToiAd = (iAdImpressionDate != nil);
            if (appInstallationWasAttributedToiAd) {
                // Referer type: iad
                dict[@"app_install_store"] = @"iad";
            }
        }];
    } else if ([adClient respondsToSelector:@selector(determineAppInstallationAttributionWithCompletionHandler:)]) {
        [adClient determineAppInstallationAttributionWithCompletionHandler:^(BOOL appInstallationWasAttributedToiAd) {
            // Referer type: ia
            if (appInstallationWasAttributedToiAd) {
                dict[@"app_install_store"] = @"iad";
            }
        }];
    }
    
    dict[kCLBIPKey] = [CLBDeviceInfo getIPAddress];
    dict[kCLBIDFAKey] = [CLBDeviceInfo getIDFA];
    dict[kCLBTimeZoneKey] = _deviceInfo.timezone;
    dict[kCLBDeviceCountryKey] = _deviceInfo.country;
    dict[kCLBLanguageKey] = _deviceInfo.language;
    // Optional values
    if (_country)
        dict[kCLBCountryKey] = _country;
    if (_email)
        dict[kCLBEmailKey] = [CLBUtils generateSHA1:_email];
    
    return dict;
}

- (void)setCookie:(NSString *)cookie {
    if (![cookie isEqualToString:_cookie]) {
        _cookie = cookie;
        [_dbHelper insertOrReplaceKeyValue:kCLBCookieKey value:cookie];
    }
}

- (void)setCountry:(NSString *)country {
    if (country && ![CLBUtils isValidCountryCode:country]) {
        @throw [NSException exceptionWithName:@"Bad Country Code" reason:@"Please use ISO 3166 country code." userInfo:nil];
    }
    _country = country;
    [_dbHelper insertOrReplaceKeyValue:kCLBCountryKey value:country];
}

- (void)setEmail:(NSString *)email {
    _email = email;
    [_dbHelper insertOrReplaceKeyValue:kCLBEmailKey value:email];
}


@end
