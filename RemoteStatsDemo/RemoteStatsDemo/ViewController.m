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
#import "Aspects.h"
@interface ViewController ()

@end

@implementation ViewController

static NSString* _printReturnValue(void* returnValue,NSString* returnType){
    //ilILB@v
    NSString* returnString = @"";
    if (returnType.length == 1 && [@"ilIL" containsString:returnType]) {
        returnString = [NSString stringWithFormat:@"return:(%@)%ld",returnType,(long)returnValue];
        NSLog(@"%@",returnString);
    }else if ([returnType isEqualToString:@"B"]){
        returnString = [NSString stringWithFormat:@"return:(BOOL)%d",(BOOL)returnValue];
        NSLog(@"%@",returnString);
    }else if ([returnType isEqualToString:@"@"]){
        id obj = (__bridge id) returnValue;
        returnString = [NSString stringWithFormat:@"return:(%@)%@",NSStringFromClass([obj class]),obj];
        NSLog(@"%@",returnString);
    }else if ([returnType isEqualToString:@"v"]){
        returnString = @"return:(void)";
        NSLog(@"%@",returnString);
    }else{
        returnString = [NSString stringWithFormat:@"return:(%@)unknown",returnType];
        NSLog(@"%@",returnString);
    }
    return returnString;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self abc:9 content:@"hellod" num:5];
    [self hij:@"hello" num:4];
    double ret = [self def:^(int i, NSString *a) {
        NSLog(@"%d %@",i,a);
    } num:99];
    NSLog(@"ret value %lf",ret);
    
    
    TableViewController* vc = [TableViewController new];
    [vc aspect_hookSelector:@selector(tableView:cellForRowAtIndexPath:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info){
        NSLog(@"%@",info.arguments);
        NSInvocation* anInvocation = info.originalInvocation;
        if(anInvocation.methodSignature.methodReturnLength)
        {
            if ([[NSString stringWithUTF8String:anInvocation.methodSignature.methodReturnType] isEqualToString:@"d"]) {
                double callBackObject = 0;
                [anInvocation getReturnValue:&callBackObject];
                NSString* resultString = [NSString stringWithFormat:@"return:(double)%lf",callBackObject];
                NSLog(@"%@",resultString);
            }else{
                void* callBackObject = 0;
                [anInvocation getReturnValue:&callBackObject];
                NSString* resultString = _printReturnValue(callBackObject, [NSString stringWithUTF8String:anInvocation.methodSignature.methodReturnType]);
            }
    
        }
    } error:NULL];
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.navigationController pushViewController:vc animated:YES];
    });
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
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
