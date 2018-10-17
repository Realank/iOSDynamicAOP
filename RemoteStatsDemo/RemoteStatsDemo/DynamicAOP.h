//
//  DynamicAOP.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/17.
//  Copyright © 2018 Realank. All rights reserved.
//

#ifndef DynamicAOP_h
#define DynamicAOP_h
typedef void (^ResultCallback)(NSArray* resultArray);

/**
 add a dynamic aop point for specific Class and Method

 @param className Corresponding Class name
 @param selectorName Corresponding Method name for this Class
 @param resultCallBack a invoke information array callback, must use weak self in this block
 @return return 0 means added successfully, -1 means added failed
 */
extern int dynamicAopAddMonitor(NSString* className,NSString* selectorName,ResultCallback resultCallBack);
#endif /* UCARDynamicAOP_h */
