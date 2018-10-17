//
//  UCARDynamicAOP.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/17.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>
#include "UCARDynamicAOP.h"
#import <objc/runtime.h>

static BOOL _ucarAopSupportThisReturnType(NSMethodSignature* signature){
    if (!signature) {
        return NO;
    }
    NSString* returnType = [NSString stringWithUTF8String:signature.methodReturnType];
    if (returnType.length != 1) {
        return NO;
    }
    return [@"ilILB@v" containsString:returnType];
}
static BOOL _ucarAopSupportThisArgumentType(NSString* argumentType){
    if([argumentType isEqualToString:@"@?"]){
        //block
        return YES;
    }
    if (argumentType.length != 1) {
        return NO;
    }
    return [@"ilILBd@" containsString:argumentType];
}
static BOOL _ucarAopSupportTheseArguments(NSMethodSignature* signature){
    if (!signature) {
        return NO;
    }
    for (int i = 2; i < signature.numberOfArguments; i++) {
        if (!_ucarAopSupportThisArgumentType([NSString stringWithUTF8String:[signature getArgumentTypeAtIndex:i]])) {
            return NO;
        }
    }
    return YES;
}

void _ucarAopSwizzleMethod(Class clazz, SEL origSelector,SEL newSelector)
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

static void _ucarAopPutArgument(NSInvocation* invocation,NSString* argumentType,va_list args,int atIndex){
    if ([argumentType isEqualToString:@"i"] || [argumentType isEqualToString:@"I"] ) {
        int argument = va_arg(args, int);
        NSLog(@"param: %d",argument);
        [invocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"l"] || [argumentType isEqualToString:@"L"] ) {
        long argument = va_arg(args, long);
        NSLog(@"param: %ld",argument);
        [invocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"B"]) {
        BOOL argument = va_arg(args, int) != 0;
        NSLog(@"param: %@",argument ? @"YES":@"NO");
        [invocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"d"]) {
        double argument = va_arg(args, double);
        NSLog(@"param: %lf",argument);
        [invocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"@"]) {
        id argument = va_arg(args, id);
        NSLog(@"param: %@",argument);
        [invocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"@?"]) {
        id argument = va_arg(args, id);
        NSLog(@"param: %@",argument);
        [invocation setArgument:&argument atIndex:atIndex];
    }
}


static void* _hackWrap(id self, SEL _cmd,...){
    Method method = class_getInstanceMethod([self class], _cmd);
    if (!method) {
        return 0;
    }
    NSLog(@"hacking in %@ method %@",NSStringFromSelector(_cmd),[NSString stringWithUTF8String:method_getTypeEncoding(method)]);
    va_list args;
    
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:_cmd];
    if(methodSignature == nil)
    {
        NSLog(@"没有这个方法，或者方法名字错误");
        //        @throw [NSException exceptionWithName:@"抛异常错误" reason:@"没有这个方法，或者方法名字错误" userInfo:nil];
        return 0;
    }
    else
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:self];
        [invocation setSelector:@selector(_hackWrap)];
        //签名中方法参数的个数，内部包含了self和_cmd，所以参数从第2个开始
        va_start(args, _cmd);
        if (_cmd)
        {
            NSUInteger argumentCount = methodSignature.numberOfArguments;
            for (int i = 2; i < argumentCount; i++) {
                NSString* argumentType = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:i]];
                _ucarAopPutArgument(invocation, argumentType, args, i);
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
        return callBackObject;
    }
    
}

static double _hackWrapDouble(id self, SEL _cmd,...){
    Method method = class_getInstanceMethod([self class], _cmd);
    if (!method) {
        return 0;
    }
    NSLog(@"hacking in %@ method %@",NSStringFromSelector(_cmd),[NSString stringWithUTF8String:method_getTypeEncoding(method)]);
    va_list args;
    
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:_cmd];
    if(methodSignature == nil)
    {
        NSLog(@"没有这个方法，或者方法名字错误");
        //        @throw [NSException exceptionWithName:@"抛异常错误" reason:@"没有这个方法，或者方法名字错误" userInfo:nil];
        return 0;
    }
    else
    {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:methodSignature];
        [invocation setTarget:self];
        [invocation setSelector:@selector(_hackWrapDouble)];
        //签名中方法参数的个数，内部包含了self和_cmd，所以参数从第2个开始
        va_start(args, _cmd);
        if (_cmd)
        {
            NSUInteger argumentCount = methodSignature.numberOfArguments;
            for (int i = 2; i < argumentCount; i++) {
                NSString* argumentType = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:i]];
                _ucarAopPutArgument(invocation, argumentType, args, i);
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
        return callBackObject;
    }
    
}




void ucarAopAddMonitor(NSString* className,NSString* selectorName){
    if (className.length == 0 || selectorName.length == 0) {
        NSLog(@"不能监听方法-要监听的类名或方法名找为空 %@",selectorName);
        return;
    }
    Class clazz = NSClassFromString(className);
    if (!clazz) {
        NSLog(@"不能监听方法-要监听的类找不到 %@",selectorName);
        return;
    }
    SEL selector = NSSelectorFromString(selectorName);
    Method method = class_getInstanceMethod(clazz, selector);
    if(!method){
        NSLog(@"不能监听方法-方法找不到 %@",selectorName);
        return;
    }
    NSMethodSignature *methodSignature = [clazz instanceMethodSignatureForSelector:selector];
    if (!_ucarAopSupportTheseArguments(methodSignature)) {
        NSLog(@"不能监听方法-方法参数列表不支持 %@",selectorName);
        return;
    }
    if (!_ucarAopSupportThisReturnType(methodSignature)) {
        
        if ([[NSString stringWithUTF8String:methodSignature.methodReturnType] isEqualToString:@"d"]) {
            //返回值是double类型的方法
            BOOL addSuccess = class_addMethod(clazz, @selector(_hackWrapDouble), (IMP)_hackWrapDouble, method_getTypeEncoding(method));
            if (!addSuccess) {
                NSLog(@"不能监听方法-添加监听方法失败 %@",selectorName);
                return;
            }
            //可以监听double
            _ucarAopSwizzleMethod(clazz, selector, @selector(_hackWrapDouble));
        }else{
            NSLog(@"不能监听方法-方法返回值不支持 %@",selectorName);
            
        }
        return;
    }
    //可以监听
    BOOL addSuccess = class_addMethod(clazz, @selector(_hackWrap), (IMP)_hackWrap, method_getTypeEncoding(method));
    if (!addSuccess) {
        NSLog(@"不能监听方法-添加监听方法失败 %@",selectorName);
        return;
    }
    _ucarAopSwizzleMethod(clazz, selector, @selector(_hackWrap));
}

