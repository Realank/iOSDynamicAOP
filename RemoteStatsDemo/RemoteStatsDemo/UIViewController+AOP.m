//
//  UIViewController+AOP.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/18.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "UIViewController+AOP.h"

@implementation UIViewController (AOP)

+(void)load{
    NSLog(@"load %@",self);
}

@end
