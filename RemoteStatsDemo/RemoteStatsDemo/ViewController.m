//
//  ViewController.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/15.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "ViewController.h"
#include "DynamicAOP.h"
#import "TableViewController.h"

@interface ViewController ()

@end

@implementation ViewController

+ (void)initialize{
    NSLog(@"%@ initialize in category",NSStringFromClass([self class]));
    if ([NSStringFromClass([self class]) isEqualToString:@"ViewController"]) {
        NSLog(@"Monitor %@",NSStringFromClass([self class]));
//        dynamicAopAddMonitor(NSStringFromClass([self class]), NSStringFromSelector(@selector(def:num:)),^(NSArray* result){
//            NSLog(@"=result:%@",result);
//        });
        dynamicAopAddMonitor(@"UIViewController", @"viewDidAppear:",^(NSArray* result){
            NSLog(@"=result:%@",result);
        });
//        dynamicAopAddMonitor(@"ViewController", @"viewDidAppear:",^(NSArray* result){
//            NSLog(@"=result:%@",result);
//        });
//        dynamicAopAddMonitor(@"ViewController", NSStringFromSelector(@selector(abc:content:num:)),^(NSArray* result){
//            NSLog(@"=result:%@",result);
//        });
//        dynamicAopAddMonitor(@"ViewController", NSStringFromSelector(@selector(presentViewController:animated:completion:)),^(NSArray* result){
//            NSLog(@"=result:%@",result);
//        });
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSLog(@"%@ %@",NSStringFromClass([self class]),NSStringFromClass([super class]));
//    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
////        long ret = [self abc:YES content:@"content" num:-1];
//        double ret = [self def:^(int i,NSString* aa) {
//            NSLog(@"block int %d %@",i,aa);
//        } num:3];
//        NSLog(@"ret %lf",ret);
//        [self abc:YES content:@"content" num:34];
//        TableViewController* vc = [TableViewController new];
//        [self.navigationController pushViewController:vc animated:YES];
//    });
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    NSLog(@"== viewDidAppear %@ %d",NSStringFromSelector(_cmd),animated);
    [super viewDidAppear:animated];
   
}


- (int)abc:(BOOL)is content:(NSString*)content num:(int)num{
    NSLog(@"== abc %@ %d %@ %d",NSStringFromSelector(_cmd),is,content,num);
    return 314743647;
}

- (double)def:(void(^)(int i,NSString* a))is num:(int)num{
    NSLog(@"== def %@ %d",NSStringFromSelector(_cmd),num);
    is(883,@"dddd");
    return 0.2355657;
}



@end
