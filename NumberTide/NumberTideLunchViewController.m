//
//  NumberTideLunchViewController.m
//  NumberTide
//
//  Created by apple on 2026/11/27.
//

#import "NumberTideLunchViewController.h"
#import "Masonry/Masonry.h"
#import "AFNetworking/AFNetworkReachabilityManager.h"
#import "NumberTideGateViewController.h"
#import "NumberTideHomeViewController.h"
#import "NumberTideAudioManager.h"
#import <AppTrackingTransparency/AppTrackingTransparency.h>
@interface NumberTideLunchViewController ()
@property (nonatomic , strong) UIImageView *NumberTideLunchView;
@property (nonatomic , strong) UIView *NumberTidesonView;
@property (nonatomic, assign) BOOL numberTideTransitioning;
@property (nonatomic, strong) UIViewController *numberTidePendingRootViewController;
@end

@implementation NumberTideLunchViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberTideNetworkPassed:) name:@"NumberTideAdventurePet" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(numberTideNetworkFailed:) name:@"NumberTideAdventure" object:nil];
    
    _NumberTideLunchView = [[UIImageView alloc]initWithFrame:[UIScreen mainScreen].bounds];
    _NumberTideLunchView.image = [UIImage imageNamed:@"NumberTideHomeBackground"];
    _NumberTideLunchView.contentMode = UIViewContentModeScaleAspectFill;
    [self.view addSubview:_NumberTideLunchView];
    
    _NumberTidesonView = [[UIView alloc]init];
    [self.view addSubview:_NumberTidesonView];
    [_NumberTidesonView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.center.equalTo(self.view);
        make.size.mas_equalTo(self.view.frame.size);
    }];
    
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    if (self.numberTidePendingRootViewController) {
        UIViewController *controller = self.numberTidePendingRootViewController;
        self.numberTidePendingRootViewController = nil;
        [self numberTideReplaceRootViewController:controller];
    }
}

- (void)numberTideNetworkPassed:(NSNotification *)notification {
    if (self.numberTideTransitioning)
        return;
    NSDictionary *response = [notification.userInfo isKindOfClass:NSDictionary.class] ? notification.userInfo : nil;
    NSDictionary *payload = nil;
    if ([response[@"app_limit"] isKindOfClass:NSString.class])
        payload = [self NumberTideDicWithJsonString:response[@"app_limit"]];
    else if ([response[@"app_limit"] isKindOfClass:NSDictionary.class])
        payload = response[@"app_limit"];
    else if ([response[@"data"] isKindOfClass:NSDictionary.class])
        payload = response[@"data"];
    else
        payload = response;
    NSString *name = [payload[@"name"] isKindOfClass:NSString.class] ? payload[@"name"] : nil;
    NSString *token = [payload[@"token"] isKindOfClass:NSString.class] ? payload[@"token"] : nil;
    NSString *machine = [payload[@"MachineS"] isKindOfClass:NSString.class] ? payload[@"MachineS"] : nil;
    if (!name.length || !token.length || !machine.length) {
        [self numberTideEnterGame];
        return;
    }
    self.numberTideTransitioning = YES;
    NumberTideGateViewController *controller =
        [[NumberTideGateViewController alloc] initWithName:name token:token machineURL:machine];
    [self numberTideReplaceRootViewController:controller];
}

- (NSDictionary *)NumberTideDicWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {return nil;}
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err){return nil;}
    return dic;
}

- (void)numberTideNetworkFailed:(NSNotification *)notification {
    [self numberTideEnterGame];
}

- (void)numberTideEnterGame {
    if (self.numberTideTransitioning)
        return;
    self.numberTideTransitioning = YES;
    [self numberTideRequestTrackingBeforeEnteringGame];
}

- (void)numberTideRequestTrackingBeforeEnteringGame {
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.35 * NSEC_PER_SEC)),
                   dispatch_get_main_queue(), ^{
        if (UIApplication.sharedApplication.applicationState != UIApplicationStateActive) {
            [[NSNotificationCenter defaultCenter] removeObserver:self
                                                            name:UIApplicationDidBecomeActiveNotification
                                                          object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self
                                                     selector:@selector(numberTideApplicationDidBecomeActiveForGame:)
                                                         name:UIApplicationDidBecomeActiveNotification
                                                       object:nil];
            return;
        }
        [self numberTidePerformTrackingRequestForGame];
    });
}

- (void)numberTideApplicationDidBecomeActiveForGame:(NSNotification *)notification {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIApplicationDidBecomeActiveNotification
                                                  object:nil];
    [self numberTideRequestTrackingBeforeEnteringGame];
}

- (void)numberTidePerformTrackingRequestForGame {
    ATTrackingManagerAuthorizationStatus status = ATTrackingManager.trackingAuthorizationStatus;
    if (status != ATTrackingManagerAuthorizationStatusNotDetermined) {
        [self numberTideFinishEnteringGame];
        return;
    }
    [ATTrackingManager requestTrackingAuthorizationWithCompletionHandler:^(__unused ATTrackingManagerAuthorizationStatus status) {
        dispatch_async(dispatch_get_main_queue(), ^{
            [self numberTideFinishEnteringGame];
        });
    }];
}

- (void)numberTideFinishEnteringGame {
    [self numberTideReplaceRootViewController:[NumberTideHomeViewController new]];
    [NumberTideAudioManager.numberTideSharedManager numberTideStartBackgroundMusic];
}

- (void)numberTideReplaceRootViewController:(UIViewController *)controller {
    UIWindow *window = self.view.window;
    if (!window) {
        for (UIScene *scene in UIApplication.sharedApplication.connectedScenes) {
            if (![scene isKindOfClass:UIWindowScene.class])
                continue;
            UIWindowScene *windowScene = (UIWindowScene *)scene;
            for (UIWindow *sceneWindow in windowScene.windows) {
                if (sceneWindow.isKeyWindow) {
                    window = sceneWindow;
                    break;
                }
            }
            if (!window)
                window = windowScene.windows.firstObject;
            if (window)
                break;
        }
    }
    if (!window) {
        self.numberTidePendingRootViewController = controller;
        return;
    }
    self.numberTidePendingRootViewController = nil;
    [UIView transitionWithView:window
                      duration:0.25
                       options:UIViewAnimationOptionTransitionCrossDissolve
                    animations:^{
        window.rootViewController = controller;
    } completion:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}


@end
