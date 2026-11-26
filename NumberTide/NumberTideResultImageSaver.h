#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^NumberTideResultSaveCompletion)(BOOL success,
                                                BOOL permissionDenied,
                                                NSError * _Nullable error);

@interface NumberTideResultImageSaver : NSObject

+ (UIImage *)numberTideResultImageForLevel:(NSInteger)level
                                     title:(NSString *)title
                                     board:(NSArray *)board
                                    rounds:(NSInteger)rounds
                                    cycles:(NSInteger)cycles
                                  actions:(NSInteger)actions;
+ (void)numberTideSaveImage:(UIImage *)image
                 completion:(NumberTideResultSaveCompletion)completion;

@end

NS_ASSUME_NONNULL_END
