#import "NumberTideAudioManager.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

static NSString * const NumberTideMusicVolumeKey = @"NumberTideMusicVolume";
static NSString * const NumberTideSoundVolumeKey = @"NumberTideSoundVolume";
static NSString * const NumberTideVibrationEnabledKey = @"NumberTideVibrationEnabled";

@interface NumberTideAudioManager ()

@property (nonatomic, strong) AVAudioPlayer *numberTideBackgroundPlayer;
@property (nonatomic, strong) AVAudioPlayer *numberTideEffectPlayer;

@end

@implementation NumberTideAudioManager

+ (instancetype)numberTideSharedManager
{
    static NumberTideAudioManager *manager;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        manager = [[self alloc] initNumberTidePrivate];
    });
    return manager;
}

- (instancetype)init
{
    return NumberTideAudioManager.numberTideSharedManager;
}

- (instancetype)initNumberTidePrivate
{
    self = [super init];
    if (self)
    {
        [NSUserDefaults.standardUserDefaults registerDefaults:@{
            NumberTideMusicVolumeKey : @0.5,
            NumberTideSoundVolumeKey : @0.8,
            NumberTideVibrationEnabledKey : @YES
        }];
        _numberTideMusicVolume = [NSUserDefaults.standardUserDefaults floatForKey:NumberTideMusicVolumeKey];
        _numberTideSoundVolume = [NSUserDefaults.standardUserDefaults floatForKey:NumberTideSoundVolumeKey];
        _numberTideVibrationEnabled = [NSUserDefaults.standardUserDefaults boolForKey:NumberTideVibrationEnabledKey];
        AVAudioSession *session = AVAudioSession.sharedInstance;
        [session setCategory:AVAudioSessionCategoryAmbient error:nil];
        [session setActive:YES error:nil];
    }
    return self;
} 

- (void)setNumberTideMusicVolume:(float)musicVolume
{
    _numberTideMusicVolume = MAX(0.0f, MIN(1.0f, musicVolume));
    self.numberTideBackgroundPlayer.volume = _numberTideMusicVolume;
    [NSUserDefaults.standardUserDefaults setFloat:_numberTideMusicVolume
                                            forKey:NumberTideMusicVolumeKey];
}

- (void)setNumberTideSoundVolume:(float)soundVolume
{
    _numberTideSoundVolume = MAX(0.0f, MIN(1.0f, soundVolume));
    [NSUserDefaults.standardUserDefaults setFloat:_numberTideSoundVolume
                                            forKey:NumberTideSoundVolumeKey];
}

- (void)setNumberTideVibrationEnabled:(BOOL)vibrationEnabled
{
    _numberTideVibrationEnabled = vibrationEnabled;
    [NSUserDefaults.standardUserDefaults setBool:vibrationEnabled forKey:NumberTideVibrationEnabledKey];
}

- (void)numberTideResetSettings
{
    NSUserDefaults *defaults = NSUserDefaults.standardUserDefaults;
    [defaults removeObjectForKey:NumberTideMusicVolumeKey];
    [defaults removeObjectForKey:NumberTideSoundVolumeKey];
    [defaults removeObjectForKey:NumberTideVibrationEnabledKey];
    _numberTideMusicVolume = 0.5f;
    _numberTideSoundVolume = 0.8f;
    _numberTideVibrationEnabled = YES;
    self.numberTideBackgroundPlayer.volume = _numberTideMusicVolume;
}

- (void)numberTideStartBackgroundMusic
{
    if (!self.numberTideBackgroundPlayer)
    {
        NSURL *url = [NSBundle.mainBundle URLForResource:@"NUMBER_TIDE_BGM" withExtension:@"wav"];
        self.numberTideBackgroundPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
        self.numberTideBackgroundPlayer.numberOfLoops = -1;
        [self.numberTideBackgroundPlayer prepareToPlay];
    }
    self.numberTideBackgroundPlayer.volume = self.numberTideMusicVolume;
    if (!self.numberTideBackgroundPlayer.isPlaying)
    {
        [self.numberTideBackgroundPlayer play];
    }
}

- (void)numberTidePlayClick
{
    [self numberTidePlayEffectNamed:@"CLICK"];
    if (self.isNumberTideVibrationEnabled)
    {
        UIImpactFeedbackGenerator *feedback = [[UIImpactFeedbackGenerator alloc]
            initWithStyle:UIImpactFeedbackStyleLight];
        [feedback impactOccurred];
    }
}

- (void)numberTidePlayLevelComplete
{
    [self numberTidePlayEffectNamed:@"LEVEL_COMPLETE"];
    if (self.isNumberTideVibrationEnabled)
    {
        [[[UINotificationFeedbackGenerator alloc] init] notificationOccurred:UINotificationFeedbackTypeSuccess];
    }
}

- (void)numberTidePlayLevelFailed
{
    [self numberTidePlayEffectNamed:@"LEVEL_FAILED"];
    if (self.isNumberTideVibrationEnabled)
    {
        [[[UINotificationFeedbackGenerator alloc] init] notificationOccurred:UINotificationFeedbackTypeError];
    }
}

- (void)numberTidePlayEffectNamed:(NSString *)name
{
    if (self.numberTideSoundVolume <= 0.0f)
    {
        return;
    }
    NSURL *url = [NSBundle.mainBundle URLForResource:name withExtension:@"wav"];
    self.numberTideEffectPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    self.numberTideEffectPlayer.volume = self.numberTideSoundVolume;
    [self.numberTideEffectPlayer play];
}

@end
