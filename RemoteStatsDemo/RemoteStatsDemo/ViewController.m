//
//  ViewController.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/15.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "ViewController.h"
#import <objc/runtime.h>
@interface ViewController ()

@end

@implementation ViewController

+ (void)load{
//    [self swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(ucarViewDidAppear:)];
    Method method = class_getInstanceMethod([self class], @selector(def:num:));
    NSLog(@"%s",method_getTypeEncoding(method));
    [self monitorSelector:NSStringFromSelector(@selector(def:num:))];
}

+ (void)monitorSelector:(NSString*)selectorName{
    SEL selector = NSSelectorFromString(selectorName);
    Method method = class_getInstanceMethod([self class], selector);
    if(!method){
        NSLog(@"不能监听方法-方法找不到 %@",selectorName);
        return;
    }
    NSMethodSignature *methodSignature = [[self class] instanceMethodSignatureForSelector:selector];
    if (![self supportTheseArguments:methodSignature]) {
        NSLog(@"不能监听方法-方法参数列表不支持 %@",selectorName);
        return;
    }
    if (![self supportThisReturnType:methodSignature]) {
        
        if ([[NSString stringWithUTF8String:methodSignature.methodReturnType] isEqualToString:@"d"]) {
            //返回值是double类型的方法
            class_addMethod([self class], @selector(hackWrapDouble), (IMP)hackWrapDouble, method_getTypeEncoding(method));
            [self swizzleMethod:selector withMethod:@selector(hackWrapDouble)];
        }else{
            NSLog(@"不能监听方法-方法返回值不支持 %@",selectorName);
            
        }
        return;
    }
    //可以监听
    class_addMethod([self class], @selector(hackWrap), (IMP)hackWrap, method_getTypeEncoding(method));
    [self swizzleMethod:selector withMethod:@selector(hackWrap)];
    
}

+ (BOOL)supportThisReturnType:(NSMethodSignature*)signature{
    if (!signature) {
        return NO;
    }
    NSString* returnType = [NSString stringWithUTF8String:signature.methodReturnType];
    if (returnType.length != 1) {
        return NO;
    }
    return [@"ilILB@v" containsString:returnType];
}
+ (BOOL)supportThisArgumentType:(NSString*)argumentType{
    if([argumentType isEqualToString:@"@?"]){
        //block
        return YES;
    }
    if (argumentType.length != 1) {
        return NO;
    }
    return [@"ilILBd@" containsString:argumentType];
}
+ (BOOL)supportTheseArguments:(NSMethodSignature*)signature{
    if (!signature) {
        return NO;
    }
    for (int i = 2; i < signature.numberOfArguments; i++) {
        if (![self supportThisArgumentType:[NSString stringWithUTF8String:[signature getArgumentTypeAtIndex:i]]]) {
            return NO;
        }
    }
    return YES;
}

+ (void)swizzleMethod:(SEL)origSelector withMethod:(SEL)newSelector
{
    Class cls = [self class];
    
    Method originalMethod = class_getInstanceMethod(cls, origSelector);
    Method swizzledMethod = class_getInstanceMethod(cls, newSelector);
    
    BOOL didAddMethod = class_addMethod(cls,
                                        origSelector,
                                        method_getImplementation(swizzledMethod),
                                        method_getTypeEncoding(swizzledMethod));
    if (didAddMethod) {
        class_replaceMethod(cls,
                            newSelector,
                            method_getImplementation(originalMethod),
                            method_getTypeEncoding(originalMethod));
    } else {
        method_exchangeImplementations(originalMethod, swizzledMethod);
    }
}

static void* hackWrap(id self, SEL _cmd,...){
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
        [invocation setSelector:@selector(hackWrap)];
        //签名中方法参数的个数，内部包含了self和_cmd，所以参数从第2个开始
        va_start(args, _cmd);
        if (_cmd)
        {
            NSUInteger argumentCount = methodSignature.numberOfArguments;
            for (int i = 2; i < argumentCount; i++) {
                NSString* argumentType = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:i]];
                if ([argumentType isEqualToString:@"i"] || [argumentType isEqualToString:@"I"] ) {
                    int argument = va_arg(args, int);
                    NSLog(@"param: %d",argument);
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"l"] || [argumentType isEqualToString:@"L"] ) {
                    long argument = va_arg(args, long);
                    NSLog(@"param: %ld",argument);
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"B"]) {
                    BOOL argument = va_arg(args, int) != 0;
                    NSLog(@"param: %@",argument ? @"YES":@"NO");
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"d"]) {
                    double argument = va_arg(args, double);
                    NSLog(@"param: %lf",argument);
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"@"]) {
                    id argument = va_arg(args, id);
                    NSLog(@"param: %@",argument);
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"@?"]) {
                    id argument = va_arg(args, id);
                    NSLog(@"param: %@",argument);
                    [invocation setArgument:&argument atIndex:i];
                }
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

static double hackWrapDouble(id self, SEL _cmd,...){
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
        [invocation setSelector:@selector(hackWrapDouble)];
        //签名中方法参数的个数，内部包含了self和_cmd，所以参数从第2个开始
        va_start(args, _cmd);
        if (_cmd)
        {
            NSUInteger argumentCount = methodSignature.numberOfArguments;
            for (int i = 2; i < argumentCount; i++) {
                NSString* argumentType = [NSString stringWithUTF8String:[methodSignature getArgumentTypeAtIndex:i]];
                if ([argumentType isEqualToString:@"i"] || [argumentType isEqualToString:@"I"] ) {
                    int argument = va_arg(args, int);
                    NSLog(@"param: %d",argument);
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"l"] || [argumentType isEqualToString:@"L"] ) {
                    long argument = va_arg(args, long);
                    NSLog(@"param: %ld",argument);
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"B"]) {
                    BOOL argument = va_arg(args, int) != 0;
                    NSLog(@"param: %@",argument ? @"YES":@"NO");
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"d"]) {
                    double argument = va_arg(args, double);
                    NSLog(@"param: %lf",argument);
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"@"]) {
                    id argument = va_arg(args, id);
                    NSLog(@"param: %@",argument);
                    [invocation setArgument:&argument atIndex:i];
                }else if ([argumentType isEqualToString:@"@?"]) {
                    id argument = va_arg(args, id);
                    NSLog(@"param: %@",argument);
                    [invocation setArgument:&argument atIndex:i];
                }
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
