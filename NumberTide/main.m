//
//  main.m
//  NumberTide
//
//  Created by apple on 2026/10/29.
//

#import <UIKit/UIKit.h>
#import "NumberTideAppDelegate.h"

int main(int argc, char *argv[])
{
    NSString *appDelegateClassName;
    @autoreleasepool
    {
        appDelegateClassName = NSStringFromClass([NumberTideAppDelegate class]);
    }
    return UIApplicationMain(argc, argv, nil, appDelegateClassName);
}
