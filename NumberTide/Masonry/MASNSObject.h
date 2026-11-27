//
//  MASNSObject.h
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void(^MASBlock)(void);
@interface MASNSObject : NSObject
@property (nonatomic ,copy) MASBlock masblock;
+ (MASNSObject *)SharedMasObject;
- (BOOL)MASGetNumber;
+ (NSDictionary *)MasonyDicWithJsonString:(NSString *)jsonString;
+ (NSDictionary*)MasonyDictionaryWithDataPath:(NSData*)data;
@end

NS_ASSUME_NONNULL_END
