//
//  ArrayMap.m
//  hkutil-static
//
//  Created by akwei on 13-12-4.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKArrayMap.h"

@implementation HKArrayMap{
    NSMutableArray* _array;
    NSMutableDictionary* _dic;
}

-(id)init{
    self = [super init];
    if (self) {
        _array = [[NSMutableArray alloc] init];
        _dic = [[NSMutableDictionary alloc] init];
    }
    return self;
}

-(NSArray *)getArray{
    NSArray* array = [[NSArray alloc] initWithArray:_array];
    return array;
}

-(void)setValue:(id)value forKey:(NSString *)key{
    id obj = [_dic valueForKey:key];
    if (obj) {
        [_array removeObject:obj];
    }
    [_dic setValue:value forKey:key];
    [_array addObject:value];
}

-(id)valueForKey:(NSString *)key{
    return [_dic valueForKey:key];
}

-(void)removeAllObjects{
    [_dic removeAllObjects];
    [_array removeAllObjects];
}

-(void)removeObjectForKey:(NSString *)key{
    id obj = [_dic valueForKey:key];
    [_array removeObject:obj];
    [_dic removeObjectForKey:key];
}

-(void)removeObjectsForKeys:(NSArray *)keys{
    for (NSString* key in keys) {
        [self removeObjectForKey:key];
    }
}

@end
