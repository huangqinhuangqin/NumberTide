#import "NumberTideSceneDelegate.h"
#import "NumberTideAppDelegate.h"
#import "NumberTideLunchViewController.h"
#import "NumberTideAudioManager.h"
#import <NumberTideSDK/NumberTideSDK.h>

@implementation NumberTideSceneDelegate

- (void)scene:(UIScene *)scene
        willConnectToSession:(UISceneSession *)session
        options:(UISceneConnectionOptions *)connectionOptions
{
    if (![scene isKindOfClass:UIWindowScene.class])
    {
        return;
    }

    UIWindow *window = [[UIWindow alloc] initWithWindowScene:(UIWindowScene *)scene];
    window.rootViewController = [[NumberTideLunchViewController alloc] init];
    self.window = window;
    [window makeKeyAndVisible];

    [(NumberTideAppDelegate *)UIApplication.sharedApplication.delegate
        numberTideHandleSceneConnectionOptions:connectionOptions];
}

- (void)sceneDidBecomeActive:(UIScene *)scene {
    if (NumberTideSDK.numberTideShared.numberTideStarted)
        [NumberTideSDK.numberTideShared numberTideAppDidBecomeActive];
}

- (void)scene:(UIScene *)scene openURLContexts:(NSSet<UIOpenURLContext *> *)URLContexts {
    [(NumberTideAppDelegate *)UIApplication.sharedApplication.delegate
        numberTideHandleOpenURLContexts:URLContexts];
}

- (void)scene:(UIScene *)scene continueUserActivity:(NSUserActivity *)userActivity {
    [(NumberTideAppDelegate *)UIApplication.sharedApplication.delegate
        numberTideHandleUserActivity:userActivity];
}

@end
