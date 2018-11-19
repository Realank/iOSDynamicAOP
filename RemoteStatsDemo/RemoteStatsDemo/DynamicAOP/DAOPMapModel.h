//
//  DAOPMapModel.h
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/30.
//  Copyright © 2018 Realank. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface DAOPMapFilterModel : NSObject<NSSecureCoding>

@property (nonatomic, copy) NSString* key;
@property (nonatomic, copy) NSString* content;
+ (instancetype)modelWithDict:(NSDictionary*)dict;
@end

@interface DAOPMapModel : NSObject<NSSecureCoding>

@property (nonatomic, copy) NSString* className;
@property (nonatomic, copy) NSString* methodName;
@property (nonatomic, copy) NSString* eventCode;
@property (nonatomic, copy) NSString* metaData;
@property (nonatomic, assign) BOOL collectDetail;
@property (nonatomic, strong) NSArray<DAOPMapFilterModel*>* filterList;

- (NSData*)toArchivedDataWithError:(NSError**)errorP;
+ (instancetype)modelWithData:(NSData*)data andError:(NSError**)errorP;
+ (instancetype)modelWithDict:(NSDictionary*)dict;

+ (NSData*)convertMappingListToData:(NSArray<DAOPMapModel*>*)mappingList;
+ (NSArray<DAOPMapModel*>*)mappingListFromData:(NSData*)data;
@end

NS_ASSUME_NONNULL_END
