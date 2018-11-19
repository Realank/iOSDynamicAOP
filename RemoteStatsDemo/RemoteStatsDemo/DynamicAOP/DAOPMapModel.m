//
//  DAOPMapModel.m
//  RemoteStatsDemo
//
//  Created by Realank on 2018/10/30.
//  Copyright © 2018 Realank. All rights reserved.
//

#import "DAOPMapModel.h"

BOOL keywordsTest(NSString* string){
    NSString *pattern = @"^[a-zA-Z_][\\w_]{0,50}$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult* result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    return result != nil;
}
BOOL methodTest(NSString* string){
    NSString *pattern = @"^[a-zA-Z_][\\w_:]{0,50}$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult* result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    return result != nil;
}
BOOL contentTest(NSString* string){
    NSString *pattern = @"^[\\w_]{0,50}$";
    NSError *error = nil;
    NSRegularExpression *regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
    NSTextCheckingResult* result = [regex firstMatchInString:string options:0 range:NSMakeRange(0, string.length)];
    return result != nil;
}

@implementation DAOPMapFilterModel

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        if (!aDecoder) {
            return self;
        }
        //        _name = [aDecoder decodeObjectForKey:@"name"];
        _key = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"key"];
        _content = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"content"];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_key forKey:@"key"];
    [aCoder encodeObject:_content forKey:@"content"];
}

+ (instancetype)modelWithDict:(NSDictionary*)dict{
    if ([dict isKindOfClass:[NSDictionary class]]) {
        NSString* key = dict[@"key"];
        NSString* content = dict[@"content"];
        if (![key isKindOfClass:[NSString class]] || ![content isKindOfClass:[NSString class]] ) {
            return nil;
        }
        if (key.length == 0 || content.length == 0) {
            return nil;
        }
        if (!keywordsTest(key) || !contentTest(content)) {
            NSLog(@"filter illegal");
            return nil;
        }
        DAOPMapFilterModel* filterModel = [[DAOPMapFilterModel alloc] init];
        filterModel.key = key;
        filterModel.content = content;
        return filterModel;
    }
    return nil;
    
}

@end

@implementation DAOPMapModel

+ (BOOL)supportsSecureCoding{
    return YES;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder{
    if (self = [super init]) {
        if (!aDecoder) {
            return self;
        }
        //        _name = [aDecoder decodeObjectForKey:@"name"];
        _className = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"className"];
        _methodName = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"methodName"];
        _eventCode = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"eventCode"];
        _metaData = [aDecoder decodeObjectOfClass:[NSString class] forKey:@"metaData"];
        _collectDetail = [aDecoder decodeBoolForKey:@"collectDetail"];
        NSArray* filterListArr = [aDecoder decodeObjectForKey:@"filterList"];
        _filterList = [filterListArr copy];
    }
    return self;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    [aCoder encodeObject:_className forKey:@"className"];
    [aCoder encodeObject:_methodName forKey:@"methodName"];
    [aCoder encodeObject:_eventCode forKey:@"eventCode"];
    [aCoder encodeObject:_metaData forKey:@"metaData"];
    [aCoder encodeBool:_collectDetail forKey:@"collectDetail"];
    [aCoder encodeObject:_filterList forKey:@"filterList"];
}

- (NSData *)toArchivedDataWithError:(NSError * _Nullable __autoreleasing *)errorP{
    NSData* cacheData = [NSKeyedArchiver archivedDataWithRootObject:self requiringSecureCoding:YES error:errorP];
    return cacheData;
}

+ (instancetype)modelWithData:(NSData *)data andError:(NSError * _Nullable __autoreleasing * _Nullable)errorP{
    DAOPMapModel* mappingModel = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[DAOPMapModel class],[DAOPMapFilterModel class],[NSArray class], nil] fromData:data error:errorP];
    return mappingModel;
}

+ (instancetype)modelWithDict:(NSDictionary*)dict{
    if (!dict || ![dict isKindOfClass:[NSDictionary class]]) {
        return nil;
    }
    NSString* className = dict[@"className"];
    NSString* methodName = dict[@"methodName"];
    NSString* eventCode = dict[@"eventCode"];
    NSString* metaData = dict[@"metaData"];
    BOOL collectDetail = [dict[@"collectDetail"] boolValue];
    NSMutableArray* array = [NSMutableArray arrayWithCapacity:10];
    NSArray* filterListArray = dict[@"filterList"];
    if (filterListArray && [filterListArray isKindOfClass:[NSArray class]]) {
        for (NSDictionary* filterDict in filterListArray) {
            DAOPMapFilterModel* filterModel = [DAOPMapFilterModel modelWithDict:filterDict];
            if (filterModel) {
                [array addObject:filterModel];
            }
        }
    }
    if (!keywordsTest(className) || !methodTest(methodName) || !keywordsTest(eventCode)) {
        return nil;
    }
    DAOPMapModel* model = [[DAOPMapModel alloc] init];
    model.className = className;
    model.methodName = methodName;
    model.eventCode = eventCode;
    model.metaData = metaData;
    model.collectDetail = collectDetail;
    model.filterList = [array copy];
    return model;
}

+ (NSData*)convertMappingListToData:(NSArray<DAOPMapModel*>*)mappingList{
    NSMutableArray* mappingArray = [NSMutableArray arrayWithCapacity:mappingList.count];
    for (DAOPMapModel* mapping in mappingList) {
        NSData* data = [mapping toArchivedDataWithError:nil];
        if (data) {
            [mappingArray addObject:data];
        }
    }
    if (mappingArray.count) {
        NSData* cacheData = [NSKeyedArchiver archivedDataWithRootObject:[mappingArray copy] requiringSecureCoding:YES error:nil];
        return cacheData;
    }else{
        return nil;
    }
}
+ (NSArray<DAOPMapModel*>*)mappingListFromData:(NSData*)data{
    NSError* error = nil;
    NSArray* cachedArr = [NSKeyedUnarchiver unarchivedObjectOfClasses:[NSSet setWithObjects:[NSData class],[NSArray class], nil] fromData:data error:&error];
    if (error) {
        NSLog(@"error:%@",error);
        return nil;
    }else if (cachedArr && [cachedArr isKindOfClass:[NSArray class]]) {
        NSMutableArray* mappingArr = [NSMutableArray arrayWithCapacity:10];
        for (NSData* data in cachedArr) {
            DAOPMapModel* mappingModel = [DAOPMapModel modelWithData:data andError:nil];
            if (mappingModel) {
                [mappingArr addObject:mappingModel];
            }
        }
        return [mappingArr copy];
    }else{
        return nil;
    }
}
@end
