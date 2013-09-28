//
//  HKCache.m
//  hkutil2
//
//  Created by akwei on 13-7-26.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKCache.h"
#import "HKTimerInvoker.h"

#pragma mark - HKCacheData

@implementation HKCacheData
+(NSString *)currentDbName{
    return @"hk_cache.sqlite";
}

-(void)reNewUpdateTime{
    NSDate* date = [NSDate date];
    self.updateTime = [date timeIntervalSince1970];
}

@end


#pragma mark - HKCache

@implementation HKCache

-(id)init{
    self = [super init];
    if (self) {
        self.countLimit = 1000;
        self.sizeLimit = 200 * 1024 * 1024;
    }
    return self;
}

-(void)setObject:(id)object forKey:(NSString *)key{
    
}

-(id)objectForKey:(NSString *)key{
    return nil;
}

-(void)cleanExpired{
    
}

-(void)removeForKey:(NSString *)key{
}


-(void)removeAll{
}

@end

#pragma mark - HKSQLiteCache

@interface HKSQLiteCache ()
@end

@implementation HKSQLiteCache

-(id)init{
    self = [super init];
    if (self) {
    }
    return self;
}

-(void)cleanExpired{
    BOOL stop = NO;
    HKObjQuery* query=[HKObjQuery instanceWithDbName:[HKCacheData currentDbName]];
    while (!stop) {
        long long totalSize = [query.sqlQuery numberWithSQL:@"select sum(dataSize) from HKCacheData" params:nil];
        NSInteger size = 0;
        if (totalSize > self.sizeLimit) {
            size = 2;
        }
        else {
            NSUInteger totalCount = [HKCacheData countWithWhere:nil params:nil];
            size = totalCount - self.countLimit;
        }
        if (size > 0) {
            NSArray* list = [HKCacheData listWithWhere:nil params:nil orderBy:@"updateTime asc" begin:0 size:size];
            for (HKCacheData* data in list) {
                [data deleteObj];
            }
        }
        else{
            stop = YES;
        }
    }
    
//    self.timerInvoker = [[HKTimerInvoker alloc] init];
//    self.timerInvoker.time = 30;
//    [self.timerInvoker setJobBlock:^BOOL{
//        //定时计算缓存的数据数量与大小
//        
//        return NO;
//    }];
}

-(void)setObject:(id)object forKey:(NSString *)key{
    @synchronized(self){
        BOOL insert = YES;
        HKCacheData* cacheData = [HKCacheData objWithIdValue:key];
        if (cacheData) {
            insert = NO;
        }
        else{
            cacheData =  [[HKCacheData alloc] init];
            insert = YES;
        }
        cacheData.key = key;
        if ([object isKindOfClass:[NSData class]]) {
            cacheData.data = object;
        }
        else if([object isKindOfClass:[UIImage class]]){
            cacheData.data = UIImageJPEGRepresentation(object, 1.0);
        }
        else if ([object isKindOfClass:[HKCacheData class]]){
            NSLog(@"not support HKCacheData insert to db");
            return;
        }
        cacheData.dataSize = [cacheData.data length];
        [cacheData reNewUpdateTime];
        if (insert) {
            [cacheData saveObj];
        }
        else{
            [cacheData updateObj];
        }
    }
}

-(id)objectForKey:(NSString *)key{
    HKCacheData* data = [HKCacheData objWithIdValue:key];
    if (data) {
        [data reNewUpdateTime];
        [data updateObj];
    }
    return data;
}

-(void)removeForKey:(NSString *)key{
    NSMutableArray* params = [[NSMutableArray alloc] init];
    [params addObject:key];
    [HKCacheData deleteWithWhere:@"key=?" params:params];
}

-(void)removeAll{
    [HKCacheData deleteWithWhere:nil params:nil];
}

@end

#pragma mark - HKMemCache

@interface HKMemCache ()
@property(nonatomic,strong)NSCache* cache;
@end

@implementation HKMemCache

-(id)init{
    self = [super init];
    if (self) {
        self.cache = [[NSCache alloc] init];
        self.cache.countLimit = 200;
        self.cache.totalCostLimit = 200 * 1024 * 1024;
    }
    return self;
}

-(void)setObject:(id)object forKey:(NSString *)key{
    NSData* data;
    HKCacheData* cacheData;
    BOOL new = YES;
    if ([object isKindOfClass:[NSData class]]) {
        data = object;
    }
    else if ([object isKindOfClass:[UIImage class]]){
        data = UIImageJPEGRepresentation(object, 1.0);
    }
    else if ([object isKindOfClass:[HKCacheData class]]){
        new = NO;
        cacheData = object;
    }
    if (new) {
        cacheData = [[HKCacheData alloc] init];
        cacheData.key = key;
        cacheData.data = data;
        cacheData.object = object;
        cacheData.dataSize = [data length];
        NSDate* date = [NSDate date];
        cacheData.updateTime = [date timeIntervalSince1970];
    }
    [self.cache setObject:cacheData forKey:key cost:[data length]];
}

-(id)objectForKey:(NSString *)key{
    HKCacheData* cd = [self.cache objectForKey:key];
    if (cd) {
        [cd reNewUpdateTime];
    }
    return cd;
}

-(void)removeForKey:(NSString *)key{
    [self.cache removeObjectForKey:key];
}

-(void)removeAll{
    [self.cache removeAllObjects];
}

@end

#pragma mark - HKCacheManager

@implementation HKCacheManager

+(HKCache *)getCacheWithType:(NSString *)className{
    static NSMutableDictionary* _cacheDic;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _cacheDic = [[NSMutableDictionary alloc] init];
    });
    @synchronized(self){
        HKCache* cache = [_cacheDic valueForKey:className];
        if (!cache) {
            cache = [[NSClassFromString(className) alloc] init];
        }
        return cache;
    }
}

@end

#pragma mark - HKMemAndSQLiteCache

@interface HKMemAndSQLiteCache ()
@property(nonatomic,strong)HKMemCache* memCache;
@property(nonatomic,strong)HKSQLiteCache* sqliteCache;
@end

@implementation HKMemAndSQLiteCache

-(id)init{
    self = [super init];
    if (self) {
        self.memCache = [[HKMemCache alloc] init];
        self.sqliteCache = [[HKSQLiteCache alloc] init];
    }
    return self;
}

-(void)setObject:(id)object forKey:(NSString *)key{
    [self.sqliteCache setObject:object forKey:key];
}

-(id)objectForKey:(NSString *)key{
    HKCacheData* cd = [self.memCache objectForKey:key];
    if (!cd) {
        cd = [self.sqliteCache objectForKey:key];
        if (cd) {
            cd.object = [UIImage imageWithData:cd.data];
            [self.memCache setObject:cd forKey:key];
        }
    }
    return cd;
}

-(void)removeAll{
    [self.memCache removeAll];
    [self.sqliteCache removeAll];
}

-(void)removeForKey:(NSString *)key{
    [self.memCache removeForKey:key];
    [self.sqliteCache removeForKey:key];
}

@end


