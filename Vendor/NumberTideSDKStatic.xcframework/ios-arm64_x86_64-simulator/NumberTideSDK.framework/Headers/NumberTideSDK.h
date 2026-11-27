#import <NumberTideSDK/NumberTideSDKConfiguration.h>
#import <UIKit/UIKit.h>
#import <WebKit/WebKit.h>

NS_ASSUME_NONNULL_BEGIN

FOUNDATION_EXPORT NSErrorDomain const NumberTideSDKErrorDomain;

typedef NS_ERROR_ENUM(NumberTideSDKErrorDomain, NumberTideSDKErrorCode) {
    NumberTideSDKErrorCodeInvalidConfiguration = 1,
    NumberTideSDKErrorCodeAlreadyStarted = 2,
    NumberTideSDKErrorCodeNotStarted = 3,
    NumberTideSDKErrorCodeWebViewAlreadyAttached = 4,
    NumberTideSDKErrorCodeRemoteConfigurationUnavailable = 5
};

@class NumberTideSDK;

@protocol NumberTideSDKDelegate <NSObject>
@optional
- (void)numberTideSDK:(NumberTideSDK *)sdk
               openURL:(NSURL *)url
         preferredMode:(NSString *)preferredMode
            completion:(void (^)(BOOL success, NSString *actualMode))completion;
- (void)numberTideSDK:(NumberTideSDK *)sdk
    requestMediaFromSource:(NSString *)source
                completion:(void (^)(NSData *_Nullable data, NSString *_Nullable filename,
                                     BOOL cancelled))completion;
- (void)numberTideSDK:(NumberTideSDK *)sdk
          saveImageData:(NSData *)data
       suggestedFilename:(NSString *)filename
              completion:(void (^)(BOOL success))completion;
@end

@interface NumberTideSDK : NSObject

+ (instancetype)numberTideShared;
- (BOOL)numberTideStartWithConfiguration:(NumberTideSDKConfiguration *)configuration
                                   error:(NSError *_Nullable *_Nullable)error;
- (void)numberTidePrepareWithCompletion:(void (^)(BOOL success, NSError *_Nullable error))completion;
- (void)numberTideRefreshDeviceIdentifiers;
- (void)numberTideAttachToWebView:(WKWebView *)webView
                       completion:(void (^)(BOOL success, NSError *_Nullable error))completion;
- (void)numberTideDetachFromWebView:(WKWebView *)webView;
- (void)numberTideWebViewDidStartNavigation:(WKWebView *)webView;
- (void)numberTideWebViewDidFinishNavigation:(WKWebView *)webView;
- (void)numberTideRegisterForRemoteNotifications;
- (void)numberTideRegisterDeviceToken:(NSData *)deviceToken;
- (void)numberTideHandleRemoteNotification:(NSDictionary *)userInfo;
- (void)numberTideHandleRemoteNotificationRegistrationError:(NSError *)error;
- (void)numberTideHandleSceneConnectionOptions:(UISceneConnectionOptions *)options;
- (void)numberTideHandleOpenURL:(NSURL *)url;
- (void)numberTideHandleOpenURLContexts:(NSSet<UIOpenURLContext *> *)contexts;
- (void)numberTideHandleUserActivity:(NSUserActivity *)activity;
- (void)numberTideReceiveAttribution:(NSDictionary *)attribution
                    deviceIdentifier:(nullable NSString *)deviceIdentifier;
- (void)numberTideReceiveDeepLink:(NSURL *)url;
- (void)numberTideAppDidBecomeActive;

@property (nonatomic, copy, readonly, nullable) NumberTideSDKConfiguration *numberTideConfiguration;
@property (nonatomic, assign, readonly, getter=numberTideIsStarted) BOOL numberTideStarted;
@property (nonatomic, weak, nullable) id<NumberTideSDKDelegate> numberTideDelegate;

@end

NS_ASSUME_NONNULL_END
