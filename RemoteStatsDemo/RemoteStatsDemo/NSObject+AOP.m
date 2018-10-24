//
//  NSObject+AOP.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/24.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "NSObject+AOP.h"
#import <objc/runtime.h>
#import <objc/message.h>
static NSMutableDictionary* methodAndBlockMapping;
static NSArray<NSDictionary*>* aopMapping;


@implementation NSObject (AOP)

+(void)load{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self runAOP];
    });
    
}


BOOL _dynamicAopSupportThisReturnType(NSMethodSignature* signature){
    if (!signature) {
        return NO;
    }
    NSString* returnType = [NSString stringWithUTF8String:signature.methodReturnType];
    if (returnType.length != 1) {
        return NO;
    }
    return [@"ilILBd@v" containsString:returnType];
}
BOOL _dynamicAopSupportThisArgumentType(NSString* argumentType){
    if([argumentType isEqualToString:@"@?"]){
        //block
        return YES;
    }
    if (argumentType.length != 1) {
        return NO;
    }
    return [@"ilILBd@" containsString:argumentType];
}
BOOL _dynamicAopSupportTheseArguments(NSMethodSignature* signature){
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

int aopAddMonitor(NSString* className,NSString* selectorName,AOPResultCallback resultCallBack){
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
    if (!_dynamicAopSupportThisReturnType(methodSignature)) {
        
        NSLog(@"不能监听方法-方法返回值不支持 %@",methodUniqueKey);
        return -1;
        
    }else{
        //交换函数
        _aopSwizzleMethod(clazz, selector);
        return 0;
    }
    
}



SEL generateSwizzedSEL(SEL origSelector){
    NSString *swizzedSelectorName = [NSString stringWithFormat:@"ORIG_%@", NSStringFromSelector(origSelector)];
    SEL swizzedSelector = NSSelectorFromString(swizzedSelectorName);
    return swizzedSelector;
}
void _aopSwizzleMethod(Class clazz, SEL origSelector)
{
    
    Method originalMethod = class_getInstanceMethod(clazz, origSelector);
    SEL swizzedSelector = generateSwizzedSEL(origSelector);
    if(!class_respondsToSelector(clazz, swizzedSelector)) {
        BOOL addSuccess = class_addMethod(clazz, swizzedSelector, class_getMethodImplementation(clazz, origSelector), method_getTypeEncoding(originalMethod));
        NSLog(@"add success %d",addSuccess);
    }
    
    class_replaceMethod(clazz,
                        origSelector,
                        (IMP)_objc_msgForward,
                        method_getTypeEncoding(originalMethod));
    
}

-(id)forwardingTargetForSelector:(SEL)aSelector{
    NSLog(@"forwardingTargetForSelector");
    return nil;
}

- (NSMethodSignature *)methodSignatureForSelector:(SEL)aSelector{
    return [[self class] instanceMethodSignatureForSelector:aSelector];
}

static NSString* _aopPutArgument(NSInvocation* fromInvocation,NSInvocation* toInvocation,NSString* argumentType,int atIndex){
    NSString* argumentString = @"";
    if ([argumentType isEqualToString:@"i"] || [argumentType isEqualToString:@"I"] ) {
        int argument = 0;
        [fromInvocation getArgument:&argument atIndex:atIndex];
        argumentString = [NSString stringWithFormat:@"param:(int)%d",argument];
        NSLog(@"%@",argumentString);
        [toInvocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"l"] || [argumentType isEqualToString:@"L"] ) {
        long argument = 0;
        [fromInvocation getArgument:&argument atIndex:atIndex];
        argumentString = [NSString stringWithFormat:@"param:(long)%ld",argument];
        NSLog(@"%@",argumentString);
        [toInvocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"B"]) {
        BOOL argument = NO;
        [fromInvocation getArgument:&argument atIndex:atIndex];
        argumentString = [NSString stringWithFormat:@"param:(BOOL)%@",argument ? @"YES":@"NO"];
        NSLog(@"%@",argumentString);
        [toInvocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"d"]) {
        double argument = 0.0;
        [fromInvocation getArgument:&argument atIndex:atIndex];
        argumentString = [NSString stringWithFormat:@"param:(double)%lf",argument];
        NSLog(@"%@",argumentString);
        [toInvocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"@"]) {
        id argument = nil;
        [fromInvocation getArgument:&argument atIndex:atIndex];
        argumentString = [NSString stringWithFormat:@"param:(NSObject)%@",argument];
        NSLog(@"%@",argumentString);
        [toInvocation setArgument:&argument atIndex:atIndex];
    }else if ([argumentType isEqualToString:@"@?"]) {
        id argument = nil;
        [fromInvocation getArgument:&argument atIndex:atIndex];
        argumentString = [NSString stringWithFormat:@"param:(block)%@",argument];
        NSLog(@"%@",argumentString);
        [toInvocation setArgument:&argument atIndex:atIndex];
    }
    return argumentString;
}

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

- (void)forwardInvocation:(NSInvocation *)anInvocation{
    NSLog(@"===========start================");
    NSLog(@"selector:%@",NSStringFromSelector(anInvocation.selector));
    SEL swizzedSelector = generateSwizzedSEL(anInvocation.selector);
    
    NSInteger argumentsCount = anInvocation.methodSignature.numberOfArguments;
    
    NSInvocation *newInvocation = [NSInvocation invocationWithMethodSignature:anInvocation.methodSignature];
    
    [newInvocation setTarget:anInvocation.target];
    [newInvocation setSelector:swizzedSelector];
    for (int i = 2; i < argumentsCount; i++) {
        _aopPutArgument(anInvocation,newInvocation,[NSString stringWithUTF8String:[anInvocation.methodSignature getArgumentTypeAtIndex:i]],i);
    }
    [newInvocation invoke];
    
    if(anInvocation.methodSignature.methodReturnLength)
    {
        if ([[NSString stringWithUTF8String:anInvocation.methodSignature.methodReturnType] isEqualToString:@"d"]) {
            double callBackObject = 0;
            [newInvocation getReturnValue:&callBackObject];
            NSString* resultString = [NSString stringWithFormat:@"return:(double)%lf",callBackObject];
            NSLog(@"%@",resultString);
        }else{
            void* callBackObject = 0;
            [newInvocation getReturnValue:&callBackObject];
            NSString* resultString = _printReturnValue(callBackObject, [NSString stringWithUTF8String:anInvocation.methodSignature.methodReturnType]);
        }
        
    }
    NSLog(@"===========end================");
    
}


- (void)runAOP{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self readAOPMappingFromRom];
        [self runMapping];
        [self asyncDownloadAOPMapping];
    });
    
}

- (void)asyncDownloadAOPMapping{
    NSURL *url = [NSURL URLWithString:@"http://39.105.128.50:3000/api/list"];
    NSURLRequest *request = [[NSURLRequest alloc]initWithURL:url cachePolicy:NSURLRequestReloadIgnoringLocalCacheData timeoutInterval:10];
    NSURLSession *session = [NSURLSession sharedSession];
    __weak __typeof(self) weakSelf = self;
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData *data, NSURLResponse *response, NSError *error) {
        if (!data || error) {
            return;
        }
        NSDictionary* jsonObject = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingAllowFragments error:nil];
        if ([jsonObject isKindOfClass:[NSDictionary class]] && [jsonObject[@"status"] isEqualToString:@"success"]) {
            NSArray* mappingRawArray = jsonObject[@"monitor"];
            NSMutableArray* mappingArray = [NSMutableArray array];
            if ([mappingRawArray isKindOfClass:[NSArray class]]) {
                for (NSDictionary* mapping in mappingRawArray) {
                    NSString* className = mapping[@"className"];
                    NSString* methodName = mapping[@"methodName"];
                    if (className.length == 0 || methodName.length == 0) {
                        continue;
                    }
                    [mappingArray addObject:@{@"className":className,@"methodName":methodName}];
                    
                }
                if (mappingArray.count) {
                    NSData* cacheData = [NSKeyedArchiver archivedDataWithRootObject:[mappingArray copy] requiringSecureCoding:YES error:nil];
                    [cacheData writeToFile:[weakSelf cacheFilePath] atomically:YES];
                }
            }
        }
        NSLog(@"%@",jsonObject);
    }];
    [task resume];
}

- (void)readAOPMappingFromRom{
    if([[NSFileManager defaultManager] fileExistsAtPath:[self cacheFilePath]]){
        NSData* cachedData = [NSData dataWithContentsOfFile:[self cacheFilePath]];
        NSError* error = nil;
        NSArray* cachedArr = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSDictionary class],[NSArray class], nil] fromData:cachedData error:&error];
        if (error) {
            NSLog(@"error:%@",error);
        }else if (cachedArr && [cachedArr isKindOfClass:[NSArray class]]) {
            aopMapping = [cachedArr copy];
        }
    }
}

- (void)runMapping{
    for (NSDictionary* mapping in aopMapping) {
        if (![mapping isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSString* className = mapping[@"className"];
        NSString* methodName = mapping[@"methodName"];
        if (className.length == 0 || methodName.length == 0) {
            continue;
        }
        
        aopAddMonitor(className, methodName,^(NSArray* result){
            NSLog(@"=result:%@",result);
        });
    }
    
}


- (NSString*)cacheFilePath {
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* filePath = [docDir stringByAppendingPathComponent:@"aop.cache"];
    return filePath;
}



@end
