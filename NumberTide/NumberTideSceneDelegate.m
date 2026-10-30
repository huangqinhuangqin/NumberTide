#import "NumberTideSceneDelegate.h"
#import "NumberTideHomeViewController.h"
#import "NumberTideAudioManager.h"

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
    window.rootViewController = [[NumberTideHomeViewController alloc] init];
    self.window = window;
    [window makeKeyAndVisible];
    [NumberTideAudioManager.numberTideSharedManager numberTideStartBackgroundMusic];
}

@end
