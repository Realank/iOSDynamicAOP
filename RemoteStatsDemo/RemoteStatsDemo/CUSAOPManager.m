//
//  CUSAOPManager.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/30.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "CUSAOPManager.h"

@implementation CUSAOPManager

- (BOOL)canMonitorThisMapping:(DAOPMapModel *)mapModel{
    if (mapModel.filterList.count > 0) {
        return YES;
    }else{
        NSLog(@"不接受没有过滤的AOP映射 %@-%@",mapModel.className, mapModel.methodName);
        return NO;
    }
}

@end
