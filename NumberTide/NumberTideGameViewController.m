#import "NumberTideGameViewController.h"
#import "NumberTideGameState.h"
#import "NumberTideAudioManager.h"

static CGFloat const NumberTideGameReferenceWidth = 750.0;
static CGFloat const NumberTideGameReferenceHeight = 1334.0;
static NSInteger const NumberTideGameNoSelection = -1;

static CGRect NumberTideGameScaledFrame(CGRect frame, CGRect bounds)
{
    CGFloat scale = MIN(CGRectGetWidth(bounds) / NumberTideGameReferenceWidth,
                        CGRectGetHeight(bounds) / NumberTideGameReferenceHeight);
    CGFloat originX = (CGRectGetWidth(bounds) - NumberTideGameReferenceWidth * scale) * 0.5;
    CGFloat originY = (CGRectGetHeight(bounds) - NumberTideGameReferenceHeight * scale) * 0.5;
    return CGRectMake(originX + CGRectGetMinX(frame) * scale,
                      originY + CGRectGetMinY(frame) * scale,
                      CGRectGetWidth(frame) * scale,
                      CGRectGetHeight(frame) * scale);
}

@interface NumberTideGameViewController ()

@property (nonatomic, strong) NumberTideGameState *numberTideState;
@property (nonatomic, strong) UIImageView *numberTideBackgroundView;
@property (nonatomic, strong) UIImageView *numberTideTitleView;
@property (nonatomic, strong) UIImageView *numberTideTargetView;
@property (nonatomic, strong) UIImageView *numberTideBoardView;
@property (nonatomic, strong) UIImageView *numberTideNextView;
@property (nonatomic, strong) UIImageView *numberTideInventoryView;
@property (nonatomic, strong) UIImageView *numberTideProgressRingView;
@property (nonatomic, strong) UIImageView *numberTideNextTileView;
@property (nonatomic, strong) UIImageView *numberTideSplitView;
@property (nonatomic, strong) UILabel *numberTideLevelLabel;
@property (nonatomic, strong) UILabel *numberTideRoundLabel;
@property (nonatomic, strong) UILabel *numberTideTargetLabel;
@property (nonatomic, strong) UILabel *numberTideRuleLabel;
@property (nonatomic, strong) UILabel *numberTideProgressLabel;
@property (nonatomic, strong) UILabel *numberTideNextLabel;
@property (nonatomic, strong) UILabel *numberTideNextValueLabel;
@property (nonatomic, strong) UILabel *numberTideNextDetailLabel;
@property (nonatomic, strong) UIButton *numberTideExitButton;
@property (nonatomic, strong) UIButton *numberTideUndoButton;
@property (nonatomic, strong) UIButton *numberTideRunButton;
@property (nonatomic, strong) UIButton *numberTideResetButton;
@property (nonatomic, strong) UIButton *numberTideSplitButton;
@property (nonatomic, strong) UIView *numberTideSplitOverlayView;
@property (nonatomic, strong) UIImageView *numberTideSplitPanelView;
@property (nonatomic, strong) UIImageView *numberTideSplitNumberView;
@property (nonatomic, strong) UIImageView *numberTideSplitPathView;
@property (nonatomic, strong) UILabel *numberTideSplitNumberLabel;
@property (nonatomic, strong) UILabel *numberTideSplitHintLabel;
@property (nonatomic, strong) UIButton *numberTideSplitCancelButton;
@property (nonatomic, strong) UIButton *numberTideSplitConfirmButton;
@property (nonatomic, strong) NSMutableArray<UIButton *> *numberTideSplitChoiceButtons;
@property (nonatomic, strong) NSMutableArray<UIButton *> *numberTideBoardButtons;
@property (nonatomic, strong) NSMutableArray<UIButton *> *numberTideInventoryButtons;
@property (nonatomic, strong) NSMutableArray<UILabel *> *numberTideInventoryCountLabels;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *numberTideActionLights;
@property (nonatomic) NSInteger numberTideSelectedBoardIndex;
@property (nonatomic) NSInteger numberTideSelectedInventoryValue;
@property (nonatomic) NSInteger numberTideDragSourceIndex;
@property (nonatomic) NSInteger numberTideSplitSourceIndex;
@property (nonatomic) BOOL numberTideShowingResult;
@property (nonatomic, strong) UIView *numberTideResultView;
@property (nonatomic, strong) UIImageView *numberTideResultBackgroundView;
@property (nonatomic, strong) UIImageView *numberTideResultTitleView;
@property (nonatomic, strong) UIImageView *numberTideResultSubtitleView;
@property (nonatomic, strong) UILabel *numberTideResultSubtitleLabel;
@property (nonatomic, strong) UIImageView *numberTideResultCycleView;
@property (nonatomic, strong) UIImageView *numberTideResultInfoView;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *numberTideResultTileViews;
@property (nonatomic, strong) NSMutableArray<UILabel *> *numberTideResultValueLabels;
@property (nonatomic, strong) NSMutableArray<UIImageView *> *numberTideResultStatViews;
@property (nonatomic, strong) NSMutableArray<UILabel *> *numberTideResultStatTitleLabels;
@property (nonatomic, strong) NSMutableArray<UILabel *> *numberTideResultStatValueLabels;
@property (nonatomic, strong) UILabel *numberTideResultReasonLabel;
@property (nonatomic, strong) UIButton *numberTideResultPrimaryButton;
@property (nonatomic, strong) UIButton *numberTideResultHomeButton;
@property (nonatomic, strong) UIButton *numberTideResultRetryButton;
@property (nonatomic) BOOL numberTideResultIsSuccess;

@end


@implementation NumberTideGameViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.numberTideState = [[NumberTideGameState alloc]
        initWithNumberTideLevel:NumberTideGameState.numberTideSavedLevel];
    self.numberTideSelectedBoardIndex = NumberTideGameNoSelection;
    self.numberTideSelectedInventoryValue = NumberTideGameNoSelection;
    self.numberTideDragSourceIndex = NumberTideGameNoSelection;
    [self numberTideBuildInterface];
    [self numberTideRefreshInterface];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    [self numberTideLayoutInterface];
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
    self.numberTideTitleView = [self numberTideImageViewNamed:@"gametitle"];
    self.numberTideTargetView = [self numberTideImageViewNamed:@"NumberLoop"];
    self.numberTideBoardView = [self numberTideImageViewNamed:@"QI"];
    self.numberTideNextView = [self numberTideImageViewNamed:@"YL"];
    self.numberTideInventoryView = [self numberTideImageViewNamed:@"Kc"];
    self.numberTideProgressRingView = [self numberTideImageViewNamed:@"Poss"];
    self.numberTideNextTileView = [self numberTideImageViewNamed:@"YLFK"];

    NSArray *images = @[self.numberTideBackgroundView, self.numberTideTitleView,
                        self.numberTideTargetView, self.numberTideBoardView,
                        self.numberTideNextView, self.numberTideInventoryView,
                        self.numberTideProgressRingView, self.numberTideNextTileView];
    for (UIImageView *imageView in images)
    {
        [self.view addSubview:imageView];
    }

    self.numberTideLevelLabel = [self numberTideLabelWithText:@"LEVEL 01" size:26.0];
    self.numberTideRoundLabel = [self numberTideLabelWithText:@"ROUND 01/12" size:25.0];
    self.numberTideTargetLabel = [self numberTideLabelWithText:@"EMPTY SPACE" size:24.0];
    self.numberTideRuleLabel = [self numberTideLabelWithText:@"0 TO 1 x3" size:43.0];
    self.numberTideProgressLabel = [self numberTideLabelWithText:@"0/3" size:35.0];
    self.numberTideNextLabel = [self numberTideLabelWithText:@"NEXT" size:15.0];
    self.numberTideNextValueLabel = [self numberTideLabelWithText:@"-" size:22.0];
    self.numberTideNextDetailLabel = [self numberTideLabelWithText:@"NO CHANGE" size:12.0];
    NSArray *labels = @[self.numberTideLevelLabel, self.numberTideRoundLabel,
                        self.numberTideTargetLabel, self.numberTideRuleLabel,
                        self.numberTideProgressLabel, self.numberTideNextLabel,
                        self.numberTideNextValueLabel,
                        self.numberTideNextDetailLabel];
    for (UILabel *label in labels)
    {
        [self.view addSubview:label];
    }

    self.numberTideExitButton = [self numberTideButtonWithImageNamed:@"exit"];
    self.numberTideUndoButton = [self numberTideButtonWithImageNamed:@"back"];
    self.numberTideRunButton = [self numberTideButtonWithImageNamed:@"run"];
    self.numberTideResetButton = [self numberTideButtonWithImageNamed:@"reset"];
    [self.numberTideExitButton addTarget:self action:@selector(numberTideExitTapped)
                         forControlEvents:UIControlEventTouchUpInside];
    [self.numberTideUndoButton addTarget:self action:@selector(numberTideUndoTapped)
                         forControlEvents:UIControlEventTouchUpInside];
    [self.numberTideRunButton addTarget:self action:@selector(numberTideRunTapped)
                        forControlEvents:UIControlEventTouchUpInside];
    [self.numberTideResetButton addTarget:self action:@selector(numberTideResetTapped)
                          forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:self.numberTideExitButton];
    [self.view addSubview:self.numberTideUndoButton];
    [self.view addSubview:self.numberTideRunButton];
    [self.view addSubview:self.numberTideResetButton];
    self.numberTideUndoButton.accessibilityLabel = @"Undo";
    self.numberTideRunButton.accessibilityLabel = @"Run";
    self.numberTideResetButton.accessibilityLabel = @"Restart level";

    [self numberTideBuildBoard];
    [self numberTideBuildInventory];
    [self numberTideBuildActionLights];
}

- (void)numberTideBuildBoard
{
    self.numberTideBoardButtons = [NSMutableArray arrayWithCapacity:25];
    for (NSInteger index = 0; index < 25; index++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = index;
        button.adjustsImageWhenHighlighted = NO;
        button.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:42.0];
        [button setTitleColor:[self numberTideInkColor] forState:UIControlStateNormal];
        [button addTarget:self action:@selector(numberTideBoardTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [self.numberTideBoardButtons addObject:button];
    }

    UILongPressGestureRecognizer *drag = [[UILongPressGestureRecognizer alloc]
        initWithTarget:self action:@selector(numberTideBoardDragged:)];
    drag.minimumPressDuration = 0.18;
    [self.view addGestureRecognizer:drag];

    self.numberTideSplitButton = [self numberTideButtonWithImageNamed:@"SPLIT"];
    [self.numberTideSplitButton addTarget:self action:@selector(numberTideSplitTapped)
                           forControlEvents:UIControlEventTouchUpInside];
    self.numberTideSplitButton.hidden = YES;
    [self.view addSubview:self.numberTideSplitButton];
}

- (void)numberTideBuildInventory
{
    NSArray<NSNumber *> *values = self.numberTideState.numberTideInventoryValues;
    self.numberTideInventoryButtons = [NSMutableArray arrayWithCapacity:values.count];
    self.numberTideInventoryCountLabels = [NSMutableArray arrayWithCapacity:values.count];
    for (NSNumber *value in values)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.tag = value.integerValue;
        button.adjustsImageWhenHighlighted = NO;
        [button setBackgroundImage:[UIImage imageNamed:@"FK"] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"chooseing"] forState:UIControlStateSelected];
        [button setTitle:value.stringValue forState:UIControlStateNormal];
        [button setTitleColor:[self numberTideInkColor] forState:UIControlStateNormal];
        button.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:39.0];
        [button addTarget:self action:@selector(numberTideInventoryTapped:)
         forControlEvents:UIControlEventTouchUpInside];
        [self.view addSubview:button];
        [self.numberTideInventoryButtons addObject:button];

        UILabel *count = [self numberTideLabelWithText:@"x0" size:22.0];
        [self.view addSubview:count];
        [self.numberTideInventoryCountLabels addObject:count];
    }
}

- (void)numberTideBuildActionLights
{
    self.numberTideActionLights = [NSMutableArray arrayWithCapacity:3];
    for (NSInteger index = 0; index < 3; index++)
    {
        UIImageView *light = [self numberTideImageViewNamed:@"Greenlight"];
        [self.view addSubview:light];
        [self.numberTideActionLights addObject:light];
    }
}

- (void)numberTideLayoutInterface
{
    CGRect bounds = self.view.bounds;
    CGFloat scale = MIN(CGRectGetWidth(bounds) / NumberTideGameReferenceWidth,
                        CGRectGetHeight(bounds) / NumberTideGameReferenceHeight);
    self.numberTideBackgroundView.frame = bounds;
    self.numberTideTitleView.frame = NumberTideGameScaledFrame(CGRectMake(43, 24, 226, 156), bounds);
    self.numberTideLevelLabel.frame = NumberTideGameScaledFrame(CGRectMake(57, 140, 190, 39), bounds);
    self.numberTideRoundLabel.frame = NumberTideGameScaledFrame(CGRectMake(445, 59, 198, 57), bounds);
    self.numberTideExitButton.frame = NumberTideGameScaledFrame(CGRectMake(655, 48, 76, 76), bounds);
    self.numberTideTargetView.frame = NumberTideGameScaledFrame(CGRectMake(75, 145, 608, 203), bounds);
    self.numberTideTargetLabel.frame = NumberTideGameScaledFrame(CGRectMake(245, 178, 265, 31), bounds);
    self.numberTideRuleLabel.frame = NumberTideGameScaledFrame(CGRectMake(260, 211, 230, 54), bounds);
    self.numberTideProgressRingView.frame = NumberTideGameScaledFrame(CGRectMake(532, 184, 116, 118), bounds);
    self.numberTideProgressLabel.frame = NumberTideGameScaledFrame(CGRectMake(540, 213, 100, 57), bounds);
    self.numberTideBoardView.frame = NumberTideGameScaledFrame(CGRectMake(43, 310, 626, 660), bounds);
    self.numberTideNextView.frame = NumberTideGameScaledFrame(CGRectMake(663, 420, 87, 440), bounds);
    self.numberTideNextLabel.frame = NumberTideGameScaledFrame(CGRectMake(674, 450, 65, 21), bounds);
    self.numberTideNextTileView.frame = NumberTideGameScaledFrame(CGRectMake(676, 521, 62, 59), bounds);
    self.numberTideNextValueLabel.frame = NumberTideGameScaledFrame(CGRectMake(678, 526, 58, 48), bounds);
    self.numberTideNextDetailLabel.frame = NumberTideGameScaledFrame(CGRectMake(672, 586, 70, 36), bounds);
    self.numberTideInventoryView.frame = NumberTideGameScaledFrame(CGRectMake(24, 1024, 705, 151), bounds);
    self.numberTideUndoButton.frame = NumberTideGameScaledFrame(CGRectMake(66, 1196, 117, 112), bounds);
    self.numberTideRunButton.frame = NumberTideGameScaledFrame(CGRectMake(202, 1195, 346, 116), bounds);
    self.numberTideResetButton.frame = NumberTideGameScaledFrame(CGRectMake(568, 1196, 116, 112), bounds);

    for (NSInteger index = 0; index < self.numberTideBoardButtons.count; index++)
    {
        NSInteger row = index / 5;
        NSInteger column = index % 5;
        CGRect frame = CGRectMake(74 + column * 114, 398 + row * 110, 107, 102);
        UIButton *button = self.numberTideBoardButtons[index];
        button.frame = NumberTideGameScaledFrame(frame, bounds);
        button.titleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:42.0 * scale];
    }

    for (NSInteger index = 0; index < self.numberTideInventoryButtons.count; index++)
    {
        CGFloat x = 86 + index * 119;
        self.numberTideInventoryButtons[index].frame = NumberTideGameScaledFrame(CGRectMake(x, 1040, 102, 100), bounds);
        self.numberTideInventoryCountLabels[index].frame = NumberTideGameScaledFrame(CGRectMake(x, 1141, 102, 30), bounds);
        self.numberTideInventoryButtons[index].titleLabel.font =
            [UIFont fontWithName:@"Arial-BoldMT" size:39.0 * scale];
    }

    for (NSInteger index = 0; index < 3; index++)
    {
        self.numberTideActionLights[index].frame =
            NumberTideGameScaledFrame(CGRectMake(300 + index * 54, 327, 31, 30), bounds);
    }
    [self numberTideLayoutSplitButton];
    [self numberTideLayoutSplitOverlay];
    [self numberTideLayoutResult];
    for (UILabel *label in @[self.numberTideLevelLabel, self.numberTideRoundLabel,
                             self.numberTideTargetLabel, self.numberTideRuleLabel,
                             self.numberTideProgressLabel, self.numberTideNextLabel,
                             self.numberTideNextValueLabel,
                             self.numberTideNextDetailLabel])
    {
        label.font = [label.font fontWithSize:label.tag * scale];
    }
}

- (void)numberTideRefreshInterface
{
    self.numberTideLevelLabel.text = [NSString stringWithFormat:@"LEVEL %02ld",
                                      (long)self.numberTideState.numberTideLevel];
    self.numberTideTargetLabel.text = self.numberTideState.numberTideTargetTitle;
    self.numberTideRuleLabel.text = self.numberTideState.numberTideTargetRule;
    NSArray *board = self.numberTideState.numberTideBoard;
    for (NSInteger index = 0; index < self.numberTideBoardButtons.count; index++)
    {
        UIButton *button = self.numberTideBoardButtons[index];
        id value = board[index];
        BOOL occupied = value != NSNull.null;
        [button setTitle:occupied ? [value stringValue] : nil forState:UIControlStateNormal];
        [button setBackgroundImage:occupied ? [UIImage imageNamed:@"FK"] : nil
                          forState:UIControlStateNormal];
        [button setBackgroundImage:occupied ? [UIImage imageNamed:@"chooseing"] : nil
                          forState:UIControlStateSelected];
        button.selected = index == self.numberTideSelectedBoardIndex;
    }

    NSArray<NSNumber *> *values = self.numberTideState.numberTideInventoryValues;
    for (NSInteger index = 0; index < values.count; index++)
    {
        NSNumber *value = values[index];
        UIButton *button = self.numberTideInventoryButtons[index];
        button.tag = value.integerValue;
        [button setTitle:value.stringValue forState:UIControlStateNormal];
        NSInteger count = [self.numberTideState.numberTideInventory[value] integerValue];
        self.numberTideInventoryCountLabels[index].text = [NSString stringWithFormat:@"x%ld", (long)count];
        button.selected = value.integerValue == self.numberTideSelectedInventoryValue;
        button.enabled = count > 0;
        button.alpha = count > 0 ? 1.0 : 0.45;
    }

    for (NSInteger index = 0; index < self.numberTideActionLights.count; index++)
    {
        self.numberTideActionLights[index].hidden = index >= self.numberTideState.numberTideActionsLeft;
    }
    NSInteger round = MIN(self.numberTideState.numberTideRound,
                          self.numberTideState.numberTideRoundLimit);
    self.numberTideRoundLabel.text = [NSString stringWithFormat:@"ROUND %02ld/%02ld",
                                      (long)round,
                                      (long)self.numberTideState.numberTideRoundLimit];
    self.numberTideProgressLabel.text = self.numberTideState.numberTideProgressText;
    self.numberTideNextValueLabel.text = self.numberTideState.numberTideNextValueText;
    self.numberTideNextDetailLabel.text = self.numberTideState.numberTideNextDetailText;
    self.numberTideSplitButton.hidden =
        ![self.numberTideState numberTideCanSplitIndex:self.numberTideSelectedBoardIndex];
    [self numberTideLayoutSplitButton];
}

- (void)numberTideBoardTapped:(UIButton *)button
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
    NSInteger index = button.tag;
    id value = self.numberTideState.numberTideBoard[index];
    if (self.numberTideSelectedInventoryValue != NumberTideGameNoSelection && value == NSNull.null)
    {
        [self.numberTideState numberTidePlaceValue:self.numberTideSelectedInventoryValue atIndex:index];
        self.numberTideSelectedInventoryValue = NumberTideGameNoSelection;
        self.numberTideSelectedBoardIndex = NumberTideGameNoSelection;
    }
    else if (self.numberTideSelectedBoardIndex != NumberTideGameNoSelection &&
             index != self.numberTideSelectedBoardIndex)
    {
        if ([self.numberTideState numberTideMoveFromIndex:self.numberTideSelectedBoardIndex toIndex:index])
        {
            self.numberTideSelectedBoardIndex = NumberTideGameNoSelection;
        }
    }
    else
    {
        self.numberTideSelectedInventoryValue = NumberTideGameNoSelection;
        self.numberTideSelectedBoardIndex = value == NSNull.null ? NumberTideGameNoSelection : index;
    }
    [self numberTideRefreshInterface];
}

- (void)numberTideInventoryTapped:(UIButton *)button
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
    self.numberTideSelectedBoardIndex = NumberTideGameNoSelection;
    self.numberTideSelectedInventoryValue =
        self.numberTideSelectedInventoryValue == button.tag ? NumberTideGameNoSelection : button.tag;
    [self numberTideRefreshInterface];
}

- (void)numberTideBoardDragged:(UILongPressGestureRecognizer *)gesture
{
    CGPoint point = [gesture locationInView:self.view];
    NSInteger index = [self numberTideBoardIndexAtPoint:point];
    if (gesture.state == UIGestureRecognizerStateBegan)
    {
        if (index != NumberTideGameNoSelection && self.numberTideState.numberTideBoard[index] != NSNull.null)
        {
            self.numberTideDragSourceIndex = index;
            self.numberTideSelectedBoardIndex = index;
            [self numberTideRefreshInterface];
        }
    }
    else if (gesture.state == UIGestureRecognizerStateEnded)
    {
        if (self.numberTideDragSourceIndex != NumberTideGameNoSelection &&
            index != NumberTideGameNoSelection && index != self.numberTideDragSourceIndex)
        {
            [self.numberTideState numberTideMoveFromIndex:self.numberTideDragSourceIndex toIndex:index];
        }
        self.numberTideDragSourceIndex = NumberTideGameNoSelection;
        self.numberTideSelectedBoardIndex = NumberTideGameNoSelection;
        [self numberTideRefreshInterface];
    }
}

- (void)numberTideSplitTapped
{
    NSInteger index = self.numberTideSelectedBoardIndex;
    NSInteger value = [self.numberTideState.numberTideBoard[index] integerValue];
    self.numberTideSplitSourceIndex = index;
    [self numberTideBuildSplitOverlayForValue:value];
    [self numberTideLayoutSplitOverlay];
    self.numberTideSplitButton.hidden = YES;
    self.numberTideSplitOverlayView.alpha = 0.0;
    [UIView animateWithDuration:0.2 animations:^{
        self.numberTideSplitOverlayView.alpha = 1.0;
    }];
}

- (void)numberTideBuildSplitOverlayForValue:(NSInteger)value
{
    [self.numberTideSplitOverlayView removeFromSuperview];

    UIView *overlay = [[UIView alloc] initWithFrame:self.view.bounds];
    overlay.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.48];
    [self.view addSubview:overlay];
    self.numberTideSplitOverlayView = overlay;

    self.numberTideSplitPanelView = [self numberTideImageViewNamed:@"mid1"];
    self.numberTideSplitPanelView.contentMode = UIViewContentModeScaleToFill;
    self.numberTideSplitNumberView = [self numberTideImageViewNamed:@"big"];
    self.numberTideSplitPathView = [self numberTideImageViewNamed:@"dao"];
    self.numberTideSplitNumberLabel = [self numberTideLabelWithText:[NSString stringWithFormat:@"%ld", (long)value]
                                                               size:108.0];
    self.numberTideSplitHintLabel = [self numberTideLabelWithText:@"PLACE IN ADJACENT EMPTY CELL"
                                                             size:21.0];
    self.numberTideSplitCancelButton = [self numberTideButtonWithImageNamed:@"cancel"];
    self.numberTideSplitConfirmButton = [self numberTideButtonWithImageNamed:@"confirm"];
    [self.numberTideSplitCancelButton addTarget:self action:@selector(numberTideCancelSplitTapped)
                               forControlEvents:UIControlEventTouchUpInside];
    [self.numberTideSplitConfirmButton addTarget:self action:@selector(numberTideConfirmSplitTapped)
                                forControlEvents:UIControlEventTouchUpInside];

    [overlay addSubview:self.numberTideSplitPanelView];
    [overlay addSubview:self.numberTideSplitPathView];
    [overlay addSubview:self.numberTideSplitNumberView];
    [overlay addSubview:self.numberTideSplitNumberLabel];
    [overlay addSubview:self.numberTideSplitHintLabel];
    [overlay addSubview:self.numberTideSplitCancelButton];
    [overlay addSubview:self.numberTideSplitConfirmButton];

    self.numberTideSplitChoiceButtons = [NSMutableArray arrayWithCapacity:3];
    NSInteger choiceCount = MIN(value / 2, 3);
    NSInteger firstChoiceSlot = (3 - choiceCount) / 2;
    for (NSInteger slot = 0; slot < 3; slot++)
    {
        UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
        button.adjustsImageWhenHighlighted = NO;
        button.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:40.0];
        [button setTitleColor:[self numberTideInkColor] forState:UIControlStateNormal];
        [button setBackgroundImage:[UIImage imageNamed:@"small"] forState:UIControlStateNormal];

        NSInteger choiceIndex = slot - firstChoiceSlot;
        if (choiceIndex >= 0 && choiceIndex < choiceCount)
        {
            NSInteger first = choiceIndex + 1;
            NSInteger second = value - first;
            button.tag = first;
            [button setTitle:[NSString stringWithFormat:@"%ld + %ld", (long)first, (long)second]
                    forState:UIControlStateNormal];
            [button addTarget:self action:@selector(numberTideSplitChoiceTapped:)
             forControlEvents:UIControlEventTouchUpInside];
        }
        else
        {
            button.enabled = NO;
        }

        UIImageView *highlightView = [self numberTideImageViewNamed:@"choose"];
        highlightView.tag = 2001;
        highlightView.hidden = YES;
        [button addSubview:highlightView];
        [button bringSubviewToFront:button.titleLabel];
        [overlay addSubview:button];
        [self.numberTideSplitChoiceButtons addObject:button];
    }

    NSInteger selectedIndex = firstChoiceSlot + choiceCount / 2;
    self.numberTideSplitChoiceButtons[selectedIndex].selected = YES;
    [self numberTideUpdateSplitChoiceHighlights];

    UIImageView *costView = [self numberTideImageViewNamed:@"cost"];
    costView.tag = 1001;
    [overlay addSubview:costView];
}

- (void)numberTideLayoutSplitOverlay
{
    if (!self.numberTideSplitOverlayView)
    {
        return;
    }

    CGRect bounds = self.view.bounds;
    CGFloat scale = MIN(CGRectGetWidth(bounds) / NumberTideGameReferenceWidth,
                        CGRectGetHeight(bounds) / NumberTideGameReferenceHeight);
    self.numberTideSplitOverlayView.frame = bounds;
    self.numberTideSplitPanelView.frame = NumberTideGameScaledFrame(CGRectMake(25, 313, 700, 780), bounds);
    self.numberTideSplitNumberView.frame = NumberTideGameScaledFrame(CGRectMake(290, 467, 170, 165), bounds);
    self.numberTideSplitNumberLabel.frame = NumberTideGameScaledFrame(CGRectMake(305, 481, 140, 134), bounds);
    self.numberTideSplitPathView.frame = NumberTideGameScaledFrame(CGRectMake(155, 615, 440, 100), bounds);
    self.numberTideSplitHintLabel.frame = NumberTideGameScaledFrame(CGRectMake(185, 902, 380, 30), bounds);
    self.numberTideSplitCancelButton.frame = NumberTideGameScaledFrame(CGRectMake(70, 940, 285, 96), bounds);
    self.numberTideSplitConfirmButton.frame = NumberTideGameScaledFrame(CGRectMake(376, 936, 310, 108), bounds);
    [self.numberTideSplitOverlayView viewWithTag:1001].frame =
        NumberTideGameScaledFrame(CGRectMake(238, 838, 274, 58), bounds);

    CGFloat choiceX[] = {70.0, 280.0, 490.0};
    for (NSInteger index = 0; index < self.numberTideSplitChoiceButtons.count; index++)
    {
        UIButton *button = self.numberTideSplitChoiceButtons[index];
        button.frame = NumberTideGameScaledFrame(CGRectMake(choiceX[index], 712, 190, 112), bounds);
        NSString *title = [button titleForState:UIControlStateNormal];
        if (title.length > 0)
        {
            [button setAttributedTitle:[self numberTideSplitText:title size:40.0 scale:scale]
                              forState:UIControlStateNormal];
            button.titleLabel.shadowColor = nil;
            button.titleLabel.layer.shadowColor = [self numberTideSplitGoldColor].CGColor;
            button.titleLabel.layer.shadowOffset = CGSizeMake(1.5 * scale, 2.0 * scale);
            button.titleLabel.layer.shadowRadius = 0.8 * scale;
            button.titleLabel.layer.shadowOpacity = 0.65;
        }
        UIImageView *highlightView = [button viewWithTag:2001];
        highlightView.frame = CGRectMake(-18.0 * scale, -16.0 * scale,
                                         226.0 * scale, 144.0 * scale);
    }
    self.numberTideSplitNumberLabel.attributedText =
        [self numberTideSplitText:self.numberTideSplitNumberLabel.text size:108.0 scale:scale];
    self.numberTideSplitNumberLabel.shadowColor = nil;
    self.numberTideSplitNumberLabel.layer.shadowColor = [self numberTideSplitGoldColor].CGColor;
    self.numberTideSplitNumberLabel.layer.shadowOffset = CGSizeMake(2.0 * scale, 2.5 * scale);
    self.numberTideSplitNumberLabel.layer.shadowRadius = 1.0 * scale;
    self.numberTideSplitNumberLabel.layer.shadowOpacity = 0.7;
    self.numberTideSplitHintLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:21.0 * scale];
}

- (NSAttributedString *)numberTideSplitText:(NSString *)text
                                       size:(CGFloat)size
                                      scale:(CGFloat)scale
{
    NSDictionary *attributes = @{
        NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:size * scale],
        NSForegroundColorAttributeName: [UIColor colorWithRed:0.0 green:0.23 blue:0.39 alpha:1.0],
        NSStrokeColorAttributeName: [UIColor colorWithRed:0.0 green:0.04 blue:0.07 alpha:1.0],
        NSStrokeWidthAttributeName: @(-2.5)
    };
    return [[NSAttributedString alloc] initWithString:text attributes:attributes];
}

- (UIColor *)numberTideSplitGoldColor
{
    return [UIColor colorWithRed:0.68 green:0.45 blue:0.12 alpha:1.0];
}

- (void)numberTideSplitChoiceTapped:(UIButton *)sender
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
    for (UIButton *button in self.numberTideSplitChoiceButtons)
    {
        button.selected = button == sender;
    }
    [self numberTideUpdateSplitChoiceHighlights];
}

- (void)numberTideUpdateSplitChoiceHighlights
{
    for (UIButton *button in self.numberTideSplitChoiceButtons)
    {
        [button viewWithTag:2001].hidden = !button.selected;
        [button bringSubviewToFront:button.titleLabel];
    }
}

- (void)numberTideCancelSplitTapped
{
    [self numberTideDismissSplitOverlayWithCompletion:nil];
}

- (void)numberTideConfirmSplitTapped
{
    UIButton *selectedButton = nil;
    for (UIButton *button in self.numberTideSplitChoiceButtons)
    {
        if (button.selected)
        {
            selectedButton = button;
            break;
        }
    }
    if (!selectedButton)
    {
        return;
    }

    NSInteger first = selectedButton.tag;
    NSInteger value = [self.numberTideState.numberTideBoard[self.numberTideSplitSourceIndex] integerValue];
    if ([self.numberTideState numberTideSplitIndex:self.numberTideSplitSourceIndex
                                       firstValue:first
                                      secondValue:value - first])
    {
        self.numberTideSelectedBoardIndex = NumberTideGameNoSelection;
        [self numberTideDismissSplitOverlayWithCompletion:nil];
    }
}

- (void)numberTideDismissSplitOverlayWithCompletion:(void (^ _Nullable)(void))completion
{
    [UIView animateWithDuration:0.16 animations:^{
        self.numberTideSplitOverlayView.alpha = 0.0;
    } completion:^(__unused BOOL finished) {
        [self.numberTideSplitOverlayView removeFromSuperview];
        self.numberTideSplitOverlayView = nil;
        self.numberTideSplitChoiceButtons = nil;
        [self numberTideRefreshInterface];
        if (completion)
        {
            completion();
        }
    }];
}

- (void)numberTideUndoTapped
{
    [self.numberTideState numberTideUndo];
    [self numberTideClearSelectionAndRefresh];
}

- (void)numberTideResetTapped
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"RESTART LEVEL"
                                                                     message:@"Restart this level from the beginning?"
                                                              preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"CANCEL"
                                                style:UIAlertActionStyleCancel
                                              handler:nil]];
    __weak typeof(self) weakSelf = self;
    [alert addAction:[UIAlertAction actionWithTitle:@"RESTART"
                                                style:UIAlertActionStyleDestructive
                                              handler:^(__unused UIAlertAction *action) {
        [weakSelf numberTideLoadLevel:weakSelf.numberTideState.numberTideLevel];
    }]];
    [self presentViewController:alert animated:YES completion:nil];
}

- (void)numberTideRunTapped
{
    [self.numberTideState numberTideRun];
    [self numberTideClearSelectionAndRefresh];
    [self numberTidePresentResultIfNeeded];
}

- (void)numberTidePresentResultIfNeeded
{
    if (self.numberTideShowingResult)
    {
        return;
    }
    if (self.numberTideState.numberTideLevelComplete)
    {
        [self numberTidePresentCompletion];
    }
    else if (self.numberTideState.numberTideLevelFailed)
    {
        [self numberTidePresentFailure];
    }
}

- (void)numberTidePresentCompletion
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayLevelComplete];
    self.numberTideShowingResult = YES;
    NSInteger level = self.numberTideState.numberTideLevel;
    if (level < 8)
    {
        [NumberTideGameState numberTideSaveLevel:level + 1];
    }
    [self numberTideBuildResultViewForSuccess:YES];
}

- (void)numberTidePresentFailure
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayLevelFailed];
    self.numberTideShowingResult = YES;
    [self numberTideBuildResultViewForSuccess:NO];
}

- (void)numberTideBuildResultViewForSuccess:(BOOL)success
{
    [self.numberTideResultView removeFromSuperview];
    self.numberTideResultIsSuccess = success;

    UIView *resultView = [[UIView alloc] initWithFrame:self.view.bounds];
    resultView.backgroundColor = UIColor.blackColor;
    self.numberTideResultView = resultView;
    [self.view addSubview:resultView];

    self.numberTideResultBackgroundView = [self numberTideImageViewNamed:success ? @"successbg" : @"failbg"];
    self.numberTideResultBackgroundView.contentMode = UIViewContentModeScaleAspectFill;
    self.numberTideResultBackgroundView.clipsToBounds = YES;
    self.numberTideResultTitleView = [self numberTideImageViewNamed:success ? @"successtitle" : @"failedtitle"];
    BOOL perfectCycle = success && self.numberTideState.numberTideLevel == 8;
    self.numberTideResultSubtitleView = [self numberTideImageViewNamed:
        success ? (perfectCycle ? @"perfect" : @"small") : @"levelfailed"];
    if (success && !perfectCycle)
    {
        self.numberTideResultSubtitleView.contentMode = UIViewContentModeScaleToFill;
    }
    self.numberTideResultCycleView = [self numberTideImageViewNamed:success ? @"mid2" : @"mid3"];
    for (UIView *view in @[self.numberTideResultBackgroundView, self.numberTideResultTitleView,
                           self.numberTideResultSubtitleView, self.numberTideResultCycleView])
    {
        [resultView addSubview:view];
    }
    if (success && !perfectCycle)
    {
        self.numberTideResultSubtitleLabel = [self numberTideLabelWithText:self.numberTideState.numberTideTargetTitle
                                                                      size:25.0];
        [resultView addSubview:self.numberTideResultSubtitleLabel];
    }

    self.numberTideResultTileViews = [NSMutableArray arrayWithCapacity:3];
    self.numberTideResultValueLabels = [NSMutableArray arrayWithCapacity:3];
    NSArray<NSNumber *> *values = self.numberTideState.numberTideResultValues;
    for (NSInteger index = 0; index < 3; index++)
    {
        UIImageView *tile = [self numberTideImageViewNamed:@"big"];
        UILabel *label = [self numberTideLabelWithText:values[index].stringValue size:76.0];
        [resultView addSubview:tile];
        [resultView addSubview:label];
        [self.numberTideResultTileViews addObject:tile];
        [self.numberTideResultValueLabels addObject:label];
    }

    if (success)
    {
        self.numberTideResultStatViews = [NSMutableArray arrayWithCapacity:3];
        self.numberTideResultStatTitleLabels = [NSMutableArray arrayWithCapacity:3];
        self.numberTideResultStatValueLabels = [NSMutableArray arrayWithCapacity:3];
        NSArray<NSString *> *titles = @[@"ROUNDS", @"CYCLES", @"ACTIONS"];
        NSInteger completedRounds = MIN(MAX(0, self.numberTideState.numberTideRound - 1),
                                        self.numberTideState.numberTideRoundLimit);
        NSArray<NSString *> *statistics = @[
            [NSString stringWithFormat:@"%02ld", (long)completedRounds],
            [NSString stringWithFormat:@"%02ld", (long)self.numberTideState.numberTideLoopProgress],
            [NSString stringWithFormat:@"%02ld", (long)self.numberTideState.numberTideUsedActions]
        ];
        for (NSInteger index = 0; index < 3; index++)
        {
            UIImageView *panel = [self numberTideImageViewNamed:@"Fk 1"];
            UILabel *title = [self numberTideLabelWithText:titles[index] size:21.0];
            UILabel *value = [self numberTideLabelWithText:statistics[index] size:51.0];
            [resultView addSubview:panel];
            [resultView addSubview:title];
            [resultView addSubview:value];
            [self.numberTideResultStatViews addObject:panel];
            [self.numberTideResultStatTitleLabels addObject:title];
            [self.numberTideResultStatValueLabels addObject:value];
        }
        NSString *primaryImage = self.numberTideState.numberTideLevel < 8 ? @"nextlevel" : @"retry1";
        self.numberTideResultPrimaryButton = [self numberTideButtonWithImageNamed:primaryImage];
        self.numberTideResultHomeButton = [self numberTideButtonWithImageNamed:@"home 1"];
        self.numberTideResultRetryButton = [self numberTideButtonWithImageNamed:@"retry"];
        [self.numberTideResultPrimaryButton addTarget:self action:@selector(numberTideResultPrimaryTapped)
                                      forControlEvents:UIControlEventTouchUpInside];
        [self.numberTideResultHomeButton addTarget:self action:@selector(numberTideResultHomeTapped)
                                   forControlEvents:UIControlEventTouchUpInside];
        [self.numberTideResultRetryButton addTarget:self action:@selector(numberTideResultRetryTapped)
                                    forControlEvents:UIControlEventTouchUpInside];
        [resultView addSubview:self.numberTideResultPrimaryButton];
        [resultView addSubview:self.numberTideResultHomeButton];
        [resultView addSubview:self.numberTideResultRetryButton];
    }
    else
    {
        self.numberTideResultInfoView = [self numberTideImageViewNamed:@"info"];
        [resultView addSubview:self.numberTideResultInfoView];
        self.numberTideResultStatTitleLabels = [NSMutableArray arrayWithCapacity:3];
        self.numberTideResultStatValueLabels = [NSMutableArray arrayWithCapacity:3];
        NSArray<NSString *> *titles = @[@"ROUNDS", @"CYCLES", @"ACTIONS"];
        NSInteger completedRounds = MIN(MAX(0, self.numberTideState.numberTideRound - 1),
                                        self.numberTideState.numberTideRoundLimit);
        NSArray<NSString *> *statistics = @[
            [NSString stringWithFormat:@"%02ld / %02ld", (long)completedRounds,
             (long)self.numberTideState.numberTideRoundLimit],
            [NSString stringWithFormat:@"%02ld / 03", (long)MIN(3, self.numberTideState.numberTideLoopProgress)],
            [NSString stringWithFormat:@"%02ld", (long)self.numberTideState.numberTideUsedActions]
        ];
        for (NSInteger index = 0; index < 3; index++)
        {
            UILabel *title = [self numberTideLabelWithText:titles[index] size:21.0];
            UILabel *value = [self numberTideLabelWithText:statistics[index] size:43.0];
            [resultView addSubview:title];
            [resultView addSubview:value];
            [self.numberTideResultStatTitleLabels addObject:title];
            [self.numberTideResultStatValueLabels addObject:value];
        }
        self.numberTideResultReasonLabel = [self numberTideLabelWithText:@"ROUND LIMIT REACHED" size:22.0];
        [resultView addSubview:self.numberTideResultReasonLabel];
        self.numberTideResultPrimaryButton = [self numberTideButtonWithImageNamed:@"retry1"];
        self.numberTideResultHomeButton = [self numberTideButtonWithImageNamed:@"home1"];
        [self.numberTideResultPrimaryButton addTarget:self action:@selector(numberTideResultRetryTapped)
                                      forControlEvents:UIControlEventTouchUpInside];
        [self.numberTideResultHomeButton addTarget:self action:@selector(numberTideResultHomeTapped)
                                   forControlEvents:UIControlEventTouchUpInside];
        [resultView addSubview:self.numberTideResultPrimaryButton];
        [resultView addSubview:self.numberTideResultHomeButton];
    }

    [self numberTideLayoutResult];
    resultView.alpha = 0.0;
    [UIView animateWithDuration:0.28 animations:^{ resultView.alpha = 1.0; }];
}

- (void)numberTideLayoutResult
{
    if (!self.numberTideResultView)
    {
        return;
    }
    CGRect bounds = self.view.bounds;
    CGFloat scale = MIN(CGRectGetWidth(bounds) / NumberTideGameReferenceWidth,
                        CGRectGetHeight(bounds) / NumberTideGameReferenceHeight);
    self.numberTideResultView.frame = bounds;
    self.numberTideResultBackgroundView.frame = bounds;
    if (self.numberTideResultIsSuccess)
    {
        self.numberTideResultTitleView.frame = NumberTideGameScaledFrame(CGRectMake(141, 65, 468, 168), bounds);
        self.numberTideResultSubtitleView.frame = NumberTideGameScaledFrame(CGRectMake(208, 235, 335, 63), bounds);
        self.numberTideResultSubtitleLabel.frame = self.numberTideResultSubtitleView.frame;
        self.numberTideResultCycleView.frame = NumberTideGameScaledFrame(CGRectMake(88, 316, 574, 559), bounds);
        NSArray<NSValue *> *tiles = @[
            [NSValue valueWithCGRect:CGRectMake(303, 316, 145, 138)],
            [NSValue valueWithCGRect:CGRectMake(112, 599, 165, 145)],
            [NSValue valueWithCGRect:CGRectMake(473, 599, 165, 145)]
        ];
        for (NSInteger index = 0; index < 3; index++)
        {
            CGRect frame = NumberTideGameScaledFrame(tiles[index].CGRectValue, bounds);
            self.numberTideResultTileViews[index].frame = frame;
            self.numberTideResultValueLabels[index].frame = frame;
        }
        for (NSInteger index = 0; index < 3; index++)
        {
            CGFloat x = 68 + index * 207;
            self.numberTideResultStatViews[index].frame = NumberTideGameScaledFrame(CGRectMake(x, 875, 202, 148), bounds);
            self.numberTideResultStatTitleLabels[index].frame = NumberTideGameScaledFrame(CGRectMake(x + 14, 894, 174, 29), bounds);
            self.numberTideResultStatValueLabels[index].frame = NumberTideGameScaledFrame(CGRectMake(x + 15, 923, 172, 74), bounds);
        }
        self.numberTideResultPrimaryButton.frame = NumberTideGameScaledFrame(
            self.numberTideState.numberTideLevel < 8 ? CGRectMake(108, 1037, 534, 143) : CGRectMake(147, 1044, 457, 126), bounds);
        self.numberTideResultHomeButton.frame = NumberTideGameScaledFrame(CGRectMake(153, 1185, 121, 121), bounds);
        self.numberTideResultRetryButton.frame = NumberTideGameScaledFrame(CGRectMake(316, 1185, 273, 121), bounds);
    }
    else
    {
        self.numberTideResultTitleView.frame = NumberTideGameScaledFrame(CGRectMake(76, 56, 598, 149), bounds);
        self.numberTideResultSubtitleView.frame = NumberTideGameScaledFrame(CGRectMake(180, 198, 390, 67), bounds);
        self.numberTideResultCycleView.frame = NumberTideGameScaledFrame(CGRectMake(61, 274, 628, 592), bounds);
        NSArray<NSValue *> *tiles = @[
            [NSValue valueWithCGRect:CGRectMake(290, 307, 170, 150)],
            [NSValue valueWithCGRect:CGRectMake(137, 608, 170, 151)],
            [NSValue valueWithCGRect:CGRectMake(448, 608, 170, 151)]
        ];
        for (NSInteger index = 0; index < 3; index++)
        {
            CGRect frame = NumberTideGameScaledFrame(tiles[index].CGRectValue, bounds);
            self.numberTideResultTileViews[index].frame = frame;
            self.numberTideResultValueLabels[index].frame = frame;
        }
        self.numberTideResultInfoView.frame = NumberTideGameScaledFrame(CGRectMake(47, 850, 656, 194), bounds);
        for (NSInteger index = 0; index < 3; index++)
        {
            CGFloat x = 67 + index * 219;
            self.numberTideResultStatTitleLabels[index].frame = NumberTideGameScaledFrame(CGRectMake(x, 875, 178, 27), bounds);
            self.numberTideResultStatValueLabels[index].frame = NumberTideGameScaledFrame(CGRectMake(x, 901, 178, 57), bounds);
        }
        self.numberTideResultReasonLabel.frame = NumberTideGameScaledFrame(CGRectMake(90, 974, 570, 43), bounds);
        self.numberTideResultPrimaryButton.frame = NumberTideGameScaledFrame(CGRectMake(147, 1057, 457, 126), bounds);
        self.numberTideResultHomeButton.frame = NumberTideGameScaledFrame(CGRectMake(252, 1200, 246, 88), bounds);
    }
    for (UILabel *label in self.numberTideResultValueLabels)
    {
        label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:76.0 * scale];
    }
    for (UILabel *label in self.numberTideResultStatTitleLabels)
    {
        label.font = [UIFont fontWithName:@"Arial-BoldMT" size:21.0 * scale];
    }
    for (UILabel *label in self.numberTideResultStatValueLabels)
    {
        CGFloat size = self.numberTideResultIsSuccess ? 51.0 : 43.0;
        label.font = [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:size * scale];
    }
    self.numberTideResultReasonLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:22.0 * scale];
    self.numberTideResultSubtitleLabel.font = [UIFont fontWithName:@"Arial-BoldMT" size:25.0 * scale];
}

- (void)numberTideResultPrimaryTapped
{
    NSInteger level = self.numberTideState.numberTideLevel;
    [self numberTideDismissResultAndLoadLevel:level < 8 ? level + 1 : level];
}

- (void)numberTideResultRetryTapped
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
    [self numberTideRestartCurrentLevel];
}

- (void)numberTideRestartCurrentLevel
{
    [self numberTideDismissResultAndLoadLevel:self.numberTideState.numberTideLevel];
}

- (void)numberTideDismissResultAndLoadLevel:(NSInteger)level
{
    [UIView animateWithDuration:0.18 animations:^{ self.numberTideResultView.alpha = 0.0; }
                     completion:^(__unused BOOL finished) {
        [self.numberTideResultView removeFromSuperview];
        self.numberTideResultView = nil;
        [self numberTideLoadLevel:level];
    }];
}

- (void)numberTideResultHomeTapped
{
    self.numberTideShowingResult = NO;
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)numberTideLoadLevel:(NSInteger)level
{
    [self.numberTideSplitOverlayView removeFromSuperview];
    self.numberTideSplitOverlayView = nil;
    self.numberTideState = [[NumberTideGameState alloc] initWithNumberTideLevel:level];
    self.numberTideShowingResult = NO;
    [self numberTideClearSelectionAndRefresh];
}

- (void)numberTideExitTapped
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)numberTideClearSelectionAndRefresh
{
    self.numberTideSelectedBoardIndex = NumberTideGameNoSelection;
    self.numberTideSelectedInventoryValue = NumberTideGameNoSelection;
    [self numberTideRefreshInterface];
}

- (NSInteger)numberTideBoardIndexAtPoint:(CGPoint)point
{
    for (UIButton *button in self.numberTideBoardButtons)
    {
        if (CGRectContainsPoint(button.frame, point))
        {
            return button.tag;
        }
    }
    return NumberTideGameNoSelection;
}

- (void)numberTideLayoutSplitButton
{
    if (self.numberTideSelectedBoardIndex == NumberTideGameNoSelection)
    {
        return;
    }
    NSInteger row = self.numberTideSelectedBoardIndex / 5;
    NSInteger column = self.numberTideSelectedBoardIndex % 5;
    CGRect frame = CGRectMake(77 + column * 114, 492 + row * 110, 101, 26);
    self.numberTideSplitButton.frame = NumberTideGameScaledFrame(frame, self.view.bounds);
    [self.view bringSubviewToFront:self.numberTideSplitButton];
}

- (UIImageView *)numberTideImageViewNamed:(NSString *)name
{
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.userInteractionEnabled = NO;
    return imageView;
}

- (UILabel *)numberTideLabelWithText:(NSString *)text size:(CGFloat)size
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.tag = (NSInteger)size;
    label.font = [UIFont fontWithName:@"Arial-BoldMT" size:size];
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [self numberTideInkColor];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.65;
    return label;
}

- (UIButton *)numberTideButtonWithImageNamed:(NSString *)name
{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    [button setBackgroundImage:[UIImage imageNamed:name] forState:UIControlStateNormal];
    button.adjustsImageWhenHighlighted = NO;
    button.showsTouchWhenHighlighted = NO;
    [button addTarget:self action:@selector(numberTideButtonTouchDown:)
     forControlEvents:UIControlEventTouchDown];
    [button addTarget:self action:@selector(numberTideButtonTouchUp:)
     forControlEvents:UIControlEventTouchUpInside | UIControlEventTouchUpOutside |
                      UIControlEventTouchCancel | UIControlEventTouchDragExit];
    [button addTarget:self action:@selector(numberTidePlayClick)
     forControlEvents:UIControlEventTouchUpInside];
    return button;
}

- (void)numberTidePlayClick
{
    [NumberTideAudioManager.numberTideSharedManager numberTidePlayClick];
}

- (void)numberTideButtonTouchDown:(UIButton *)button
{
    [UIView animateWithDuration:0.12 animations:^{
        button.transform = CGAffineTransformMakeScale(0.965, 0.965);
        button.alpha = 0.86;
    }];
}

- (void)numberTideButtonTouchUp:(UIButton *)button
{
    [UIView animateWithDuration:0.18 animations:^{
        button.transform = CGAffineTransformIdentity;
        button.alpha = 1.0;
    }];
}

- (UIColor *)numberTideInkColor
{
    return [UIColor colorWithRed:0.01 green:0.11 blue:0.17 alpha:1.0];
}

@end
