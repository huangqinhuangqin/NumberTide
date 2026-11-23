#import "NumberTideAppDelegate.h"
#import <AdSupport/AdSupport.h>
#import <AirBridge/AirBridge.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>

static NSString * const NumberTideAirBridgeAppToken = @"6391a6cd3c1c40bc8b3bed4d5f80c2b7";

@interface NumberTideAppDelegate ()

@property (nonatomic) BOOL NumberTideTrackingStarted;
@property (nonatomic) BOOL NumberTideRequestedTrackingAuthorization;

@end

@implementation NumberTideAppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [AirBridge setAutoStartTrackingEnabled:NO];
    [AirBridge getInstance:NumberTideAirBridgeAppToken appName:[[[@"m" stringByAppendingString:@"b"] stringByAppendingString:@"000"] stringByAppendingString:@"152"] withLaunchOptions:launchOptions];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(NumberTideApplicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
    return YES;
}

- (void)NumberTideApplicationDidBecomeActive:(NSNotification *)NumberTideNotification {
    ATTrackingManagerAuthorizationStatus NumberTideStatus = ATTrackingManager.trackingAuthorizationStatus;
    if (NumberTideStatus == ATTrackingManagerAuthorizationStatusNotDetermined) {
        if (self.NumberTideRequestedTrackingAuthorization) {
            return;
        }
        self.NumberTideRequestedTrackingAuthorization = YES;
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus NumberTideRequestedStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self NumberTideHandleTrackingStatus:NumberTideRequestedStatus];
            });
        }];
        return;
    }
    [self NumberTideHandleTrackingStatus:NumberTideStatus];
}

- (void)NumberTideHandleTrackingStatus:(ATTrackingManagerAuthorizationStatus)NumberTideStatus {
    if (NumberTideStatus == ATTrackingManagerAuthorizationStatusAuthorized) {
        NSUUID *NumberTideIdentifier = ASIdentifierManager.sharedManager.advertisingIdentifier;
        NSString *NumberTideIDFA = NumberTideIdentifier.UUIDString;
        if (![NumberTideIDFA isEqualToString:@"00000000-0000-0000-0000-000000000000"]) {
            self.NumberTideIDFA = NumberTideIDFA;
        }
    } else {
        self.NumberTideIDFA = nil;
    }

    if (!self.NumberTideTrackingStarted) {
        self.NumberTideTrackingStarted = YES;
        [AirBridge startTracking];
    }
}


#pragma mark - UISceneSession lifecycle


- (UISceneConfiguration *)application:(UIApplication *)application configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration" sessionRole:connectingSceneSession.role];
}


- (void)application:(UIApplication *)application didDiscardSceneSessions:(NSSet<UISceneSession *> *)sceneSessions {
    
}


@end
