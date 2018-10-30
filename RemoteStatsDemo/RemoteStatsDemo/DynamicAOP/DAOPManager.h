//
//  DAOPManager.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/23.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DAOPProbe.h"
#import "DAOPMapModel.h"

typedef void (^DAOPResultCallback)(DAOPMapModel* mapModel,NSArray* resultArray);

NS_ASSUME_NONNULL_BEGIN

@interface DAOPManager : NSObject


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

 @param resultBlock a callback to return AOP result, but if you set collectDetail to NO, it will return a empty array
 */
- (void)runAOPWithResult:(DAOPResultCallback)resultBlock;

//methods to override AOP abuse

@property (nonatomic, strong) NSArray<DAOPMapModel*>* aopMapping;


/**
 **Must Override**
 determine which mapping model should be monitored
 you can add a black list in this method to avoid

 @param mapModel a mapping model fetch from cache
 @return return YES to monitor, otherwise to ignore
 */
- (BOOL)canMonitorThisMapping:(DAOPMapModel*)mapModel;
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
