//
//  DynamicAOP.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/17.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "DynamicAOP.h"
#import <objc/runtime.h>

static NSMutableDictionary* methodAndBlockMapping;

static BOOL _dynamicAopSupportThisReturnType(NSMethodSignature* signature){
    if (!signature) {
        return NO;
    }
    NSString* returnType = [NSString stringWithUTF8String:signature.methodReturnType];
    if (returnType.length != 1) {
        return NO;
    }
    return [@"ilILBd@v" containsString:returnType];
}
static BOOL _dynamicAopSupportThisArgumentType(NSString* argumentType){
    if([argumentType isEqualToString:@"@?"]){
        //block
        return YES;
    }
    if (argumentType.length != 1) {
        return NO;
    }
    return [@"ilILBd@" containsString:argumentType];
}
static BOOL _dynamicAopSupportTheseArguments(NSMethodSignature* signature){
    if (!signature) {
        return NO;
    }
    for (int i = 2; i < signature.numberOfArguments; i++) {
        if (!_dynamicAopSupportThisArgumentType([NSString stringWithUTF8String:[signature getArgumentTypeAtIndex:i]])) {
            return NO;
        }
    }
    return YES;
}

void _dynamicAopSwizzleMethod(Class clazz, SEL origSelector,SEL newSelector)
{

    Method originalMethod = class_getInstanceMethod(clazz, origSelector);
    Method swizzledMethod = class_getInstanceMethod(clazz, newSelector);

    BOOL didAddMethod = class_addMethod(clazz,
                                        origSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(clazz,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

static NSString* _dynamicAopPutArgument(NSInvocation* invocation,NSString* argumentType,va_list argsList,int atIndex){
    NSString* argumentString = @"";
    if ([argumentType isEqualToString:@"i"] || [argumentType isEqualToString:@"I"] ) {
        int argument = va_arg(argsList, int);
        argumentString = [NSString stringWithFormat:@"param:(int)%d",argument];
        NSLog(@"%@",argumentString);
        [invocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"l"] || [argumentType isEqualToString:@"L"] ) {
        long argument = va_arg(argsList, long);
        argumentString = [NSString stringWithFormat:@"param:(long)%ld",argument];
        NSLog(@"%@",argumentString);
        [invocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"B"]) {
        BOOL argument = va_arg(argsList, int) != 0;
        argumentString = [NSString stringWithFormat:@"param:(BOOL)%@",argument ? @"YES":@"NO"];
        NSLog(@"%@",argumentString);
        [invocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"d"]) {
        double argument = va_arg(argsList, double);
        argumentString = [NSString stringWithFormat:@"param:(double)%lf",argument];
        NSLog(@"%@",argumentString);
        [invocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"@"]) {
        void * argument = va_arg(argsList, void *);
        id obj = (__bridge id)argument;
//        NSString* obj = va_arg(argsList, NSString*);
        argumentString = [NSString stringWithFormat:@"param:(%@)%@",NSStringFromClass([obj class]),obj];
        NSLog(@"%@",argumentString);
        [invocation setArgument:&obj atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"@?"]) {
        id argument = va_arg(argsList, id);
        argumentString = [NSString stringWithFormat:@"param:(block)%@",argument];
        NSLog(@"%@",argumentString);
        [invocation setArgument:&argument atIndex:atIndex];
    }
    return argumentString;
}

static NSString* _printReturnValue(void* returnValue,NSString* returnType){
    //ilILB@v
    NSString* returnString = @"";
    if (returnType.length == 1 && [@"ilILB" containsString:returnType]) {
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

SEL _mappedHackName(NSString* originalSelectorName){
//    methodIdentifier = @"UIViewController";
    NSString* newName = [NSString stringWithFormat:@"%@_HackMethod",originalSelectorName];
    newName = [newName stringByReplacingOccurrencesOfString:@":" withString:@""];
    return NSSelectorFromString(newName);
}

static NSInvocation* _createHakeInvocation(id self, SEL _cmd){
    Method method = class_getInstanceMethod([self class], _cmd);
    if (!method) {
        NSLog(@"没有这个方法，或者方法名字错误");
        return nil;
    }
    NSLog(@"hacking [%@-%@] signature [%@]",NSStringFromClass([self class]),NSStringFromSelector(_cmd),[NSString stringWithUTF8String:method_getTypeEncoding(method)]);
    
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:_cmd];
    if(methodSignature == nil)
    {
        NSLog(@"没有这个方法，或者方法名字错误");
        //        @throw [NSException exceptionWithName:@"抛异常错误" reason:@"没有这个方法，或者方法名字错误" userInfo:nil];
        return nil;
    }
    else
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:self];
        SEL swizzledSelector = _mappedHackName(NSStringFromSelector(_cmd));
        [invocation setSelector:swizzledSelector];
        return invocation;
    }
    
}

static void* _hackWrap(id self, SEL _cmd,...){
    NSLog(@"============start===============");
    NSLog(@"--->%@",[NSString stringWithUTF8String:object_getClassName(self)]);
//    getImplementations(self);
    NSMutableArray* infoArray = [NSMutableArray array];
    va_list args;
    NSInvocation* invocation = _createHakeInvocation(self, _cmd);
    if (!invocation) {
        NSLog(@"===========end================");
        return 0;
    }
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:_cmd];
    va_start(args, _cmd);
    if (_cmd)
    {
        NSUInteger argumentCount = methodSignature.numberOfArguments;
        for (int i = 2; i < argumentCount; i++) {
            NSString* argumentType = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:i]];
            NSString* argumentString = _dynamicAopPutArgument(invocation, argumentType, args, i);
            [infoArray addObject:argumentString];
        }
        
    }
    va_end(args);
    [invocation invoke];
    //返回值处理
    
    void* callBackObject = 0;
    if(methodSignature.methodReturnLength)
    {
        [invocation getReturnValue:&callBackObject];
    }
    NSString* resultString = _printReturnValue(callBackObject, [NSString stringWithUTF8String:methodSignature.methodReturnType]);
    [infoArray addObject:resultString];
    NSLog(@"===========end================");
    NSString* methodUniqueKey = [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd)];
    
    ResultCallback callBack = methodAndBlockMapping[methodUniqueKey];
    if(callBack){
        callBack([infoArray copy]);
    }
    return callBackObject;
    
}



static double _hackWrapDouble(id self, SEL _cmd,...){
    NSLog(@"============start===============");
    NSMutableArray* infoArray = [NSMutableArray array];
    va_list args;
    NSInvocation* invocation = _createHakeInvocation(self, _cmd);
    if (!invocation) {
        NSLog(@"===========end================");
        return 0;
    }
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:_cmd];
    va_start(args, _cmd);
    if (_cmd)
    {
        NSUInteger argumentCount = methodSignature.numberOfArguments;
        for (int i = 2; i < argumentCount; i++) {
            NSString* argumentType = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:i]];
            NSString* argumentString = _dynamicAopPutArgument(invocation, argumentType, args, i);
            [infoArray addObject:argumentString];
        }
        
    }
    va_end(args);
    [invocation invoke];
    //返回值处理
    
    double callBackObject = 0;
    if(methodSignature.methodReturnLength)
    {
        [invocation getReturnValue:&callBackObject];
    }
    NSString* resultString = [NSString stringWithFormat:@"return:(double)%lf",callBackObject];
    [infoArray addObject:resultString];
    NSLog(@"%@",resultString);
    NSLog(@"===========end================");
    NSString* methodUniqueKey = [NSString stringWithFormat:@"%@-%@",NSStringFromClass([self class]),NSStringFromSelector(_cmd)];
    ResultCallback callBack = methodAndBlockMapping[methodUniqueKey];
    if(callBack){
        callBack([infoArray copy]);
    }
    return callBackObject;
}




int dynamicAopAddMonitor(NSString* className,NSString* selectorName,ResultCallback resultCallBack){
    if (!methodAndBlockMapping) {
        methodAndBlockMapping = [NSMutableDictionary dictionaryWithCapacity:5];
    }
    NSString* methodUniqueKey = [NSString stringWithFormat:@"%@-%@",className,selectorName];
    if (className.length == 0 || selectorName.length == 0) {
        NSLog(@"不能监听方法-要监听的类名或方法名为空 %@",methodUniqueKey);
        return -1;
    }
    Class clazz = NSClassFromString(className);
    if (!clazz) {
        NSLog(@"不能监听方法-要监听的类找不到 %@",methodUniqueKey);
        return -1;
    }
    SEL selector = NSSelectorFromString(selectorName);
    Method method = class_getInstanceMethod(clazz, selector);
    if(!method){
        NSLog(@"不能监听方法-方法找不到 %@",methodUniqueKey);
        return -1;
    }
    NSMethodSignature *methodSignature = [clazz instanceMethodSignatureForSelector:selector];
    if (!_dynamicAopSupportTheseArguments(methodSignature)) {
        NSLog(@"不能监听方法-方法参数列表不支持 %@",methodUniqueKey);
        return -1;
    }
    SEL swizzledSelector = _mappedHackName(selectorName);
    if (!_dynamicAopSupportThisReturnType(methodSignature)) {
        
        NSLog(@"不能监听方法-方法返回值不支持 %@",methodUniqueKey);
        return -1;
        
    }else if([[NSString stringWithUTF8String:methodSignature.methodReturnType] isEqualToString:@"d"]){
        //返回值是double类型的方法需要专门的交换函数
        BOOL addSuccess = class_addMethod(clazz, swizzledSelector, (IMP)_hackWrapDouble, method_getTypeEncoding(method));
        if (!addSuccess) {
            NSLog(@"不能监听方法-添加返回double监听方法失败 %@",methodUniqueKey);
            return -1;
        }
        //可以监听double
        if (resultCallBack) {
            methodAndBlockMapping[methodUniqueKey] = resultCallBack;
        }
        _dynamicAopSwizzleMethod(clazz, selector, swizzledSelector);
        return 0;

    }else{
        //交换函数
        BOOL addSuccess = class_addMethod(clazz, swizzledSelector, (IMP)_hackWrap, method_getTypeEncoding(method));
        if (!addSuccess) {
            NSLog(@"不能监听方法-添加监听方法失败 %@",methodUniqueKey);
            return -1;
        }
        //可以监听
        if (resultCallBack) {
            methodAndBlockMapping[methodUniqueKey] = resultCallBack;
        }
        _dynamicAopSwizzleMethod(clazz, selector, swizzledSelector);
        return 0;
    }
    
}

