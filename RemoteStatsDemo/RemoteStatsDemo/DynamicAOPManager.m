//
//  DynamicAOPManager.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/23.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "DynamicAOPManager.h"
#import "DynamicAOP.h"
@interface DynamicAOPManager ()

@property (nonatomic, strong) NSArray<NSDictionary*>* aopMapping;

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
            _aopMapping = [cachedArr copy];
        }
    }
}

- (void)runMapping{
    for (NSDictionary* mapping in _aopMapping) {
        if (![mapping isKindOfClass:[NSDictionary class]]) {
            continue;
        }
        NSString* className = mapping[@"className"];
        NSString* methodName = mapping[@"methodName"];
        if (className.length == 0 || methodName.length == 0) {
            continue;
        }
        dynamicAopAddMonitor(className, methodName,^(NSArray* result){
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
