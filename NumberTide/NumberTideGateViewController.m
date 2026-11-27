#import "NumberTideGateViewController.h"
#import "NumberTideAppDelegate.h"
#import "NumberTideHomeViewController.h"
#import "NumberTideWyViewController.h"
#import <AdSupport/AdSupport.h>
#import <AppTrackingTransparency/AppTrackingTransparency.h>
#import <NumberTideSDK/NumberTideSDK.h>

@interface NumberTideGateViewController ()
@property (nonatomic, copy) NSString *numberTideName;
@property (nonatomic, copy) NSString *numberTideToken;
@property (nonatomic, copy) NSString *numberTideMachineURL;
@property (nonatomic, assign) BOOL numberTidePreparationStarted;
@property (nonatomic, strong) UIActivityIndicatorView *numberTideIndicator;
@end

@implementation NumberTideGateViewController

- (instancetype)initWithName:(NSString *)name token:(NSString *)token machineURL:(NSString *)machineURL {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        _numberTideName = [name copy];
        _numberTideToken = [token copy];
        _numberTideMachineURL = [machineURL copy];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    UIImageView *background = [[UIImageView alloc] initWithFrame:self.view.bounds];
    background.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    background.image = [UIImage imageNamed:@"NumberTideHomeBackground"];
    background.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:background];
    UIActivityIndicatorView *indicator =
        [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleLarge];
    indicator.color = UIColor.whiteColor;
    indicator.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:indicator];
    [NSLayoutConstraint activateConstraints:@[
        [indicator.centerXAnchor constraintEqualToAnchor:self.view.centerXAnchor],
        [indicator.centerYAnchor constraintEqualToAnchor:self.view.centerYAnchor]
    ]];
    [indicator startAnimating];
    self.numberTideIndicator = indicator;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.numberTidePreparationStarted)
        return;
    self.numberTidePreparationStarted = YES;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        [self numberTideBeginPreparation];
    });
}

- (void)numberTideBeginPreparation {
    NumberTideAppDelegate *delegate = (NumberTideAppDelegate *)UIApplication.sharedApplication.delegate;
    if (![delegate numberTideConfigureAirBridgeWithName:self.numberTideName token:self.numberTideToken]) {
        [self numberTideEnterGame];
        return;
    }
    [self numberTideRequestTrackingAndContinue];
}

- (void)numberTideRequestTrackingAndContinue {
    ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
    if (status != ATTrackingManagerAuthorizationStatusNotDetermined) {
        [self numberTideStoreIdentifiersForStatus:status];
        return;
    }
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self numberTideStoreIdentifiersForStatus:status];
        });
    }];
}

- (void)numberTideStoreIdentifiersForStatus:(ATTrackingManagerAuthorizationStatus)status {
    [self numberTidePersistIdentifiersForStatus:status];
    [self numberTideInitializeSDK];
}

- (void)numberTidePersistIdentifiersForStatus:(ATTrackingManagerAuthorizationStatus)status {
    NSString *zero = @"00000000-0000-0000-0000-000000000000";
    NSString *idfa = zero;
    if (status == ATTrackingManagerAuthorizationStatusAuthorized) {
        NSString *value = ASIdentifierManager.sharedManager.advertisingIdentifier.UUIDString ?: @"";
        if (value.length && ![value isEqualToString:zero])
            idfa = value;
    }
    NSString *idfv = UIDevice.currentDevice.identifierForVendor.UUIDString ?: @"";
    if ([idfv isEqualToString:zero])
        idfv = @"";
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults setObject:idfa forKey:@"IDFA"];
    [defaults setObject:idfv forKey:@"IDFV"];
    [defaults synchronize];
}

- (void)numberTideInitializeSDK {
    NSURL *machineURL = [NSURL URLWithString:self.numberTideMachineURL];
    if (!machineURL) {
        [self numberTideEnterGame];
        return;
    }
    NumberTideSDKConfiguration *configuration =
        [[NumberTideSDKConfiguration alloc] initWithNumberTideWaveEntryURL:machineURL];
    configuration.numberTideAppURLScheme = @"NumberTide";
    
    NSError *error = nil;
    NumberTideSDK *sdk = NumberTideSDK.numberTideShared;
    if (![sdk numberTideStartWithConfiguration:configuration error:&error]) {
        [self numberTideEnterGame];
        return;
    }
    [(NumberTideAppDelegate *)UIApplication.sharedApplication.delegate
        numberTideStartAirBridgeTracking];
    [sdk numberTideRefreshDeviceIdentifiers];
    [sdk numberTidePrepareWithCompletion:^(BOOL success, NSError *prepareError) {
        dispatch_async(dispatch_get_main_queue(), ^{
            if (!success) {
                [self numberTideEnterGame];
                return;
            }
            [(NumberTideAppDelegate *)UIApplication.sharedApplication.delegate
                numberTideActivateSDKServices];
            NumberTideWyViewController *controller = [NumberTideWyViewController new];
            [self numberTideReplaceRootViewController:controller];
        });
    }];
}

- (void)numberTideEnterGame {
    ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
    if (status == ATTrackingManagerAuthorizationStatusNotDetermined) {
        [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(ATTrackingManagerAuthorizationStatus resolvedStatus) {
            dispatch_async(dispatch_get_main_queue(), ^{
                [self numberTidePersistIdentifiersForStatus:resolvedStatus];
                [self numberTideFinishEnteringGame];
            });
        }];
        return;
    }
    [self numberTidePersistIdentifiersForStatus:status];
    [self numberTideFinishEnteringGame];
}

- (void)numberTideFinishEnteringGame {
    [self numberTideReplaceRootViewController:[NumberTideHomeViewController new]];
}

- (void)numberTideReplaceRootViewController:(UIViewController *)controller {
    UIWindow *window = self.view.window;
    if (!window)
        return;
    [UIView transitionWithView:window duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{ window.rootViewController = controller; }
                    completion:nil];
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

@end
