//
//  DAOPProbe.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/30.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>


typedef void (^ResultCallback)(NSArray* resultArray);
NS_ASSUME_NONNULL_BEGIN

@interface DAOPProbe : NSObject

/**
 AOP mapping a single method

 @param className class name
 @param methodName method name
 @param resultBlock after this method invoked, this block will call back to return method arguments and return value
 */

/**
 AOP mapping a single method

 @param className class name
 @param methodName method name
 @param showResult whether to collect result
 @param resultBlock after this method invoked, this block will call back to return method arguments and return value, it set showResult to NO, it will return a empty array
 */
+ (void)runMappingOfClass:(NSString*)className andMethod:(NSString*)methodName showResult:(BOOL)showResult withResult:(ResultCallback)resultBlock;

@end

NS_ASSUME_NONNULL_END
