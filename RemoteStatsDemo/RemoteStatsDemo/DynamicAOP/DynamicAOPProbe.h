//
//  DynamicAOPProbe.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/30.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^ResultCallback)(NSString* className, NSString* methodName,NSArray* resultArray);
NS_ASSUME_NONNULL_BEGIN

@interface DynamicAOPProbe : NSObject

/**
 AOP mapping a single method

 @param className class name
 @param methodName method name
 @param resultBlock after this method invoked, this block will call back to return method arguments and return value
 */
+ (void)runMappingOfClass:(NSString*)className andMethod:(NSString*)methodName withResult:(ResultCallback)resultBlock;

@end

NS_ASSUME_NONNULL_END
