//
//  DynamicAOPMappingModel.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/30.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DynamicAOPMappingFilterModel : NSObject<NSSecureCoding>

@property (nonatomic, copy) NSString* key;
@property (nonatomic, copy) NSString* content;
+ (instancetype)modelWithDict:(NSDictionary*)dict;
@end

@interface DynamicAOPMappingModel : NSObject<NSSecureCoding>

@property (nonatomic, copy) NSString* className;
@property (nonatomic, copy) NSString* methodName;
@property (nonatomic, copy) NSString* eventCode;
@property (nonatomic, copy) NSString* mark;
@property (nonatomic, assign) BOOL collectDetail;
@property (nonatomic, strong) NSArray<DynamicAOPMappingFilterModel*>* filterList;

- (NSData*)toArchivedDataWithError:(NSError**)errorP;
+ (instancetype)modelWithData:(NSData*)data andError:(NSError**)errorP;
+ (instancetype)modelWithDict:(NSDictionary*)dict;

+ (NSData*)convertMappingListToData:(NSArray<DynamicAOPMappingModel*>*)mappingList;
+ (NSArray<DynamicAOPMappingModel*>*)mappingListFromData:(NSData*)data;
@end

NS_ASSUME_NONNULL_END
