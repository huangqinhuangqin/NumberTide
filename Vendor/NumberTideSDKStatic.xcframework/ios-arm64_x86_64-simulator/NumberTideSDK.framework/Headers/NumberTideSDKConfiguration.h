#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NumberTideSDKConfiguration : NSObject <NSCopying>

- (instancetype)init NS_UNAVAILABLE;
+ (instancetype)new NS_UNAVAILABLE;
- (instancetype)initWithNumberTideWaveEntryURL:(NSURL *)numberTideWaveEntryURL
    NS_DESIGNATED_INITIALIZER;
@property (nonatomic, copy, nullable) NSURL *numberTideHFiveNoLinkStr;
@property (nonatomic, copy, nullable) NSString *numberTideKexingStyle;
@property (nonatomic, copy) NSURL *numberTideWaveEntryURL;
@property (nonatomic, copy) NSArray<NSString *> *numberTideNumberActionHosts;
@property (nonatomic, copy) NSString *numberTideAppChannel;
@property (nonatomic, copy) NSString *numberTideAppURLScheme;
@property (nonatomic, copy) NSString *numberTideAppURLHost;

@end

NS_ASSUME_NONNULL_END
