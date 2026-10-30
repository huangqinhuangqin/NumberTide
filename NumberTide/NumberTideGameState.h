#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface NumberTideGameState : NSObject

@property (nonatomic, readonly) NSArray *numberTideBoard;
@property (nonatomic, readonly) NSDictionary<NSNumber *, NSNumber *> *numberTideInventory;
@property (nonatomic, readonly) NSArray<NSNumber *> *numberTideInventoryValues;
@property (nonatomic, readonly) NSInteger numberTideActionsLeft;
@property (nonatomic, readonly) NSInteger numberTideRound;
@property (nonatomic, readonly) NSInteger numberTideLevel;
@property (nonatomic, readonly) NSInteger numberTideRoundLimit;
@property (nonatomic, readonly) NSInteger numberTideUsedActions;
@property (nonatomic, readonly) NSInteger numberTideLoopProgress;
@property (nonatomic, readonly) NSString *numberTideTargetTitle;
@property (nonatomic, readonly) NSString *numberTideTargetRule;
@property (nonatomic, readonly) NSString *numberTideProgressText;
@property (nonatomic, readonly) NSString *numberTideNextValueText;
@property (nonatomic, readonly) NSString *numberTideNextDetailText;
@property (nonatomic, readonly) BOOL numberTideLevelComplete;
@property (nonatomic, readonly) BOOL numberTideLevelFailed;
@property (nonatomic, readonly) NSArray<NSNumber *> *numberTideResultValues;

+ (NSInteger)numberTideSavedLevel;
+ (void)numberTideSaveLevel:(NSInteger)level;
+ (void)numberTideClearSavedData;

- (instancetype)initWithNumberTideLevel:(NSInteger)level;
- (BOOL)numberTidePlaceValue:(NSInteger)value atIndex:(NSInteger)index;
- (BOOL)numberTideMoveFromIndex:(NSInteger)source toIndex:(NSInteger)destination;
- (BOOL)numberTideSplitIndex:(NSInteger)index firstValue:(NSInteger)first secondValue:(NSInteger)second;
- (BOOL)numberTideCanSplitIndex:(NSInteger)index;
- (BOOL)numberTideUndo;
- (void)numberTideResetTurn;
- (void)numberTideRun;
- (NSArray<NSNumber *> *)numberTideEmptyNeighborsOfIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_END
