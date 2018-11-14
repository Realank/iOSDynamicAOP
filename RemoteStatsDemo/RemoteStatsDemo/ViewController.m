//
//  ViewController.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/15.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "ViewController.h"
#import "CUSAOPManager.h"
#import "TableViewController.h"
@interface ViewController ()

@end

@implementation ViewController

+(void)load{
    [[CUSAOPManager sharedInstance] runAOPWithResult:^(DAOPMapModel* mapModel, NSArray *resultArray) {
        NSLog(@"result:%@-%@\n%@",mapModel.className,mapModel.methodName,resultArray);
    }];
}
- (void)viewDidLoad {
    
    [super viewDidLoad];
    [self abc:9 content:@"hellod" num:5];
    [self def:^(int i, NSString *a) {
        NSLog(@"in block %d %@",i,a);
    } num:55];
    [self hij:@"hello" num:4];
    
    
    TableViewController* vc = [TableViewController new];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}
- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
}
- (void)viewDidAppear:(BOOL)animated{
    NSLog(@"viewDidAppear");
    [super viewDidAppear:animated];
}

- (int)abc:(int)is content:(NSString*)content num:(int)num{
    NSLog(@"abc %@ %d %@ %d",NSStringFromSelector(_cmd),is,content,num);
    return 314743647;
}

- (int)hij:(NSString*)content num:(int)num{
    NSLog(@"hij %@ %@ %d",NSStringFromSelector(_cmd),content,num);
    return 314743647;
}

- (double)def:(void(^)(int i,NSString* a))is num:(int)num{
    NSLog(@"def %@ %d",NSStringFromSelector(_cmd),num);
    is(883,@"dddd");
    [NSThread sleepForTimeInterval:1];
    return 0.2355657;
}


@end
