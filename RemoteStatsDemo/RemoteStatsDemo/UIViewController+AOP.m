//
//  UIViewController+AOP.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/17.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "UIViewController+AOP.h"
#import "UCARDynamicAOP.h"

@implementation UIViewController (AOP)

+ (void)initialize{
    NSLog(@"%@ initialize in category",NSStringFromClass([self class]));
    if ([NSStringFromClass([self class]) isEqualToString:@"ViewController"]) {
        NSLog(@"Monitor %@",NSStringFromClass([self class]));
        ucarAopAddMonitor(NSStringFromClass([self class]), NSStringFromSelector(@selector(def:num:)));
    }
}


@end
