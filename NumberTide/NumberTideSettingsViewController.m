#import "NumberTideSettingsViewController.h"
#import "NumberTideAudioManager.h"
#import "NumberTideGameState.h"

static CGFloat const NumberTideSettingsReferenceWidth = 750.0;
static CGFloat const NumberTideSettingsReferenceHeight = 1334.0;

static CGRect NumberTideSettingsScaledFrame(CGRect frame, CGRect bounds)
{
    CGFloat scale = MIN(CGRectGetWidth(bounds) / NumberTideSettingsReferenceWidth,
                        CGRectGetHeight(bounds) / NumberTideSettingsReferenceHeight);
    CGFloat x = (CGRectGetWidth(bounds) - NumberTideSettingsReferenceWidth * scale) * 0.5;
    CGFloat y = (CGRectGetHeight(bounds) - NumberTideSettingsReferenceHeight * scale) * 0.5;
    return CGRectMake(x + frame.origin.x * scale, y + frame.origin.y * scale,
                      frame.size.width * scale, frame.size.height * scale);
}

@interface NumberTideVolumeControl : UIControl

@property (nonatomic) float numberTideValue;
@property (nonatomic, strong) UIImageView *numberTideArcView;
@property (nonatomic, strong) UIImageView *numberTideKnobView;
@property (nonatomic, strong) UIImageView *numberTideIndicatorView;
@property (nonatomic, strong) UIImageView *numberTideLabelView;

- (instancetype)initWithNumberTideLabelImageName:(NSString *)name;

@end

@implementation NumberTideVolumeControl

- (instancetype)initWithNumberTideLabelImageName:(NSString *)name
{
    self = [super initWithFrame:CGRectZero];
    if (self)
    {
        self.accessibilityLabel = name.uppercaseString;
        self.accessibilityTraits = UIAccessibilityTraitAdjustable;
        self.numberTideArcView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"hu"]];
        self.numberTideArcView.contentMode = UIViewContentModeScaleAspectFit;
        self.numberTideKnobView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"circle"]];
        self.numberTideKnobView.contentMode = UIViewContentModeScaleAspectFit;
        self.numberTideIndicatorView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"nid"]];
        self.numberTideIndicatorView.contentMode = UIViewContentModeScaleAspectFit;
        self.numberTideLabelView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
        self.numberTideLabelView.contentMode = UIViewContentModeScaleAspectFit;
        [self addSubview:self.numberTideArcView];
        [self addSubview:self.numberTideKnobView];
        [self addSubview:self.numberTideIndicatorView];
        [self addSubview:self.numberTideLabelView];

        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self
                                                                             action:@selector(numberTideHandleGesture:)];
        UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                              action:@selector(numberTideHandleGesture:)];
        [self addGestureRecognizer:pan];
        [self addGestureRecognizer:tap];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    CGFloat scale = CGRectGetWidth(self.bounds) / 300.0;
    self.numberTideArcView.frame = CGRectMake(8 * scale, 8 * scale, 284 * scale, 113 * scale);
    self.numberTideKnobView.frame = CGRectMake(32 * scale, 54 * scale, 237 * scale, 232 * scale);
    self.numberTideLabelView.frame = CGRectMake(27 * scale, 270 * scale, 247 * scale, 79 * scale);
    [self numberTideUpdateIndicator];
}

- (void)setNumberTideValue:(float)value
{
    _numberTideValue = MAX(0.0f, MIN(1.0f, value));
    self.accessibilityValue = [NSString stringWithFormat:@"%ld%%",
                                (long)lroundf(_numberTideValue * 100.0f)];
    [self setNeedsLayout];
}

- (void)numberTideUpdateIndicator
{
    CGFloat scale = CGRectGetWidth(self.bounds) / 300.0;
    CGPoint center = CGPointMake(150 * scale, 170 * scale);
    CGFloat angle = (-54.0 + 108.0 * self.numberTideValue) * M_PI / 180.0;
    CGFloat distance = 70 * scale;
    CGPoint position = CGPointMake(center.x + sin(angle) * distance,
                                   center.y - cos(angle) * distance);
    self.numberTideIndicatorView.bounds = CGRectMake(0, 0, 24 * scale, 59 * scale);
    self.numberTideIndicatorView.center = position;
    self.numberTideIndicatorView.transform = CGAffineTransformMakeRotation(angle);
}

- (void)numberTideHandleGesture:(UIGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self];
    CGFloat scale = CGRectGetWidth(self.bounds) / 300.0;
    CGPoint center = CGPointMake(150 * scale, 170 * scale);
    CGFloat angle = atan2(point.x - center.x, center.y - point.y) * 180.0 / M_PI;
    self.numberTideValue = (angle + 54.0) / 108.0;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    if (gesture.state == UIGestureRecognizerStateEnded)
    {
        [self sendActionsForControlEvents:UIControlEventEditingDidEnd];
    }
}

- (void)accessibilityIncrement
{
    self.numberTideValue += 0.1f;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

- (void)accessibilityDecrement
{
    self.numberTideValue -= 0.1f;
    [self sendActionsForControlEvents:UIControlEventValueChanged];
}

@end

@interface NumberTideSettingsViewController ()

@property (nonatomic, strong) UIImageView *numberTideBackgroundView;
@property (nonatomic, strong) UIImageView *numberTideTitleView;
@property (nonatomic, strong) UIImageView *numberTidePanelView;
@property (nonatomic, strong) UIButton *numberTideBackButton;
@property (nonatomic, strong) NumberTideVolumeControl *numberTideMusicControl;
@property (nonatomic, strong) NumberTideVolumeControl *numberTideSoundControl;
@property (nonatomic, strong) UIImageView *numberTideVibrationView;
@property (nonatomic, strong) UIButton *numberTideVibrationButton;
@property (nonatomic, strong) UIButton *numberTideClearDataButton;
@property (nonatomic, strong) UIButton *numberTideDoneButton;

@end

@implementation NumberTideSettingsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.blackColor;
    [self numberTideBuildInterface];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;
    self.numberTideBackgroundView.frame = bounds;
    self.numberTideBackButton.frame = NumberTideSettingsScaledFrame(CGRectMake(25, 28, 110, 106), bounds);
    self.numberTideTitleView.frame = NumberTideSettingsScaledFrame(CGRectMake(129, 91, 492, 169), bounds);
    self.numberTidePanelView.frame = NumberTideSettingsScaledFrame(CGRectMake(27, 291, 695, 823), bounds);
    self.numberTideMusicControl.frame = NumberTideSettingsScaledFrame(CGRectMake(68, 357, 300, 350), bounds);
    self.numberTideSoundControl.frame = NumberTideSettingsScaledFrame(CGRectMake(382, 357, 300, 350), bounds);
    self.numberTideVibrationView.frame = NumberTideSettingsScaledFrame(CGRectMake(71, 731, 608, 136), bounds);
    self.numberTideVibrationButton.frame = NumberTideSettingsScaledFrame(CGRectMake(423, 751, 228, 96), bounds);
    self.numberTideClearDataButton.frame = NumberTideSettingsScaledFrame(CGRectMake(215, 886, 320, 89), bounds);
    self.numberTideDoneButton.frame = NumberTideSettingsScaledFrame(CGRectMake(92, 998, 566, 154), bounds);
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)numberTideBuildInterface
{
    self.numberTideBackgroundView = [self numberTideImageViewNamed:@"setbg"];
    self.numberTideBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.numberTideBackgroundView.clipsToBounds = YES;
    self.numberTideTitleView = [self numberTideImageViewNamed:@"settitle"];
    self.numberTidePanelView = [self numberTideImageViewNamed:@"mid"];
    self.numberTideBackButton = [self numberTideButtonWithImageNamed:@"back"];
    self.numberTideMusicControl = [[NumberTideVolumeControl alloc] initWithNumberTideLabelImageName:@"music"];
    self.numberTideSoundControl = [[NumberTideVolumeControl alloc] initWithNumberTideLabelImageName:@"sound"];
    self.numberTideVibrationView = [self numberTideImageViewNamed:@"vinration"];
    self.numberTideVibrationButton = [self numberTideButtonWithImageNamed:@"on"];
    self.numberTideClearDataButton = [self numberTideButtonWithImageNamed:@"cleardata"];
    self.numberTideDoneButton = [self numberTideButtonWithImageNamed:@"done"];

    for (UIView *view in @[self.numberTideBackgroundView, self.numberTideTitleView, self.numberTidePanelView, self.numberTideBackButton,
                           self.numberTideMusicControl, self.numberTideSoundControl, self.numberTideVibrationView,
                           self.numberTideVibrationButton, self.numberTideClearDataButton, self.numberTideDoneButton])
    {
        [self.view addSubview:view];
    }
    NumberTideAudioManager *audio = NumberTideAudioManager.numberTideSharedManager;
    self.numberTideMusicControl.numberTideValue = audio.numberTideMusicVolume;
    self.numberTideSoundControl.numberTideValue = audio.numberTideSoundVolume;
    [self numberTideUpdateVibrationButton];

    [self.numberTideMusicControl addTarget:self action:@selector(numberTideMusicVolumeChanged:)
                forControlEvents:UIControlEventValueChanged];
    [self.numberTideSoundControl addTarget:self action:@selector(numberTideSoundVolumeChanged:)
                forControlEvents:UIControlEventValueChanged];
    [self.numberTideSoundControl addTarget:self action:@selector(numberTideSoundVolumeEditingEnded:)
                forControlEvents:UIControlEventEditingDidEnd];
    [self.numberTideBackButton addTarget:self action:@selector(numberTideCloseTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.numberTideDoneButton addTarget:self action:@selector(numberTideCloseTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.numberTideVibrationButton addTarget:self action:@selector(numberTideVibrationTapped) forControlEvents:UIControlEventTouchUpInside];
    [self.numberTideClearDataButton addTarget:self action:@selector(numberTideClearDataTapped) forControlEvents:UIControlEventTouchUpInside];
}

- (void)numberTideMusicVolumeChanged:(NumberTideVolumeControl *)control
{
    NumberTideAudioManager.numberTideSharedManager.numberTideMusicVolume =
        control.numberTideValue;
}

- (void)numberTideSoundVolumeChanged:(NumberTideVolumeControl *)control
{
    NumberTideAudioManager.numberTideSharedManager.numberTideSoundVolume =
        control.numberTideValue;
}

- (void)numberTideSoundVolumeEditingEnded:(NumberTideVolumeControl *)control
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
}

- (void)numberTideVibrationTapped
{
    NumberTideAudioManager *audio = NumberTideAudioManager.numberTideSharedManager;
    audio.numberTideVibrationEnabled = !audio.isNumberTideVibrationEnabled;
    [self numberTideUpdateVibrationButton];
    [audio numberTidePlayClick];
}

- (void)numberTideClearDataTapped
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"CLEAR DATA"
                                                                     message:@"Reset saved progress and settings?"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL"
                                                style:UIAlertActionStyleCancel
                                              handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"CLEAR"
                                                style:UIAlertActionStyleDestructive
                                              handler:^(__unused UIAlertAction *action) {
        [NumberTideGameState numberTideClearSavedData];
        [NumberTideAudioManager.numberTideSharedManager numberTideResetSettings];
        [weakSelf numberTideUpdateSettingsAfterClearData];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)numberTideUpdateSettingsAfterClearData
{
    NumberTideAudioManager *audio = NumberTideAudioManager.numberTideSharedManager;
    self.numberTideMusicControl.numberTideValue = audio.numberTideMusicVolume;
    self.numberTideSoundControl.numberTideValue = audio.numberTideSoundVolume;
    [self numberTideUpdateVibrationButton];
    [audio numberTidePlayClick];
    [UIView animateWithDuration:0.12 animations:^{
        self.numberTideClearDataButton.alpha = 0.55;
    }
                     completion:^(__unused BOOL finished) {
        [UIView animateWithDuration:0.18 animations:^{
            self.numberTideClearDataButton.alpha = 1.0;
        }];
    }];
}

- (void)numberTideCloseTapped
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)numberTideUpdateVibrationButton
{
    NumberTideAudioManager *audio = NumberTideAudioManager.numberTideSharedManager;
    NSString *imageName = audio.isNumberTideVibrationEnabled ? @"on" : @"off";
    [self.numberTideVibrationButton setBackgroundImage:[UIImage imageNamed:imageName] forState:UIControlStateNormal];
    self.numberTideVibrationButton.accessibilityLabel = @"Vibration";
    self.numberTideVibrationButton.accessibilityValue =
        audio.isNumberTideVibrationEnabled ? @"On" : @"Off";
}

- (UIImageView *)numberTideImageViewNamed:(NSString *)name
{
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.userInteractionEnabled = NO;
    return view;
}

- (UIButton *)numberTideButtonWithImageNamed:(NSString *)name
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(numberTideButtonDown:) forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(numberTideButtonUp:) forControlEvents:UIControlEventTouchUpInside |
        UIControlEventTouchUpOutside | UIControlEventTouchCancel | UIControlEventTouchDragExit];
    return button;
}

- (void)numberTideButtonDown:(UIButton *)button
{
    [UIView animateWithDuration:0.1 animations:^{
        button.transform = CGAffineTransformMakeScale(0.965, 0.965);
    }];
}

- (void)numberTideButtonUp:(UIButton *)button
{
    [UIView animateWithDuration:0.16 animations:^{
        button.transform = CGAffineTransformIdentity;
    }];
}

@end
