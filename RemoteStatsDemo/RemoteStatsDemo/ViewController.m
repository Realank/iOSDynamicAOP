//
//  ViewController.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/15.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "ViewController.h"
#include "DynamicAOPManager.h"
#import "TableViewController.h"
#import <objc/runtime.h>
#import <objc/message.h>
@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self abc:9 content:@"hellod" num:5];
    [self hij:@"hello" num:4];
    [self def:^(int i, NSString *a) {
        NSLog(@"%d %@",i,a);
    } num:99];
}



- (int)abc:(int)is content:(NSString*)content num:(int)num{
    NSLog(@"== abc %@ %d %@ %d",NSStringFromSelector(_cmd),is,content,num);
    return 314743647;
}

- (int)hij:(NSString*)content num:(int)num{
    NSLog(@"== hij %@ %@ %d",NSStringFromSelector(_cmd),content,num);
    return 314743647;
}

- (double)def:(void(^)(int i,NSString* a))is num:(int)num{
    NSLog(@"== def %@ %d",NSStringFromSelector(_cmd),num);
    is(883,@"dddd");
    return 0.2355657;
}


@end
