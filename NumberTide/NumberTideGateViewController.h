#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface NumberTideGateViewController : UIViewController
- (instancetype)initWithName:(NSString *)name
                       token:(NSString *)token
                  machineURL:(NSString *)machineURL;
- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
@end

NS_ASSUME_NONNULL_END
