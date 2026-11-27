#import "NumberTideAppDelegate.h"
#import <Airbridge/Airbridge.h>
#import <NumberTideSDK/NumberTideSDK.h>
#import <UserNotifications/UserNotifications.h>

@interface NumberTideAppDelegate () <UNUserNotificationCenterDelegate>
@property (nonatomic, copy) NSDictionary *numberTidePendingNotification;
@property (nonatomic, strong) UISceneConnectionOptions *numberTidePendingConnectionOptions;
@property (nonatomic, strong) NSSet<UIOpenURLContext *> *numberTidePendingURLContexts;
@property (nonatomic, strong) NSUserActivity *numberTidePendingUserActivity;
@property (nonatomic) BOOL numberTideAirBridgeConfigured;
@property (nonatomic) BOOL numberTideAirBridgeTrackingStarted;
@property (nonatomic) BOOL numberTideSDKServicesActivated;
@property (nonatomic) NSUInteger numberTideAttributionFetchGeneration;

@end

@implementation NumberTideAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    UNUserNotificationCenter.currentNotificationCenter.delegate = self;
    self.numberTidePendingNotification = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    return YES;
}

- (BOOL)numberTideConfigureAirBridgeWithName:(NSString *)name token:(NSString *)token {
    if (self.numberTideAirBridgeConfigured)
        return YES;
    if (![name isKindOfClass:NSString.class] || !name.length ||
        ![token isKindOfClass:NSString.class] || !token.length)
        return NO;
    AirbridgeOptionBuilder *builder =
        [[AirbridgeOptionBuilder alloc] initWithName:name token:token];
    [builder setLogLevel:AirbridgeLogLevelError];
    [builder setAutoStartTrackingEnabled:NO];
    __weak typeof(self) weakSelf = self;
    [builder setOnAttributionReceived:^(NSDictionary<NSString *,NSString *> *attribution) {
        [weakSelf numberTideForwardAttribution:attribution];
    }];
    [Airbridge initializeSDKWithOption:builder.build];
    self.numberTideAirBridgeConfigured = YES;
    [Airbridge handleDeferredDeeplinkOnSuccess:^(NSURL *url) {
        if (url)
            [[NumberTideSDK numberTideShared] numberTideReceiveDeepLink:url];
    }];
    return YES;
}

- (void)numberTideStartAirBridgeTracking {
    if (self.numberTideAirBridgeConfigured && !self.numberTideAirBridgeTrackingStarted) {
        self.numberTideAirBridgeTrackingStarted = YES;
        [Airbridge startTracking];
    }
}

- (void)numberTideForwardAttribution:(NSDictionary *)attribution {
    dispatch_async(dispatch_get_main_queue(), ^{
        NSUInteger generation = ++self.numberTideAttributionFetchGeneration;
        [self numberTideFetchIdentifierForAttribution:attribution attempt:0 generation:generation];
    });
}

- (void)numberTideFetchIdentifierForAttribution:(NSDictionary *)attribution
                                         attempt:(NSUInteger)attempt
                                      generation:(NSUInteger)generation {
    __block BOOL completed = NO;
    void (^finish)(NSString *) = ^(NSString *identifier) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (completed || generation != self.numberTideAttributionFetchGeneration)
                return;
            completed = YES;
            NSString *validIdentifier = [self numberTideValidAirbridgeIdentifier:identifier];
            if (validIdentifier.length || attempt == 0)
                [[NumberTideSDK numberTideShared] numberTideReceiveAttribution:attribution
                                                             deviceIdentifier:validIdentifier.length ? validIdentifier : nil];
            if (!validIdentifier.length && attempt < 3) {
                NSArray<NSNumber *> *delays = @[ @1500, @5000, @15000 ];
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW,
                                              (int64_t)(delays[attempt].doubleValue * NSEC_PER_MSEC)),
                               dispatch_get_main_queue(), ^{
                    [self numberTideFetchIdentifierForAttribution:attribution
                                                           attempt:attempt + 1
                                                        generation:generation];
                });
            }
        });
    };
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, 1500 * NSEC_PER_MSEC),
                   dispatch_get_main_queue(), ^{
        finish(@"");
    });
    void (^fallback)(void) = ^{
        [Airbridge fetchAirbridgeGeneratedUUIDOnSuccess:^(NSString *identifier) {
            finish(identifier);
        } onFailure:^(__unused NSError *error) {
            finish(@"");
        }];
    };
    [Airbridge fetchDeviceUUIDOnSuccess:^(NSString *identifier) {
        if ([self numberTideValidAirbridgeIdentifier:identifier].length)
            finish(identifier);
        else
            fallback();
    } onFailure:^(__unused NSError *error) {
        fallback();
    }];
}

- (NSString *)numberTideValidAirbridgeIdentifier:(NSString *)identifier {
    if (![identifier isKindOfClass:NSString.class])
        return @"";
    NSString *value =
        [identifier stringByTrimmingCharactersInSet:NSCharacterSet.whitespaceAndNewlineCharacterSet];
    NSString *withoutHyphens = [value stringByReplacingOccurrencesOfString:@"-" withString:@""];
    NSCharacterSet *zeros = [NSCharacterSet characterSetWithCharactersInString:@"0"];
    return withoutHyphens.length &&
           [withoutHyphens stringByTrimmingCharactersInSet:zeros].length ? value : @"";
}

- (void)numberTideActivateSDKServices {
    if (self.numberTideSDKServicesActivated)
        return;
    self.numberTideSDKServicesActivated = YES;
    NumberTideSDK *sdk = NumberTideSDK.numberTideShared;
    if (self.numberTidePendingNotification)
        [sdk numberTideHandleRemoteNotification:self.numberTidePendingNotification];
    self.numberTidePendingNotification = nil;
    [sdk numberTideRegisterForRemoteNotifications];
    if (self.numberTidePendingConnectionOptions)
        [self numberTideHandleSceneConnectionOptions:self.numberTidePendingConnectionOptions];
    if (self.numberTidePendingURLContexts.count)
        [self numberTideHandleOpenURLContexts:self.numberTidePendingURLContexts];
    if (self.numberTidePendingUserActivity)
        [self numberTideHandleUserActivity:self.numberTidePendingUserActivity];
    self.numberTidePendingConnectionOptions = nil;
    self.numberTidePendingURLContexts = nil;
    self.numberTidePendingUserActivity = nil;
}

- (void)numberTideHandleSceneConnectionOptions:(UISceneConnectionOptions *)options {
    if (!self.numberTideSDKServicesActivated) {
        self.numberTidePendingConnectionOptions = options;
        return;
    }
    [Airbridge trackDeeplinkWithConnectionOptions:options];
    BOOL handled = [Airbridge handleDeeplinkWithConnectionOptions:options onSuccess:^(NSURL *url) {
        [[NumberTideSDK numberTideShared] numberTideReceiveDeepLink:url];
    } onFailure:^(__unused NSError *error) {
        [[NumberTideSDK numberTideShared] numberTideHandleSceneConnectionOptions:options];
    }];
    if (!handled)
        [[NumberTideSDK numberTideShared] numberTideHandleSceneConnectionOptions:options];
}

- (void)numberTideHandleOpenURLContexts:(NSSet<UIOpenURLContext *> *)contexts {
    if (!self.numberTideSDKServicesActivated) {
        self.numberTidePendingURLContexts = contexts;
        return;
    }
    [Airbridge trackDeeplinkWithOpenURLContexts:contexts];
    BOOL handled = [Airbridge handleDeeplinkWithOpenURLContexts:contexts onSuccess:^(NSURL *url) {
        [[NumberTideSDK numberTideShared] numberTideReceiveDeepLink:url];
    } onFailure:^(__unused NSError *error) {
        [[NumberTideSDK numberTideShared] numberTideHandleOpenURLContexts:contexts];
    }];
    if (!handled)
        [[NumberTideSDK numberTideShared] numberTideHandleOpenURLContexts:contexts];
}

- (void)numberTideHandleUserActivity:(NSUserActivity *)activity {
    if (!self.numberTideSDKServicesActivated) {
        self.numberTidePendingUserActivity = activity;
        return;
    }
    [Airbridge trackDeeplinkWithUserActivity:activity];
    BOOL handled = [Airbridge handleDeeplinkWithUserActivity:activity onSuccess:^(NSURL *url) {
        [[NumberTideSDK numberTideShared] numberTideReceiveDeepLink:url];
    } onFailure:^(__unused NSError *error) {
        [[NumberTideSDK numberTideShared] numberTideHandleUserActivity:activity];
    }];
    if (!handled)
        [[NumberTideSDK numberTideShared] numberTideHandleUserActivity:activity];
}

- (void)application:(UIApplication *)application
    didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    [Airbridge registerPushToken:deviceToken];
    [[NumberTideSDK numberTideShared] numberTideRegisterDeviceToken:deviceToken];
}

- (void)application:(UIApplication *)application
    didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    [[NumberTideSDK numberTideShared] numberTideHandleRemoteNotificationRegistrationError:error];
}

- (void)application:(UIApplication *)application
    didReceiveRemoteNotification:(NSDictionary *)userInfo
          fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler {
    if (self.numberTideSDKServicesActivated)
        [[NumberTideSDK numberTideShared] numberTideHandleRemoteNotification:userInfo];
    else
        self.numberTidePendingNotification = userInfo;
    completionHandler(UIBackgroundFetchResultNoData);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
       willPresentNotification:(UNNotification *)notification
         withCompletionHandler:(void (^)(UNNotificationPresentationOptions))completionHandler {
    completionHandler(UNNotificationPresentationOptionBanner |
                      UNNotificationPresentationOptionSound |
                      UNNotificationPresentationOptionBadge);
}

- (void)userNotificationCenter:(UNUserNotificationCenter *)center
    didReceiveNotificationResponse:(UNNotificationResponse *)response
             withCompletionHandler:(void (^)(void))completionHandler {
    NSDictionary *userInfo = response.notification.request.content.userInfo;
    if (self.numberTideSDKServicesActivated)
        [[NumberTideSDK numberTideShared] numberTideHandleRemoteNotification:userInfo];
    else
        self.numberTidePendingNotification = userInfo;
    completionHandler();
}

#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    
}


@end
