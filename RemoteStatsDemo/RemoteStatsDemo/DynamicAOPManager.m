//
//  DynamicAOPManager.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/23.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "DynamicAOPManager.h"
#import "Aspects.h"
#import <objc/runtime.h>
@interface DynamicAOPManager ()

@property (nonatomic, strong) NSArray<NSDictionary*>* aopMapping;
@property (nonatomic, strong) NSMutableDictionary* methodAndBlockMapping;
@end

@implementation DynamicAOPManager

+(instancetype) sharedInstance {
    static dispatch_once_t pred;
    static id shared = nil; //设置成id类型的目的，是为了继承
    dispatch_once(&pred, ^{
        shared = [[super alloc] initUniqueInstance];
    });
    return shared;
}

-(instancetype) initUniqueInstance {
    
    if (self = [super init]) {
        
    }
    
    return self;
}

- (void)runAOPWithResult:(ResultCallback)resultBlock{
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self readAOPMappingFromRom];
        [self runMappingWithResult:resultBlock];
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
            _aopMapping = [cachedArr copy];
        }
    }
}

NSString* _printReturnValue(void* returnValue,NSString* returnType){
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

NSString* _printArgument(NSString* argumentType,id argument){
    NSString* argumentString = @"";
    if ([argumentType isEqualToString:@"i"] || [argumentType isEqualToString:@"I"] ) {
        argumentString = [NSString stringWithFormat:@"param:(int)%@",argument];
        NSLog(@"%@",argumentString);
        return argumentString;
    }else if ([argumentType isEqualToString:@"l"] || [argumentType isEqualToString:@"L"] ) {
        argumentString = [NSString stringWithFormat:@"param:(long)%@",argument];
        NSLog(@"%@",argumentString);
        return argumentString;
    }else if ([argumentType isEqualToString:@"B"]) {

        argumentString = [NSString stringWithFormat:@"param:(BOOL)%@",argument ? @"YES":@"NO"];
        NSLog(@"%@",argumentString);
        return argumentString;
    }else if ([argumentType isEqualToString:@"d"]) {
        argumentString = [NSString stringWithFormat:@"param:(double)%@",argument];
        NSLog(@"%@",argumentString);
        return argumentString;
    }else if ([argumentType isEqualToString:@"@"]) {
        argumentString = [NSString stringWithFormat:@"param:(%@)%@",[argument class],argument];
        NSLog(@"%@",argumentString);
        return argumentString;
    }else if ([argumentType isEqualToString:@"@?"]) {
        argumentString = [NSString stringWithFormat:@"param:(block)%@",argument];
        NSLog(@"%@",argumentString);
        return argumentString;
    }
    return argumentString;
}

- (void)runMappingWithResult:(ResultCallback)resultBlock{
    _methodAndBlockMapping = [NSMutableDictionary dictionaryWithCapacity:5];
    for (NSDictionary* mapping in _aopMapping) {
        if (![mapping isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSString* className = mapping[@"className"];
        NSString* methodName = mapping[@"methodName"];
        if (className.length == 0 || methodName.length == 0) {
            NSLog(@"不能监听方法-要监听的类名或方法名为空");
            continue;
        }
        NSString* methodUniqueKey = [NSString stringWithFormat:@"%@-%@",className,methodName];
        Class clazz = NSClassFromString(className);
        if (!clazz) {
            NSLog(@"不能监听方法-要监听的类找不到 %@",methodUniqueKey);
            continue;
        }
        SEL selector = NSSelectorFromString(methodName);
        Method method = class_getInstanceMethod(clazz, selector);
        if(!method){
            NSLog(@"不能监听方法-方法找不到 %@",methodUniqueKey);
            continue;
        }
        NSError* error = nil;
        __weak __typeof(self) weakSelf = self;
        [clazz aspect_hookSelector:selector withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> info){
            NSInvocation* anInvocation = info.originalInvocation;
            NSMethodSignature *methodSignature = [clazz instanceMethodSignatureForSelector:selector];
            NSMutableArray* aopArray = [NSMutableArray arrayWithCapacity:10];
            NSLog(@"===========start================");
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
                    NSLog(@"%@",resultString);
                    [aopArray addObject:resultString];
                }else{
                    void* callBackObject = 0;
                    [anInvocation getReturnValue:&callBackObject];
                    NSString* resultString = _printReturnValue(callBackObject, [NSString stringWithUTF8String:anInvocation.methodSignature.methodReturnType]);
                    [aopArray addObject:resultString];
                }
                
            }
            NSLog(@"===========end================");
            ResultCallback callBack = weakSelf.methodAndBlockMapping[methodUniqueKey];
            if(callBack){
                callBack([aopArray copy]);
            }
        } error:&error];
        if (error) {
            NSLog(@"mapping error for %@-%@",className,methodName);
        }else{
            if (resultBlock) {
                _methodAndBlockMapping[methodUniqueKey] = resultBlock;
            }
        }
    }
    
}


- (NSString*)cacheFilePath {
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* filePath = [docDir stringByAppendingPathComponent:@"aop.cache"];
    return filePath;
}

@end
