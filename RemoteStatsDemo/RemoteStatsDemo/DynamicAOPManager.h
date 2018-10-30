//
//  DynamicAOPManager.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/23.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef void (^ResultCallback)(NSArray* resultArray);
NS_ASSUME_NONNULL_BEGIN

@interface DynamicAOPManager : NSObject

+(instancetype) sharedInstance;

- (void)runAOPWithResult:(ResultCallback)resultBlock;

@end

NS_ASSUME_NONNULL_END
