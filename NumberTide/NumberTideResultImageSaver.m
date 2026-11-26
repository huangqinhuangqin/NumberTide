#import "NumberTideResultImageSaver.h"
#import <Photos/Photos.h>
#import <QuartzCore/QuartzCore.h>

static NSString * const NumberTidePhotoSaveErrorDomain = @"NumberTidePhotoSaveErrorDomain";

@interface NumberTideResultImageSaver ()

+ (void)numberTideSaveImageData:(NSData *)data
                     completion:(NumberTideResultSaveCompletion)completion;
+ (void)numberTideWriteImageData:(NSData *)data
                      completion:(NumberTideResultSaveCompletion)completion;

@end

@implementation NumberTideResultImageSaver

+ (UIImage *)numberTideResultImageForLevel:(NSInteger)level
                                     title:(NSString *)title
                                     board:(NSArray *)board
                                    rounds:(NSInteger)rounds
                                    cycles:(NSInteger)cycles
                                  actions:(NSInteger)actions
{
    CGSize size = CGSizeMake(750.0, 1334.0);
    UIView *card = [[UIView alloc] initWithFrame:(CGRect){CGPointZero, size}];
    UIImageView *background = [self numberTideImageViewNamed:@"successbg"];
    background.frame = card.bounds;
    background.contentMode = UIViewContentModeScaleAspectFill;
    [card addSubview:background];

    UIImageView *logo = [self numberTideImageViewNamed:@"NumberTideHomeTitle"];
    logo.frame = CGRectMake(166.0, 28.0, 418.0, 133.0);
    [card addSubview:logo];
    UIImageView *complete = [self numberTideImageViewNamed:@"successtitle"];
    complete.frame = CGRectMake(141.0, 158.0, 468.0, 168.0);
    [card addSubview:complete];

    UILabel *levelLabel = [self numberTideLabelWithText:[NSString
        stringWithFormat:@"LEVEL %02ld  |  %@", (long)level, title]
                                                   size:25.0];
    levelLabel.frame = CGRectMake(75.0, 320.0, 600.0, 35.0);
    [card addSubview:levelLabel];
    UIImageView *boardView = [self numberTideImageViewNamed:@"QI"];
    boardView.frame = CGRectMake(62.0, 385.0, 626.0, 660.0);
    [card addSubview:boardView];
    for (NSInteger index = 0; index < MIN(25, board.count); index++)
    {
        id value = board[index];
        if (value == NSNull.null)
        {
            continue;
        }
        NSInteger row = index / 5;
        NSInteger column = index % 5;
        CGRect frame = CGRectMake(93.0 + column * 114.0,
                                  473.0 + row * 110.0, 107.0, 102.0);
        UIImageView *tile = [self numberTideImageViewNamed:@"FK"];
        tile.frame = frame;
        [card addSubview:tile];
        UILabel *valueLabel = [self numberTideLabelWithText:[value stringValue] size:42.0];
        valueLabel.frame = frame;
        [card addSubview:valueLabel];
    }

    NSArray<NSString *> *names = @[@"ROUNDS", @"CYCLES", @"ACTIONS"];
    NSArray<NSNumber *> *values = @[@(rounds), @(cycles), @(actions)];
    for (NSInteger index = 0; index < 3; index++)
    {
        CGFloat x = 50.0 + index * 220.0;
        UIImageView *panel = [self numberTideImageViewNamed:@"Fk 1"];
        panel.frame = CGRectMake(x, 1052.0, 202.0, 148.0);
        [card addSubview:panel];
        UILabel *nameLabel = [self numberTideLabelWithText:names[index] size:20.0];
        nameLabel.frame = CGRectMake(x + 12.0, 1068.0, 178.0, 28.0);
        [card addSubview:nameLabel];
        UILabel *valueLabel = [self numberTideLabelWithText:[NSString
            stringWithFormat:@"%02ld", (long)values[index].integerValue]
                                                         size:48.0];
        valueLabel.frame = CGRectMake(x + 12.0, 1095.0, 178.0, 78.0);
        [card addSubview:valueLabel];
    }

    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    formatter.locale = [NSLocale localeWithLocaleIdentifier:@"en_US_POSIX"];
    formatter.dateFormat = @"MMM d, yyyy";
    UILabel *dateLabel = [self numberTideLabelWithText:[[formatter
        stringFromDate:NSDate.date] uppercaseString] size:28.0];
    dateLabel.frame = CGRectMake(75.0, 1260.0, 600.0, 42.0);
    [card addSubview:dateLabel];

    UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat defaultFormat];
    format.scale = 1.0;
    format.opaque = YES;
    UIGraphicsImageRenderer *renderer = [[UIGraphicsImageRenderer alloc]
        initWithSize:size format:format];
    return [renderer imageWithActions:^(UIGraphicsImageRendererContext *context) {
        [card.layer renderInContext:context.CGContext];
    }];
}

+ (UIImageView *)numberTideImageViewNamed:(NSString *)name
{
    UIImageView *view = [[UIImageView alloc] initWithImage:[UIImage imageNamed:name]];
    view.contentMode = UIViewContentModeScaleAspectFit;
    return view;
}

+ (UILabel *)numberTideLabelWithText:(NSString *)text size:(CGFloat)size
{
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectZero];
    label.text = text;
    label.textAlignment = NSTextAlignmentCenter;
    label.textColor = [UIColor colorWithRed:0.01 green:0.13 blue:0.27 alpha:1.0];
    label.font = [UIFont fontWithName:@"Arial-BoldMT" size:size];
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.75;
    return label;
}

+ (void)numberTideSaveImage:(UIImage *)image
                 completion:(NumberTideResultSaveCompletion)completion
{
    NSData *data = UIImagePNGRepresentation(image);
    if (!data)
    {
        NSError *error = [NSError errorWithDomain:NumberTidePhotoSaveErrorDomain
                                             code:1
                                         userInfo:@{NSLocalizedDescriptionKey :
                                                        @"The result image could not be created."}];
        completion(NO, NO, error);
        return;
    }
    [self numberTideSaveImageData:data completion:completion];
}

+ (void)numberTideSaveImageData:(NSData *)data
                     completion:(NumberTideResultSaveCompletion)completion
{
    PHAuthorizationStatus status = [PHPhotoLibrary
        authorizationStatusForAccessLevel:PHAccessLevelAddOnly];
    if (status == PHAuthorizationStatusNotDetermined)
    {
        [PHPhotoLibrary requestAuthorizationForAccessLevel:PHAccessLevelAddOnly
                                                   handler:^(__unused PHAuthorizationStatus newStatus) {
            [self numberTideSaveImageData:data completion:completion];
        }];
        return;
    }
    if (status != PHAuthorizationStatusAuthorized &&
        status != PHAuthorizationStatusLimited)
    {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(NO, YES, nil);
        });
        return;
    }
    [self numberTideWriteImageData:data completion:completion];
}

+ (void)numberTideWriteImageData:(NSData *)data
                      completion:(NumberTideResultSaveCompletion)completion
{
    [PHPhotoLibrary.sharedPhotoLibrary performChanges:^{
        PHAssetCreationRequest *request = [PHAssetCreationRequest creationRequestForAsset];
        [request addResourceWithType:PHAssetResourceTypePhoto data:data options:nil];
    }
    completionHandler:^(BOOL success, NSError *error) {
        dispatch_async(dispatch_get_main_queue(), ^{
            completion(success, NO, error);
        });
    }];
}

@end
