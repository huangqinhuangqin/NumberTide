#import "NumberTideGameState.h"

static NSInteger const NumberTideBoardSide = 5;
static NSInteger const NumberTideActionsPerRound = 3;
static NSInteger const NumberTideNoBoardIndex = -1;
static NSString * const NumberTideSavedLevelKey = @"NumberTideCurrentLevel";
static NSString * const NumberTideHasProgressKey = @"NumberTideHasProgress";

@interface NumberTideGameState ()

@property (nonatomic, strong) NSMutableArray *numberTideMutableBoard;
@property (nonatomic, strong) NSMutableDictionary<NSNumber *, NSNumber *> *numberTideMutableInventory;
@property (nonatomic, strong) NSArray<NSNumber *> *numberTideInventoryValues;
@property (nonatomic) NSInteger numberTideActionsLeft;
@property (nonatomic) NSInteger numberTideRound;
@property (nonatomic) NSInteger numberTideLevel;
@property (nonatomic) NSInteger numberTideRoundLimit;
@property (nonatomic, strong) NSString *numberTideTargetTitle;
@property (nonatomic, strong) NSString *numberTideTargetRule;
@property (nonatomic) NSInteger numberTideGeneratedOnes;
@property (nonatomic) NSInteger numberTideConsumptionCount;
@property (nonatomic) NSInteger numberTideAutomaticSplitCount;
@property (nonatomic) NSInteger numberTideManualSplitCount;
@property (nonatomic) NSInteger numberTideLoopProgress;
@property (nonatomic) NSInteger numberTideChainCount;
@property (nonatomic) NSInteger numberTideUsedActions;
@property (nonatomic) NSInteger numberTideConsecutiveChanges;
@property (nonatomic) NSInteger numberTideSplitSurvivalRounds;
@property (nonatomic, strong) NSMutableArray<NSDictionary *> *numberTideUndoStack;
@property (nonatomic, strong) NSDictionary *numberTideTurnStart;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *numberTidePendingLoops;
@property (nonatomic, strong) NSMutableSet<NSNumber *> *numberTidePriorConsumptionResults;
@property (nonatomic, strong) NSMutableArray<NSArray<NSNumber *> *> *numberTideSplitPairs;

@end

@implementation NumberTideGameState

+ (NSInteger)numberTideSavedLevel
{
    if (![NSUserDefaults.standardUserDefaults boolForKey:NumberTideHasProgressKey])
    {
        return 1;
    }
    NSInteger level = [NSUserDefaults.standardUserDefaults integerForKey:NumberTideSavedLevelKey];
    return level >= 1 && level <= 8 ? level : 1;
}

+ (void)numberTideSaveLevel:(NSInteger)level
{
    NSInteger validLevel = MAX(1, MIN(8, level));
    [NSUserDefaults.standardUserDefaults setInteger:validLevel forKey:NumberTideSavedLevelKey];
    [NSUserDefaults.standardUserDefaults setBool:YES forKey:NumberTideHasProgressKey];
}

+ (void)numberTideClearSavedData
{
    [NSUserDefaults.standardUserDefaults removeObjectForKey:NumberTideSavedLevelKey];
    [NSUserDefaults.standardUserDefaults removeObjectForKey:NumberTideHasProgressKey];
}

- (instancetype)init
{
    return [self initWithNumberTideLevel:NumberTideGameState.numberTideSavedLevel];
}

- (instancetype)initWithNumberTideLevel:(NSInteger)level
{
    self = [super init];
    if (self)
    {
        self.numberTideLevel = MAX(1, MIN(8, level));
        self.numberTideMutableBoard = [NSMutableArray arrayWithCapacity:25];
        for (NSInteger index = 0; index < 25; index++)
        {
            [self.numberTideMutableBoard addObject:NSNull.null];
        }
        self.numberTideActionsLeft = NumberTideActionsPerRound;
        self.numberTideRound = 1;
        self.numberTideUndoStack = [NSMutableArray array];
        self.numberTidePendingLoops = [NSMutableSet set];
        self.numberTidePriorConsumptionResults = [NSMutableSet set];
        self.numberTideSplitPairs = [NSMutableArray array];
        [self numberTideConfigureLevel];
        self.numberTideTurnStart = [self numberTideSnapshot];
    }
    return self;
}

- (NSArray *)numberTideBoard
{
    return self.numberTideMutableBoard.copy;
}

- (NSDictionary<NSNumber *,NSNumber *> *)numberTideInventory
{
    return self.numberTideMutableInventory.copy;
}

- (NSArray<NSNumber *> *)numberTideResultValues
{
    NSMutableArray<NSNumber *> *values = [NSMutableArray arrayWithCapacity:3];
    for (id value in self.numberTideMutableBoard)
    {
        if (value != NSNull.null)
        {
            [values addObject:value];
            if (values.count == 3)
            {
                break;
            }
        }
    }
    while (values.count < 3)
    {
        [values addObject:@0];
    }
    return values.copy;
}

- (NSString *)numberTideProgressText
{
    NSInteger progress = [self numberTideCompletedConditions];
    switch (self.numberTideLevel)
    {
        case 1:
            return [NSString stringWithFormat:@"%ld/3", (long)MIN(3, self.numberTideGeneratedOnes)];
        case 2:
            return [NSString stringWithFormat:@"%ld/2", (long)MIN(2, self.numberTideConsumptionCount)];
        case 3:
            return [NSString stringWithFormat:@"%ld/3", (long)MIN(3, self.numberTideSplitSurvivalRounds)];
        case 4:
            return [NSString stringWithFormat:@"%ld/2", (long)progress];
        case 5:
            return [NSString stringWithFormat:@"%ld/3", (long)MIN(3, self.numberTideLoopProgress)];
        case 6:
            return [NSString stringWithFormat:@"%ld/5", (long)progress];
        case 7:
            return [NSString stringWithFormat:@"%ld/3", (long)progress];
        default:
            return [NSString stringWithFormat:@"%ld/4", (long)progress];
    }
}

- (NSString *)numberTideNextValueText
{
    return [self numberTideNextPrediction][@"value"];
}

- (NSString *)numberTideNextDetailText
{
    return [self numberTideNextPrediction][@"detail"];
}

- (BOOL)numberTideLevelComplete
{
    switch (self.numberTideLevel)
    {
        case 1:
            return self.numberTideGeneratedOnes >= 3;
        case 2:
            return self.numberTideConsumptionCount >= 2;
        case 3:
            return [self numberTideTotalSplits] >= 1 &&
                   self.numberTideSplitSurvivalRounds >= 3;
        case 4:
            return [self numberTideTotalSplits] >= 1 && self.numberTideGeneratedOnes >= 1;
        case 5:
            return self.numberTideLoopProgress >= 3;
        case 6:
            return self.numberTideConsumptionCount >= 4 && self.numberTideChainCount >= 1;
        case 7:
            return self.numberTideConsumptionCount >= 2 && [self numberTideTotalSplits] >= 2 &&
                   self.numberTideUsedActions <= 6;
        default:
            return self.numberTideLoopProgress >= 3 && self.numberTideConsumptionCount >= 2 &&
                   [self numberTideTotalSplits] >= 1 && self.numberTideConsecutiveChanges >= 5;
    }
}

- (BOOL)numberTideLevelFailed
{
    return !self.numberTideLevelComplete && self.numberTideRound > self.numberTideRoundLimit;
}

- (BOOL)numberTidePlaceValue:(NSInteger)value atIndex:(NSInteger)index
{
    NSNumber *key = @(value);
    if (index < 0 || index >= 25 || self.numberTideMutableBoard[index] != NSNull.null ||
        [self.numberTideMutableInventory[key] integerValue] < 1 || self.numberTideActionsLeft < 1)
    {
        return NO;
    }
    [self numberTideSaveUndo];
    self.numberTideMutableBoard[index] = key;
    self.numberTideMutableInventory[key] = @([self.numberTideMutableInventory[key] integerValue] - 1);
    self.numberTideActionsLeft--;
    self.numberTideUsedActions++;
    return YES;
}

- (BOOL)numberTideMoveFromIndex:(NSInteger)source toIndex:(NSInteger)destination
{
    if (![self numberTideIndexesAreAdjacent:source second:destination] ||
        self.numberTideMutableBoard[source] == NSNull.null || self.numberTideActionsLeft < 1)
    {
        return NO;
    }
    [self numberTideSaveUndo];
    [self.numberTideMutableBoard exchangeObjectAtIndex:source withObjectAtIndex:destination];
    self.numberTideActionsLeft--;
    self.numberTideUsedActions++;
    [self.numberTidePendingLoops removeObject:@(source)];
    [self.numberTidePendingLoops removeObject:@(destination)];
    return YES;
}

- (BOOL)numberTideCanSplitIndex:(NSInteger)index
{
    if (index < 0 || index >= 25 || self.numberTideActionsLeft < 2)
    {
        return NO;
    }
    id value = self.numberTideMutableBoard[index];
    return value != NSNull.null && [value integerValue] >= 2 &&
           [self numberTideEmptyNeighborsOfIndex:index].count > 0;
}

- (BOOL)numberTideSplitIndex:(NSInteger)index firstValue:(NSInteger)first secondValue:(NSInteger)second
{
    NSArray<NSNumber *> *neighbors = [self numberTideEmptyNeighborsOfIndex:index];
    NSInteger original = [self.numberTideMutableBoard[index] integerValue];
    if (![self numberTideCanSplitIndex:index] || first < 1 || second < 1 || first + second != original)
    {
        return NO;
    }
    [self numberTideSaveUndo];
    NSInteger destination = neighbors.firstObject.integerValue;
    self.numberTideMutableBoard[index] = @(first);
    self.numberTideMutableBoard[destination] = @(second);
    self.numberTideActionsLeft -= 2;
    self.numberTideUsedActions += 2;
    self.numberTideManualSplitCount++;
    [self.numberTideSplitPairs addObject:@[@(index), @(destination)]];
    [self.numberTidePendingLoops removeObject:@(index)];
    return YES;
}

- (BOOL)numberTideUndo
{
    NSDictionary *snapshot = self.numberTideUndoStack.lastObject;
    if (!snapshot)
    {
        return NO;
    }
    [self.numberTideUndoStack removeLastObject];
    [self numberTideRestoreSnapshot:snapshot];
    return YES;
}

- (void)numberTideResetTurn
{
    [self numberTideRestoreSnapshot:self.numberTideTurnStart];
    [self.numberTideUndoStack removeAllObjects];
}

- (void)numberTideRun
{
    if (self.numberTideLevelComplete || self.numberTideLevelFailed)
    {
        return;
    }
    NSArray *source = self.numberTideMutableBoard.copy;
    NSMutableArray *result = self.numberTideMutableBoard.mutableCopy;
    NSMutableSet<NSNumber *> *changed = [NSMutableSet set];
    NSMutableSet<NSNumber *> *consumptionResults = [NSMutableSet set];

    [self numberTideUpdateSplitSurvivalFrom:source];
    [self numberTideResolveConsumptionFrom:source
                                    result:result
                                   changed:changed
                        consumptionResults:consumptionResults];
    [self numberTideResolveAutomaticSplitsFrom:source result:result changed:changed];
    for (NSInteger index = 0; index < 25; index++)
    {
        id value = source[index];
        if (value == NSNull.null || [changed containsObject:@(index)])
        {
            continue;
        }
        NSInteger number = [value integerValue];
        if (number == 0 && [self numberTideArray:source hasEmptyNeighbor:index])
        {
            result[index] = @1;
            self.numberTideGeneratedOnes++;
            [self.numberTidePendingLoops addObject:@(index)];
        }
        else if (number > 1)
        {
            result[index] = @(number - 1);
        }
    }
    self.numberTideConsecutiveChanges = [source isEqualToArray:result] ?
        0 : self.numberTideConsecutiveChanges + 1;
    self.numberTidePriorConsumptionResults = consumptionResults;
    self.numberTideMutableBoard = result;
    self.numberTideRound++;
    self.numberTideActionsLeft = NumberTideActionsPerRound;
    [self.numberTideUndoStack removeAllObjects];
    self.numberTideTurnStart = [self numberTideSnapshot];
}

- (NSArray<NSNumber *> *)numberTideEmptyNeighborsOfIndex:(NSInteger)index
{
    NSMutableArray<NSNumber *> *empty = [NSMutableArray array];
    for (NSNumber *neighbor in [self numberTideNeighborsOfIndex:index])
    {
        if (self.numberTideMutableBoard[neighbor.integerValue] == NSNull.null)
        {
            [empty addObject:neighbor];
        }
    }
    return empty;
}

- (void)numberTideConfigureLevel
{
    NSDictionary *configuration = [self numberTideLevelConfigurations][self.numberTideLevel - 1];
    self.numberTideRoundLimit = [configuration[@"limit"] integerValue];
    self.numberTideTargetTitle = configuration[@"title"];
    self.numberTideTargetRule = configuration[@"rule"];
    self.numberTideInventoryValues = configuration[@"values"];
    self.numberTideMutableInventory = [configuration[@"inventory"] mutableCopy];
    [configuration[@"board"] enumerateKeysAndObjectsUsingBlock:^(NSNumber *index,
                                                                  NSNumber *value,
                                                                  __unused BOOL *stop) {
        self.numberTideMutableBoard[index.integerValue] = value;
    }];
}

- (NSArray<NSDictionary *> *)numberTideLevelConfigurations
{
    NSDictionary *empty = @{@0 : @0, @1 : @0, @2 : @0, @3 : @0,
                            @4 : @0, @5 : @0, @6 : @0};
    NSDictionary *ones = @{@0 : @0, @1 : @3, @2 : @0, @3 : @0,
                           @4 : @0, @5 : @0, @6 : @0};
    NSDictionary *threes = @{@0 : @0, @1 : @0, @2 : @0, @3 : @3,
                             @4 : @0, @5 : @0, @6 : @0};
    NSDictionary *minimal = @{@0 : @0, @1 : @0, @2 : @1, @3 : @1,
                              @4 : @0, @5 : @0, @6 : @0};
    NSDictionary *oneThree = @{@0 : @0, @1 : @0, @2 : @0, @3 : @1,
                               @4 : @0, @5 : @0, @6 : @0};
    return @[
        @{@"limit" : @12, @"title" : @"EMPTY SPACE", @"rule" : @"0 TO 1 x3",
          @"values" : @[@0, @1, @2, @3, @6], @"inventory" : empty,
          @"board" : @{@1 : @3, @5 : @3, @6 : @0, @7 : @3, @11 : @3,
                       @12 : @0, @13 : @3, @17 : @3, @18 : @0, @19 : @3,
                       @23 : @3}},
        @{@"limit" : @10, @"title" : @"DIVIDE", @"rule" : @"CONSUME x2",
          @"values" : @[@1, @2, @3, @6, @0], @"inventory" : @{@0 : @0, @1 : @2,
          @2 : @0, @3 : @0, @4 : @0, @5 : @0, @6 : @0},
          @"board" : @{@6 : @3, @18 : @3}},
        @{@"limit" : @12, @"title" : @"SPLIT", @"rule" : @"SPLIT + SURVIVE 3",
          @"values" : @[@2, @3, @4, @6, @1], @"inventory" : empty,
          @"board" : @{@7 : @0, @11 : @0, @12 : @4, @13 : @0, @17 : @0}},
        @{@"limit" : @12, @"title" : @"NO ROOM", @"rule" : @"SPLIT + 0 TO 1",
          @"values" : @[@0, @1, @2, @4, @6], @"inventory" : empty,
          @"board" : @{@1 : @0, @5 : @0, @6 : @4, @7 : @0, @11 : @0,
                       @13 : @0, @17 : @0, @18 : @0, @19 : @0, @23 : @0}},
        @{@"limit" : @12, @"title" : @"NUMBER LOOP", @"rule" : @"0 TO 1 TO 0",
          @"values" : @[@0, @1, @2, @3, @6], @"inventory" : threes,
          @"board" : @{@1 : @0, @11 : @0, @21 : @0}},
        @{@"limit" : @15, @"title" : @"CHAIN REACTION", @"rule" : @"4 CONSUME + CHAIN",
          @"values" : @[@1, @2, @3, @6, @0], @"inventory" : ones,
          @"board" : @{@0 : @3, @2 : @1, @10 : @3, @20 : @3}},
        @{@"limit" : @15, @"title" : @"MINIMAL MOVES", @"rule" : @"2C 2S MAX 6AP",
          @"values" : @[@0, @2, @3, @4, @6], @"inventory" : minimal,
          @"board" : @{@1 : @0, @5 : @0, @6 : @4, @7 : @0, @9 : @0,
                       @10 : @6, @11 : @0, @13 : @0, @14 : @6, @17 : @0,
                       @18 : @4, @19 : @0, @23 : @0}},
        @{@"limit" : @20, @"title" : @"PERFECT CYCLE", @"rule" : @"3L 2C 1S 5X",
          @"values" : @[@0, @1, @2, @3, @5], @"inventory" : oneThree,
          @"board" : @{@0 : @5, @1 : @0, @2 : @0, @6 : @0, @21 : @0}}
    ];
}

- (void)numberTideResolveConsumptionFrom:(NSArray *)source
                                   result:(NSMutableArray *)result
                                  changed:(NSMutableSet<NSNumber *> *)changed
                       consumptionResults:(NSMutableSet<NSNumber *> *)consumptionResults
{
    for (NSDictionary<NSString *, NSNumber *> *intent in
         [self numberTideResolvedConsumptionIntentsFrom:source])
    {
        NSInteger eater = [intent[@"eater"] integerValue];
        NSInteger prey = [intent[@"prey"] integerValue];
        NSInteger large = [intent[@"eaterValue"] integerValue];
        NSInteger small = [intent[@"preyValue"] integerValue];
        result[eater] = @(large / small);
        result[prey] = @0;
        [changed addObject:@(eater)];
        [changed addObject:@(prey)];
        [consumptionResults addObject:@(eater)];
        self.numberTideConsumptionCount++;
        if ([self.numberTidePriorConsumptionResults containsObject:@(eater)] ||
            [self.numberTidePriorConsumptionResults containsObject:@(prey)])
        {
            self.numberTideChainCount++;
        }
        if ([self.numberTidePendingLoops containsObject:@(prey)] && small == 1)
        {
            self.numberTideLoopProgress++;
            [self.numberTidePendingLoops removeObject:@(prey)];
        }
    }
}

- (NSArray<NSDictionary<NSString *, NSNumber *> *> *)numberTideResolvedConsumptionIntentsFrom:
    (NSArray *)source
{
    NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *intents = [NSMutableArray array];
    for (NSInteger eater = 0; eater < 25; eater++)
    {
        if (source[eater] == NSNull.null)
        {
            continue;
        }

        NSInteger eaterValue = [source[eater] integerValue];
        NSInteger selectedPrey = NumberTideNoBoardIndex;
        NSInteger selectedValue = NSIntegerMax;
        for (NSNumber *neighborValue in [self numberTideNeighborsOfIndex:eater])
        {
            NSInteger prey = neighborValue.integerValue;
            if (source[prey] == NSNull.null)
            {
                continue;
            }
            NSInteger preyValue = [source[prey] integerValue];
            if (preyValue < 1 || eaterValue <= preyValue || eaterValue % preyValue != 0)
            {
                continue;
            }
            if (preyValue < selectedValue)
            {
                selectedPrey = prey;
                selectedValue = preyValue;
            }
        }
        if (selectedPrey != NumberTideNoBoardIndex)
        {
            [intents addObject:@{@"eater" : @(eater), @"prey" : @(selectedPrey),
                                 @"eaterValue" : @(eaterValue),
                                 @"preyValue" : @(selectedValue)}];
        }
    }

    [intents sortUsingComparator:^NSComparisonResult(NSDictionary *first,
                                                      NSDictionary *second) {
        NSInteger firstValue = [first[@"eaterValue"] integerValue];
        NSInteger secondValue = [second[@"eaterValue"] integerValue];
        if (firstValue != secondValue)
        {
            return firstValue > secondValue ? NSOrderedAscending : NSOrderedDescending;
        }
        NSInteger firstIndex = [first[@"eater"] integerValue];
        NSInteger secondIndex = [second[@"eater"] integerValue];
        return firstIndex < secondIndex ? NSOrderedAscending :
               firstIndex > secondIndex ? NSOrderedDescending : NSOrderedSame;
    }];

    NSMutableSet<NSNumber *> *occupied = [NSMutableSet set];
    NSMutableArray<NSDictionary<NSString *, NSNumber *> *> *resolved = [NSMutableArray array];
    for (NSDictionary<NSString *, NSNumber *> *intent in intents)
    {
        NSNumber *eater = intent[@"eater"];
        NSNumber *prey = intent[@"prey"];
        if ([occupied containsObject:eater] || [occupied containsObject:prey])
        {
            continue;
        }
        [occupied addObject:eater];
        [occupied addObject:prey];
        [resolved addObject:intent];
    }
    return resolved.copy;
}

- (NSDictionary<NSString *, NSString *> *)numberTideNextPrediction
{
    NSArray *board = self.numberTideMutableBoard;
    NSDictionary<NSString *, NSNumber *> *consumption =
        [self numberTideResolvedConsumptionIntentsFrom:board].firstObject;
    if (consumption)
    {
        NSInteger large = [consumption[@"eaterValue"] integerValue];
        NSInteger small = [consumption[@"preyValue"] integerValue];
        return @{@"value" : [NSString stringWithFormat:@"%ld", (long)(large / small)],
                 @"detail" : [NSString stringWithFormat:@"%ld/%ld",
                              (long)large, (long)small]};
    }

    NSDictionary<NSNumber *, NSArray<NSNumber *> *> *splits =
        @{@4 : @[@2, @2], @6 : @[@2, @3], @8 : @[@2, @4], @9 : @[@3, @3]};
    for (NSInteger index = 0; index < 25; index++)
    {
        if (board[index] == NSNull.null || !splits[board[index]] ||
            ![self numberTideArray:board hasEmptyNeighbor:index])
        {
            continue;
        }
        NSArray<NSNumber *> *pair = splits[board[index]];
        return @{@"value" : [NSString stringWithFormat:@"%@+%@", pair[0], pair[1]],
                 @"detail" : [NSString stringWithFormat:@"%@ SPLIT", board[index]]};
    }

    for (NSInteger index = 0; index < 25; index++)
    {
        if (board[index] != NSNull.null && [board[index] integerValue] > 1)
        {
            NSInteger value = [board[index] integerValue];
            return @{@"value" : [NSString stringWithFormat:@"%ld", (long)(value - 1)],
                     @"detail" : [NSString stringWithFormat:@"%ld>%ld",
                                  (long)value, (long)(value - 1)]};
        }
    }

    for (NSInteger index = 0; index < 25; index++)
    {
        if (board[index] != NSNull.null && [board[index] integerValue] == 0 &&
            [self numberTideArray:board hasEmptyNeighbor:index])
        {
            return @{@"value" : @"1", @"detail" : @"0>1"};
        }
    }
    return @{@"value" : @"-", @"detail" : @"NO CHANGE"};
}

- (void)numberTideResolveAutomaticSplitsFrom:(NSArray *)source
                                       result:(NSMutableArray *)result
                                      changed:(NSMutableSet<NSNumber *> *)changed
{
    NSDictionary<NSNumber *, NSArray<NSNumber *> *> *splits =
        @{@4 : @[@2, @2], @6 : @[@2, @3], @8 : @[@2, @4], @9 : @[@3, @3]};
    for (NSInteger index = 0; index < 25; index++)
    {
        if ([changed containsObject:@(index)] || source[index] == NSNull.null)
        {
            continue;
        }
        NSArray<NSNumber *> *pair = splits[source[index]];
        if (!pair)
        {
            continue;
        }
        for (NSNumber *neighborValue in [self numberTideNeighborsOfIndex:index])
        {
            NSInteger neighbor = neighborValue.integerValue;
            if (source[neighbor] == NSNull.null && result[neighbor] == NSNull.null)
            {
                result[index] = pair[0];
                result[neighbor] = pair[1];
                [changed addObject:@(index)];
                [changed addObject:@(neighbor)];
                self.numberTideAutomaticSplitCount++;
                [self.numberTideSplitPairs addObject:@[@(index), @(neighbor)]];
                break;
            }
        }
    }
}

- (void)numberTideUpdateSplitSurvivalFrom:(NSArray *)source
{
    for (NSArray<NSNumber *> *pair in self.numberTideSplitPairs)
    {
        if (source[pair[0].integerValue] != NSNull.null &&
            source[pair[1].integerValue] != NSNull.null)
        {
            self.numberTideSplitSurvivalRounds++;
            return;
        }
    }
}

- (NSInteger)numberTideCompletedConditions
{
    switch (self.numberTideLevel)
    {
        case 4:
            return ([self numberTideTotalSplits] >= 1) + (self.numberTideGeneratedOnes >= 1);
        case 6:
            return MIN(4, self.numberTideConsumptionCount) + (self.numberTideChainCount >= 1);
        case 7:
            return (self.numberTideConsumptionCount >= 2) + ([self numberTideTotalSplits] >= 2) +
                   (self.numberTideUsedActions <= 6);
        case 8:
            return (self.numberTideLoopProgress >= 3) + (self.numberTideConsumptionCount >= 2) +
                   ([self numberTideTotalSplits] >= 1) + (self.numberTideConsecutiveChanges >= 5);
        default:
            return 0;
    }
}

- (NSInteger)numberTideTotalSplits
{
    return self.numberTideAutomaticSplitCount + self.numberTideManualSplitCount;
}

- (NSArray<NSNumber *> *)numberTideNeighborsOfIndex:(NSInteger)index
{
    NSInteger row = index / NumberTideBoardSide;
    NSInteger column = index % NumberTideBoardSide;
    NSMutableArray<NSNumber *> *neighbors = [NSMutableArray arrayWithCapacity:4];
    if (row > 0) [neighbors addObject:@(index - NumberTideBoardSide)];
    if (column < NumberTideBoardSide - 1) [neighbors addObject:@(index + 1)];
    if (row < NumberTideBoardSide - 1) [neighbors addObject:@(index + NumberTideBoardSide)];
    if (column > 0) [neighbors addObject:@(index - 1)];
    return neighbors;
}

- (NSArray<NSNumber *> *)numberTideForwardNeighborsOfIndex:(NSInteger)index
{
    NSInteger row = index / NumberTideBoardSide;
    NSInteger column = index % NumberTideBoardSide;
    NSMutableArray<NSNumber *> *neighbors = [NSMutableArray arrayWithCapacity:2];
    if (column < NumberTideBoardSide - 1) [neighbors addObject:@(index + 1)];
    if (row < NumberTideBoardSide - 1) [neighbors addObject:@(index + NumberTideBoardSide)];
    return neighbors;
}

- (BOOL)numberTideIndexesAreAdjacent:(NSInteger)first second:(NSInteger)second
{
    return [[self numberTideNeighborsOfIndex:first] containsObject:@(second)];
}

- (BOOL)numberTideArray:(NSArray *)board hasEmptyNeighbor:(NSInteger)index
{
    for (NSNumber *neighbor in [self numberTideNeighborsOfIndex:index])
    {
        if (board[neighbor.integerValue] == NSNull.null)
        {
            return YES;
        }
    }
    return NO;
}

- (void)numberTideSaveUndo
{
    [self.numberTideUndoStack addObject:[self numberTideSnapshot]];
}

- (NSDictionary *)numberTideSnapshot
{
    return @{@"board" : self.numberTideMutableBoard.copy,
             @"inventory" : self.numberTideMutableInventory.copy,
             @"actions" : @(self.numberTideActionsLeft), @"round" : @(self.numberTideRound),
             @"generated" : @(self.numberTideGeneratedOnes),
             @"consumed" : @(self.numberTideConsumptionCount),
             @"automaticSplits" : @(self.numberTideAutomaticSplitCount),
             @"manualSplits" : @(self.numberTideManualSplitCount),
             @"loops" : @(self.numberTideLoopProgress), @"chains" : @(self.numberTideChainCount),
             @"usedActions" : @(self.numberTideUsedActions),
             @"consecutive" : @(self.numberTideConsecutiveChanges),
             @"survival" : @(self.numberTideSplitSurvivalRounds),
             @"pending" : self.numberTidePendingLoops.allObjects,
             @"priorResults" : self.numberTidePriorConsumptionResults.allObjects,
             @"splitPairs" : self.numberTideSplitPairs.copy};
}

- (void)numberTideRestoreSnapshot:(NSDictionary *)snapshot
{
    self.numberTideMutableBoard = [snapshot[@"board"] mutableCopy];
    self.numberTideMutableInventory = [snapshot[@"inventory"] mutableCopy];
    self.numberTideActionsLeft = [snapshot[@"actions"] integerValue];
    self.numberTideRound = [snapshot[@"round"] integerValue];
    self.numberTideGeneratedOnes = [snapshot[@"generated"] integerValue];
    self.numberTideConsumptionCount = [snapshot[@"consumed"] integerValue];
    self.numberTideAutomaticSplitCount = [snapshot[@"automaticSplits"] integerValue];
    self.numberTideManualSplitCount = [snapshot[@"manualSplits"] integerValue];
    self.numberTideLoopProgress = [snapshot[@"loops"] integerValue];
    self.numberTideChainCount = [snapshot[@"chains"] integerValue];
    self.numberTideUsedActions = [snapshot[@"usedActions"] integerValue];
    self.numberTideConsecutiveChanges = [snapshot[@"consecutive"] integerValue];
    self.numberTideSplitSurvivalRounds = [snapshot[@"survival"] integerValue];
    self.numberTidePendingLoops = [NSMutableSet setWithArray:snapshot[@"pending"]];
    self.numberTidePriorConsumptionResults = [NSMutableSet setWithArray:snapshot[@"priorResults"]];
    self.numberTideSplitPairs = [snapshot[@"splitPairs"] mutableCopy];
}

@end
