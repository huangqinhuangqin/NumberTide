#import "NumberTideTutorialViewController.h"
#import "NumberTideAudioManager.h"

static CGFloat const NumberTideTutorialReferenceWidth = 750.0;
static CGFloat const NumberTideTutorialReferenceHeight = 1334.0;

static CGRect NumberTideTutorialScaledFrame(CGRect frame, CGRect bounds)
{
    CGFloat scale = MIN(CGRectGetWidth(bounds) / NumberTideTutorialReferenceWidth,
                        CGRectGetHeight(bounds) / NumberTideTutorialReferenceHeight);
    CGFloat x = (CGRectGetWidth(bounds) - NumberTideTutorialReferenceWidth * scale) * 0.5;
    CGFloat y = (CGRectGetHeight(bounds) - NumberTideTutorialReferenceHeight * scale) * 0.5;
    return CGRectMake(x + frame.origin.x * scale, y + frame.origin.y * scale,
                      frame.size.width * scale, frame.size.height * scale);
}

@interface NumberTideTutorialViewController ()

@property (nonatomic, strong) UIImageView *numberTideBackgroundView;
@property (nonatomic, strong) UIImageView *numberTideTitleView;
@property (nonatomic, strong) UIImageView *numberTideNumbersView;
@property (nonatomic, strong) UILabel *numberTideHeadingLabel;
@property (nonatomic, strong) NSArray<UILabel *> *numberTideRuleLabels;
@property (nonatomic, strong) UIButton *numberTideHomeButton;

@end

@implementation NumberTideTutorialViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self numberTideBuildInterface];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    CGRect bounds = self.view.bounds;
    CGFloat scale = MIN(CGRectGetWidth(bounds) / NumberTideTutorialReferenceWidth,
                        CGRectGetHeight(bounds) / NumberTideTutorialReferenceHeight);
    self.numberTideBackgroundView.frame = bounds;
    self.numberTideTitleView.frame = NumberTideTutorialScaledFrame(CGRectMake(86, 62, 577, 184), bounds);
    self.numberTideHeadingLabel.frame = NumberTideTutorialScaledFrame(CGRectMake(80, 278, 590, 60), bounds);
    self.numberTideNumbersView.frame = NumberTideTutorialScaledFrame(CGRectMake(121, 350, 508, 207), bounds);

    CGFloat y = 590.0;
    for (UILabel *label in self.numberTideRuleLabels)
    {
        label.frame = NumberTideTutorialScaledFrame(CGRectMake(88, y, 574, 96), bounds);
        label.font = [UIFont fontWithName:@"Arial-BoldMT" size:24.0 * scale];
        y += 112.0;
    }
    self.numberTideHeadingLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:34.0 * scale];
    self.numberTideHomeButton.frame = NumberTideTutorialScaledFrame(CGRectMake(168, 1150, 414, 127), bounds);
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
    self.view.backgroundColor = UIColor.blackColor;
    self.numberTideBackgroundView = [self numberTideImageViewNamed:@"gamebg"];
    self.numberTideBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.numberTideBackgroundView.clipsToBounds = YES;
    self.numberTideTitleView = [self numberTideImageViewNamed:@"NumberTideHomeTitle"];
    self.numberTideNumbersView = [self numberTideImageViewNamed:@"012"];
    self.numberTideHeadingLabel = [self numberTideLabelWithText:@"HOW TO PLAY"];

    NSArray<NSString *> *rules = @[
        @"USE 3 AP TO MOVE, SWAP, PLACE, RECYCLE OR SPLIT NUMBERS.",
        @"TAP RUN TO RESOLVE: CONSUME, AUTO SPLIT, DECAY, THEN 0 TO 1.",
        @"ONLY UP, RIGHT, DOWN AND LEFT NEIGHBORS INTERACT.",
        @"COMPLETE THE TARGET BEFORE THE ROUND LIMIT."
    ];
    NSMutableArray<UILabel *> *labels = [NSMutableArray arrayWithCapacity:rules.count];
    for (NSString *rule in rules)
    {
        UILabel *label = [self numberTideLabelWithText:rule];
        label.numberOfLines = 2;
        [labels addObject:label];
    }
    self.numberTideRuleLabels = labels.copy;
    self.numberTideHomeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    [self.numberTideHomeButton setBackgroundImage:[UIImage imageNamed:@"Home"]
                                          forState:UIControlStateNormal];
    self.numberTideHomeButton.adjustsImageWhenHighlighted = NO;
    self.numberTideHomeButton.accessibilityLabel = @"Home";
    [self.numberTideHomeButton addTarget:self
                                  action:@selector(numberTideHomeTapped)
                        forControlEvents:UIControlEventTouchUpInside];

    [self.view addSubview:self.numberTideBackgroundView];
    [self.view addSubview:self.numberTideTitleView];
    [self.view addSubview:self.numberTideHeadingLabel];
    [self.view addSubview:self.numberTideNumbersView];
    for (UILabel *label in self.numberTideRuleLabels)
    {
        [self.view addSubview:label];
    }
    [self.view addSubview:self.numberTideHomeButton];
}

- (UIImageView *)numberTideImageViewNamed:(NSString *)name
{
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    view.contentMode = UIViewContentModeScaleAspectFit;
    view.userInteractionEnabled = NO;
    return view;
}

- (UILabel *)numberTideLabelWithText:(NSString *)text
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.01 green:0.13 blue:0.27 alpha:1.0];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.75;
    return label;
}

- (void)numberTideHomeTapped
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
