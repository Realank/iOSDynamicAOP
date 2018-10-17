//
//  ViewController.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/15.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "ViewController.h"
#include "UCARDynamicAOP.h"

@interface ViewController ()

@end

@implementation ViewController

+ (void)initialize{
    NSLog(@"%@ initialize in category",NSStringFromClass([self class]));
    if ([NSStringFromClass([self class]) isEqualToString:@"ViewController"]) {
        NSLog(@"Monitor %@",NSStringFromClass([self class]));
        ucarAopAddMonitor(NSStringFromClass([self class]), NSStringFromSelector(@selector(def:num:)));
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
//        long ret = [self abc:YES content:@"content" num:-1];
        double ret = [self def:^(int i,NSString* aa) {
            NSLog(@"block int %d %@",i,aa);
        } num:3];
        NSLog(@"ret %lf",ret);
    });
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
//    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear %@ %d",NSStringFromSelector(_cmd),animated);
}


- (int)abc:(BOOL)is content:(NSString*)content num:(int)num{
    NSLog(@"abc %@ %d %@ %d",NSStringFromSelector(_cmd),is,content,num);
    return 314743647;
}

- (double)def:(void(^)(int i,NSString* a))is num:(int)num{
    NSLog(@"def %@ %d",NSStringFromSelector(_cmd),num);
    is(883,@"dddd");
    return 0.2355657;
}



@end
