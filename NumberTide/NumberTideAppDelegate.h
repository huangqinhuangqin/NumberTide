#import <UIKit/UIKit.h>

@interface NumberTideAppDelegate : UIResponder <UIApplicationDelegate>
- (BOOL)numberTideConfigureAirBridgeWithName:(NSString *)name token:(NSString *)token;
- (void)numberTideStartAirBridgeTracking;
- (void)numberTideActivateSDKServices;
- (void)numberTideHandleSceneConnectionOptions:(UISceneConnectionOptions *)options;
- (void)numberTideHandleOpenURLContexts:(NSSet<UIOpenURLContext *> *)contexts;
- (void)numberTideHandleUserActivity:(NSUserActivity *)activity;
@end
