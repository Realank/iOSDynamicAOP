//
//  DAOPProbe.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/30.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "DAOPProbe.h"
#import "Aspects.h"
#import <objc/runtime.h>
@implementation DAOPProbe

NSString* _printReturnValue(void* returnValue,NSString* returnType){
    //ilILB@v
    NSString* returnString = @"";
    if (returnType.length == 1 && [@"ilIL" containsString:returnType]) {
        returnString = [NSString stringWithFormat:@"return:(%@)%ld",returnType,(long)returnValue];
    }else if ([returnType isEqualToString:@"B"]){
        returnString = [NSString stringWithFormat:@"return:(BOOL)%d",(BOOL)returnValue];
    }else if ([returnType isEqualToString:@"@"]){
        id obj = (__bridge id) returnValue;
        returnString = [NSString stringWithFormat:@"return:(%@)%@",NSStringFromClass([obj class]),obj];
    }else if ([returnType isEqualToString:@"v"]){
        returnString = @"return:(void)";
    }else{
        returnString = [NSString stringWithFormat:@"return:(%@)unknown",returnType];
    }
    NSLog(@"== %@",returnString);
    return returnString;
}

NSString* _printArgument(NSString* argumentType,id argument){
    NSString* argumentString = @"";
    if ([argumentType isEqualToString:@"i"] || [argumentType isEqualToString:@"I"] ) {
        argumentString = [NSString stringWithFormat:@"param:(int)%@",argument];
    }else if ([argumentType isEqualToString:@"l"] || [argumentType isEqualToString:@"L"] ) {
        argumentString = [NSString stringWithFormat:@"param:(long)%@",argument];
    }else if ([argumentType isEqualToString:@"B"]) {
        argumentString = [NSString stringWithFormat:@"param:(BOOL)%@",argument ? @"YES":@"NO"];
    }else if ([argumentType isEqualToString:@"d"]) {
        argumentString = [NSString stringWithFormat:@"param:(double)%@",argument];
    }else if ([argumentType isEqualToString:@"@"]) {
        argumentString = [NSString stringWithFormat:@"param:(%@)%@",[argument class],argument];
    }else if ([argumentType isEqualToString:@"@?"]) {
        argumentString = [NSString stringWithFormat:@"param:(block)%@",argument];
    }else{
        argumentString = [NSString stringWithFormat:@"param:(unknown)%@",argument];
    }
    NSLog(@"== %@",argumentString);
    return argumentString;
}

+ (void)runMappingOfClass:(NSString*)className andMethod:(NSString*)methodName showResult:(BOOL)showResult withResult:(ResultCallback)resultBlock{

    if (className.length == 0 || methodName.length == 0) {
        NSLog(@"不能监听方法-要监听的类名或方法名为空");
        return;
    }
    NSString* methodUniqueKey = [NSString stringWithFormat:@"%@-%@",className,methodName];
    Class clazz = NSClassFromString(className);
    if (!clazz) {
        NSLog(@"不能监听方法-要监听的类找不到 %@",methodUniqueKey);
        return;
    }
    SEL selector = NSSelectorFromString(methodName);
    Method method = class_getInstanceMethod(clazz, selector);
    if(!method){
        NSLog(@"不能监听方法-方法找不到 %@",methodUniqueKey);
        return;
    }
    NSError* error = nil;
    NSLog(@"开始监听方法 %@",methodUniqueKey);
    [clazz aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info){
        dispatch_async(dispatch_get_main_queue(), ^{
            [self asyncProcessAOPResult:info ofClass:className andMethod:methodName showResult:showResult withResult:resultBlock];
        });
    } error:&error];
    if (error) {
        NSLog(@"mapping error for %@-%@",className,methodName);
    }

}

+ (void)asyncProcessAOPResult:(id<AspectInfo>)info ofClass:(NSString*)className andMethod:(NSString*)methodName showResult:(BOOL)showResult withResult:(ResultCallback)resultBlock{
    NSString* methodUniqueKey = [NSString stringWithFormat:@"%@-%@",className,methodName];
    if (!showResult) {
        NSLog(@"===========埋点方法执行开始================");
        NSLog(@"== %@ without detail",methodUniqueKey);
        NSLog(@"===========埋点方法执行结束================");
        if(resultBlock){
            resultBlock(@[]);
        }
        return;
    }
    NSInvocation* anInvocation = info.originalInvocation;
    Class clazz = NSClassFromString(className);
    SEL selector = NSSelectorFromString(methodName);
    NSMethodSignature *methodSignature = [clazz instanceMethodSignatureForSelector:selector];
    NSMutableArray* aopArray = [NSMutableArray arrayWithCapacity:10];
    NSLog(@"===========埋点方法执行开始================");
    NSLog(@"== %@",methodUniqueKey);
    for(int i = 0; i < info.arguments.count; i++){
        NSString* argumentType = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:i+2]];
        id argument = info.arguments[i];
        [aopArray addObject:_printArgument(argumentType,argument)] ;
    }
    
    if(anInvocation.methodSignature.methodReturnLength)
    {
        if ([[NSString stringWithUTF8String:anInvocation.methodSignature.methodReturnType] isEqualToString:@"d"]) {
            double callBackObject = 0;
            [anInvocation getReturnValue:&callBackObject];
            NSString* resultString = [NSString stringWithFormat:@"return:(double)%lf",callBackObject];
            NSLog(@"== %@",resultString);
            [aopArray addObject:resultString];
        }else{
            void* callBackObject = 0;
            [anInvocation getReturnValue:&callBackObject];
            NSString* resultString = _printReturnValue(callBackObject, [NSString stringWithUTF8String:anInvocation.methodSignature.methodReturnType]);
            [aopArray addObject:resultString];
        }
        
    }
    NSLog(@"===========埋点方法执行结束================");
    if(resultBlock){
        resultBlock([aopArray copy]);
    }
}


@end
