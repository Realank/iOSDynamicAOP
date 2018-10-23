//
//  DynamicAOPManager.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/23.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DynamicAOPManager : NSObject

+(instancetype) sharedInstance;

- (void)runAOP;

@end

NS_ASSUME_NONNULL_END
