//
//  HKCache.h
//  hkutil2
//
//  Created by akwei on 13-7-26.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKSQLQuery.h"

@interface HKCacheData : NSObject
//key
@property(nonatomic,copy)NSString* key;
@property(nonatomic,strong)UIImage* object;
//缓存数据
@property(nonatomic,strong)NSData* data;
//缓存数据大小
@property(nonatomic,assign)NSUInteger dataSize;
//最后更新时间
@property(nonatomic,assign)NSUInteger updateTime;
@end

@interface HKCache : NSObject
//最大字节数
@property(nonatomic,assign)unsigned long long sizeLimit;
//最大数目
@property(nonatomic,assign)NSUInteger countLimit;
-(void)setObject:(id)object forKey:(NSString*)key;
-(id)objectForKey:(NSString*)key;
//清除过期数据，或者是删除多数据
-(void)cleanExpired;
@end


@interface HKFileCache : HKCache
@end

@interface HKSQLiteCache : HKCache
@end

@interface HKMemCache : HKCache
@end

@interface HKCacheManager : NSObject
+(HKCache*)getCacheWithType:(NSString*)className;
@end

@interface HKMemAndSQLiteCache : HKCache
@end
