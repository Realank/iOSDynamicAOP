//
//  DynamicAOPManager.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/23.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "DynamicAOPManager.h"

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
    __weak __typeof(self) weakSelf = self;
    dispatch_once(&onceToken, ^{
        [self readAOPMappingFromRom];
        for (DynamicAOPMappingModel* mappingModel in weakSelf.aopMapping) {
            [DynamicAOPProbe runMappingOfClass:mappingModel.className andMethod:mappingModel.methodName withResult:^(NSString* className, NSString* methodName,NSArray *resultArray) {
                if (resultBlock) {
                    resultBlock(className,methodName,resultArray);
                }
            }];
        }
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
                    DynamicAOPMappingModel* mappingModel = [DynamicAOPMappingModel modelWithDict:mapping];
                    [mappingArray addObject:mappingModel];

                }
                if (mappingArray.count) {
                    NSData* cacheData = [DynamicAOPMappingModel convertMappingListToData:mappingArray];
                    if (cacheData) {
                        [cacheData writeToFile:[weakSelf cacheFilePath] atomically:YES];
                    }
                }else{
                    [[NSFileManager defaultManager] removeItemAtPath:[self cacheFilePath] error:nil];
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
        _aopMapping = [DynamicAOPMappingModel mappingListFromData:cachedData];
    }
}


- (NSString*)cacheFilePath {
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* filePath = [docDir stringByAppendingPathComponent:@"aop.cache"];
    return filePath;
}

@end
