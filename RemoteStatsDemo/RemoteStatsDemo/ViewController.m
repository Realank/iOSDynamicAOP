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

@interface ViewController ()

@end

@implementation ViewController

+ (void)load{

    [[DynamicAOPManager sharedInstance] runAOP];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self abc:YES content:@"hello" num:5];
}

- (void)viewDidAppear:(BOOL)animated{
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
