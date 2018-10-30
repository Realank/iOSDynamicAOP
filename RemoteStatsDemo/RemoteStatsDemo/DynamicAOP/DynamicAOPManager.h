//
//  DynamicAOPManager.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/23.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DynamicAOPProbe.h"
#import "DynamicAOPMappingModel.h"
NS_ASSUME_NONNULL_BEGIN

@interface DynamicAOPManager : NSObject


/**
 singleton method to get instance

 @return unique instance
 */
+(instancetype) sharedInstance;

/**
 main AOP method to monitor a method
 by default, it will use its internal method readAOPMappingFromRom to read cached mapping info, and stored into aopMapping property
 then use these mapping info to run AOP mapping
 afterall use asyncDownloadAOPMapping to download new mapping info

 */
- (void)runAOPWithResult:(ResultCallback)resultBlock;

//methods to override

@property (nonatomic, strong) NSArray<DynamicAOPMappingModel*>* aopMapping;

/**
 read AOP mapping from rom in cacheFilePath, and refresh aopMapping
 */
- (void)readAOPMappingFromRom;

/**
 a cache file path in Document directory

 @return a cache file path in Document directory
 */
- (NSString*)cacheFilePath;

/**
 download new mapping info and refresh cache
 */
- (void)asyncDownloadAOPMapping;
@end

NS_ASSUME_NONNULL_END
