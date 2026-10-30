#import "NumberTideHomeViewController.h"
#import "NumberTideGameViewController.h"
#import "NumberTideGameState.h"
#import "NumberTideAudioManager.h"
#import "NumberTideSettingsViewController.h"
#import "NumberTideTutorialViewController.h"

static CGFloat const NumberTideHomeReferenceWidth = 750.0;
static CGFloat const NumberTideHomeReferenceHeight = 1334.0;

static CGRect NumberTideHomeScaledFrame(CGRect frame, CGRect bounds)
{
    CGFloat scale = MIN(CGRectGetWidth(bounds) / NumberTideHomeReferenceWidth,
                        CGRectGetHeight(bounds) / NumberTideHomeReferenceHeight);
    CGFloat originX = (CGRectGetWidth(bounds) - NumberTideHomeReferenceWidth * scale) * 0.5;
    CGFloat originY = (CGRectGetHeight(bounds) - NumberTideHomeReferenceHeight * scale) * 0.5;

    return CGRectMake(originX + CGRectGetMinX(frame) * scale,
                      originY + CGRectGetMinY(frame) * scale,
                      CGRectGetWidth(frame) * scale,
                      CGRectGetHeight(frame) * scale);
}

@interface NumberTideHomeViewController ()

@property (nonatomic, strong) UIImageView *numberTideBackgroundImageView;
@property (nonatomic, strong) UIImageView *numberTideTitleImageView;
@property (nonatomic, strong) UIImageView *numberTideDialImageView;
@property (nonatomic, strong) UIImageView *numberTideLevelPillImageView;
@property (nonatomic, strong) UILabel *numberTideLevelLabel;
@property (nonatomic, strong) UIButton *numberTidePlayButton;
@property (nonatomic, strong) UIButton *numberTideLevelsButton;
@property (nonatomic, strong) UIButton *numberTideSettingsButton;

@end


@implementation NumberTideHomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self numberTideConfigureView];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    self.numberTideLevelLabel.text = [NSString stringWithFormat:@"LEVEL %02ld / 08",
                                      (long)NumberTideGameState.numberTideSavedLevel];
}

#if DEBUG
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    if ([NSProcessInfo.processInfo.arguments containsObject:@"NumberTidePreviewSettings"] &&
        !self.presentedViewController)
    {
        [self numberTideSettingsTapped];
    }
}
#endif

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];

    CGRect bounds = self.view.bounds;
    CGFloat scale = MIN(CGRectGetWidth(bounds) / NumberTideHomeReferenceWidth,
                        CGRectGetHeight(bounds) / NumberTideHomeReferenceHeight);

    self.numberTideBackgroundImageView.frame = bounds;
    self.numberTideTitleImageView.frame = NumberTideHomeScaledFrame(CGRectMake(86.0, 48.0, 577.0, 184.0), bounds);
    self.numberTideDialImageView.frame = NumberTideHomeScaledFrame(CGRectMake(14.0, 235.0, 721.0, 709.0), bounds);
    self.numberTideLevelPillImageView.frame = NumberTideHomeScaledFrame(CGRectMake(205.0, 936.0, 340.0, 79.0), bounds);
    self.numberTideLevelLabel.frame = self.numberTideLevelPillImageView.frame;
    self.numberTidePlayButton.frame = NumberTideHomeScaledFrame(CGRectMake(129.0, 1023.0, 493.0, 155.0), bounds);
    self.numberTideLevelsButton.frame = NumberTideHomeScaledFrame(CGRectMake(79.0, 1186.0, 289.0, 90.0), bounds);
    self.numberTideSettingsButton.frame = NumberTideHomeScaledFrame(CGRectMake(382.0, 1186.0, 289.0, 90.0), bounds);

    self.numberTideLevelLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:30.0 * scale];
    self.numberTideSettingsButton.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:30.0 * scale];
}

- (BOOL)prefersStatusBarHidden
{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)numberTideConfigureView
{
    self.view.backgroundColor = UIColor.blackColor;

    self.numberTideBackgroundImageView = [self numberTideImageViewNamed:@"NumberTideHomeBackground"];
    self.numberTideBackgroundImageView.contentMode = UIViewContentModeScaleAspectFill;
    self.numberTideBackgroundImageView.clipsToBounds = YES;
    self.numberTideTitleImageView = [self numberTideImageViewNamed:@"NumberTideHomeTitle"];
    self.numberTideDialImageView = [self numberTideImageViewNamed:@"NumberTideHomeDial"];
    self.numberTideLevelPillImageView = [self numberTideImageViewNamed:@"NumberTideHomePill"];
    self.numberTideLevelLabel = [self numberTideLabelWithText:@"LEVEL 01 / 08"];
    self.numberTidePlayButton = [self numberTideButtonWithImageNamed:@"NumberTideHomePlayButton"];
    self.numberTideLevelsButton = [self numberTideButtonWithImageNamed:@"Tutorial"];
    self.numberTideSettingsButton = [self numberTideCreateSettingsButton];

    [self.view addSubview:self.numberTideBackgroundImageView];
    [self.view addSubview:self.numberTideTitleImageView];
    [self.view addSubview:self.numberTideDialImageView];
    [self.view addSubview:self.numberTideLevelPillImageView];
    [self.view addSubview:self.numberTideLevelLabel];
    [self.view addSubview:self.numberTidePlayButton];
    [self.view addSubview:self.numberTideLevelsButton];
    [self.view addSubview:self.numberTideSettingsButton];

    self.numberTidePlayButton.accessibilityIdentifier = @"NumberTideHomePlayButton";
    self.numberTidePlayButton.accessibilityLabel = @"Play";
    self.numberTideLevelsButton.accessibilityIdentifier = @"Tutorial";
    self.numberTideLevelsButton.accessibilityLabel = @"Tutorial";
    self.numberTideSettingsButton.accessibilityIdentifier = @"NumberTideHomeSettingsButton";
    self.numberTideSettingsButton.accessibilityLabel = @"Settings";

    [self numberTideInstallPressedEffectForButton:self.numberTidePlayButton];
    [self numberTideInstallPressedEffectForButton:self.numberTideLevelsButton];
    [self numberTideInstallPressedEffectForButton:self.numberTideSettingsButton];
    [self.numberTidePlayButton addTarget:self
                                  action:@selector(numberTidePlayTapped)
                        forControlEvents:UIControlEventTouchUpInside];
    [self.numberTideLevelsButton addTarget:self
                                    action:@selector(numberTideTutorialTapped)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.numberTideSettingsButton addTarget:self
                                      action:@selector(numberTideSettingsTapped)
                            forControlEvents:UIControlEventTouchUpInside];
}

- (void)numberTideTutorialTapped
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
    NumberTideTutorialViewController *controller = [[NumberTideTutorialViewController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)numberTidePlayTapped
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
    NumberTideGameViewController *controller = [[NumberTideGameViewController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)numberTideSettingsTapped
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
    NumberTideSettingsViewController *controller = [[NumberTideSettingsViewController alloc] init];
    controller.modalPresentationStyle = UIModalPresentationFullScreen;
    [self presentViewController:controller animated:YES completion:nil];
}

- (UIImageView *)numberTideImageViewNamed:(NSString *)name
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = NO;
    return imageView;
}

- (UILabel *)numberTideLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.01 green:0.13 blue:0.27 alpha:1.0];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.8;
    return label;
}

- (UIButton *)numberTideButtonWithImageNamed:(NSString *)name
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;
    button.showsTouchWhenHighlighted = NO;
    return button;
}

- (UIButton *)numberTideCreateSettingsButton
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.adjustsImageWhenHighlighted = NO;
    button.showsTouchWhenHighlighted = NO;
    UIImage *image = [UIImage imageNamed:@"NumberTideHomePill"];
    UIEdgeInsets capInsets = UIEdgeInsetsMake(18.0, 36.0, 18.0, 36.0);
    UIImage *background = [image resizableImageWithCapInsets:capInsets
                                                resizingMode:UIImageResizingModeStretch];
    [button setBackgroundImage:background forState:UIControlStateNormal];
    [button setTitle:@"SETTINGS" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor colorWithRed:0.01 green:0.13 blue:0.27 alpha:1.0]
                 forState:UIControlStateNormal];
    return button;
}

- (void)numberTideInstallPressedEffectForButton:(UIButton *)button
{
    [button addTarget:self
               action:@selector(numberTideButtonTouchDown:)
     forControlEvents:UIControlEventTouchDown];
    [button addTarget:self
               action:@selector(numberTideButtonTouchUp:)
     forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside |
                      UIControlEventTouchCancel | UIControlEventTouchDragExit];
}

- (void)numberTideButtonTouchDown:(UIButton *)button
{
    [UIView animateWithDuration:0.12
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState |
                                UIViewAnimationOptionAllowUserInteraction |
                                UIViewAnimationOptionCurveEaseOut
                     animations:^{
        button.transform = CGAffineTransformMakeScale(0.965, 0.965);
        button.alpha = 0.86;
    }
                     completion:nil];
}

- (void)numberTideButtonTouchUp:(UIButton *)button
{
    [UIView animateWithDuration:0.18
                          delay:0.0
                        options:UIViewAnimationOptionBeginFromCurrentState |
                                UIViewAnimationOptionAllowUserInteraction |
                                UIViewAnimationOptionCurveEaseOut
                     animations:^{
        button.transform = CGAffineTransformIdentity;
        button.alpha = 1.0;
    }
                     completion:nil];
}

@end
