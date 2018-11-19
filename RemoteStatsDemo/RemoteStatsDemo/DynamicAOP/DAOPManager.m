//
//  DAOPManager.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/23.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "DAOPManager.h"

@implementation DAOPManager

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

- (BOOL)canMonitorThisMapping:(DAOPMapModel*)mapModel{
    return NO;
}

- (void)runAOPWithResult:(DAOPResultCallback)resultBlock{
    
    static dispatch_once_t onceToken;
    __weak __typeof(self) weakSelf = self;
    dispatch_once(&onceToken, ^{
        [self readAOPMappingFromRom];
        NSLog(@"===========埋点开始================");
        for (DAOPMapModel* mappingModel in weakSelf.aopMapping) {
            if (![self canMonitorThisMapping:mappingModel]) {
                NSLog(@"忽略监听方法 %@-%@",mappingModel.className,mappingModel.methodName);
                continue;
            }
            [DAOPProbe runMappingOfClass:mappingModel.className andMethod:mappingModel.methodName showResult:mappingModel.collectDetail withResult:^(NSArray *resultArray) {
                if (resultBlock) {  \
                    resultBlock(mappingModel,resultArray);
                }
            }];
        }
        NSLog(@"===========埋点结束================");
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
                    DAOPMapModel* mappingModel = [DAOPMapModel modelWithDict:mapping];
                    [mappingArray addObject:mappingModel];

                }
                NSArray* checkedMappingArr = [self mappingListBySafetyCheck:mappingArray];
                if (checkedMappingArr.count) {
                    NSData* cacheData = [DAOPMapModel convertMappingListToData:checkedMappingArr];
                    if (cacheData) {
                        [cacheData writeToFile:[weakSelf cacheFilePath] atomically:YES];
                    }
                }else{
                    [[NSFileManager defaultManager] removeItemAtPath:[self cacheFilePath] error:nil];
                }
            }
        }
        NSLog(@"网络更新埋点映射：%@",jsonObject);
    }];
    [task resume];
}

- (NSArray*)mappingListBySafetyCheck:(NSArray<DAOPMapModel*>*)downloadedMappingList{
    NSMutableArray* checkedMappingListArrM = [NSMutableArray arrayWithCapacity:downloadedMappingList.count];
    for (int i = 0; i < downloadedMappingList.count; i++) {
        DAOPMapModel* modelToCheck = downloadedMappingList[i];
        if (![self canMonitorThisMapping:modelToCheck]) {
            continue;
        }
        Class clazzToCheck = NSClassFromString(modelToCheck.className);
        if (!clazzToCheck) {
            continue;
        }
        BOOL canAdd = YES;
        for (int j = 0; j < checkedMappingListArrM.count; j++) {
            DAOPMapModel* preMapModel = checkedMappingListArrM[j];
            
            if ([modelToCheck.methodName isEqualToString:preMapModel.methodName]) {
                Class preClazz = NSClassFromString(preMapModel.className);
                if ([preClazz isSubclassOfClass:[clazzToCheck class]] || [clazzToCheck isSubclassOfClass:[preClazz class]]) {
                    NSLog(@"禁止监听类树中的同一方法");
                    canAdd = NO;
                    break;
                }
            }
            
        }
        if (canAdd) {
            [checkedMappingListArrM addObject:modelToCheck];
        }
    }
    return [checkedMappingListArrM copy];
}

- (void)readAOPMappingFromRom{
    if([[NSFileManager defaultManager] fileExistsAtPath:[self cacheFilePath]]){
        NSData* cachedData = [NSData dataWithContentsOfFile:[self cacheFilePath]];
        _aopMapping = [DAOPMapModel mappingListFromData:cachedData];
    }
}


- (NSString*)cacheFilePath {
    NSString* docDir = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString* filePath = [docDir stringByAppendingPathComponent:@"aop.cache"];
    return filePath;
}

@end
