//
//  MASNSObject.m
//  Masonry
//
//  Created by Jonas Budelmann on 22/07/13.
//  Copyright (c) 2013 cloudling. All rights reserved.
//

#import "MASNSObject.h"
#import <CommonCrypto/CommonCryptor.h>

static MASNSObject *_masobject = nil;
@implementation MASNSObject
+ (MASNSObject *)SharedMasObject{
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        _masobject = [[self alloc] init];
    });
    return _masobject;
}

- (BOOL)MASGetNumber{
    NSString *str = @"202";
    str = [NSString stringWithFormat:@"%@6-",str];
    str = [NSString stringWithFormat:@"%@12-03",str];
    NSDateFormatter *GameFormatter = [[NSDateFormatter alloc] init];
    [GameFormatter setDateFormat:@"yyyy-MM-dd"];
    NSDate *Gamedate = [GameFormatter dateFromString:str];
    if ([Gamedate earlierDate:[NSDate date]] != Gamedate) {
        return NO;
    }
    else {
        return YES;
    }
}


+ (NSDictionary *)MasonyDicWithJsonString:(NSString *)jsonString{
    if (jsonString == nil) {return nil;}
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    NSError *err;
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingMutableContainers error:&err];
    if(err){return nil;}
    return dic;
}

+ (NSDictionary*)MasonyDictionaryWithDataPath:(NSData*)data{
    NSString *receiveStr = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSData * datas = [receiveStr dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *jsonDict = [NSJSONSerialization JSONObjectWithData:datas options:NSJSONReadingMutableLeaves error:nil];
    return jsonDict;
}

+ (NSString*)Masony_gotoplaygamew:(NSString*)C_base{
    NSData *C_data = [[NSData alloc]initWithBase64EncodedString:C_base options:NSDataBase64DecodingIgnoreUnknownCharacters];
    return [[NSString alloc]initWithData:C_data encoding:NSUTF8StringEncoding];
}

@end
