//
//  NSObject+AOP.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/24.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN
typedef void (^AOPResultCallback)(NSArray* resultArray);

@interface NSObject (AOP)

@end

NS_ASSUME_NONNULL_END
