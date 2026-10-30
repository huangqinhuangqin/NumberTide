#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NumberTideAudioManager : NSObject

@property (nonatomic) float numberTideMusicVolume;
@property (nonatomic) float numberTideSoundVolume;
@property (nonatomic, getter=isNumberTideVibrationEnabled) BOOL numberTideVibrationEnabled;

+ (instancetype)numberTideSharedManager;
- (void)numberTideStartBackgroundMusic;
- (void)numberTidePlayClick;
- (void)numberTidePlayLevelComplete;
- (void)numberTidePlayLevelFailed;
- (void)numberTideResetSettings;

@end

NS_ASSUME_NONNULL_END
