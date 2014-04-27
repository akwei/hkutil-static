//
//  KVEncoder.m
//  huoku_paidui5
//
//  Created by akwei on 12-8-23.
//  Copyright (c) 2012年 akwei. All rights reserved.
//

#import "HKKVEncoder.h"
#import "HKDataUtil.h"

@implementation HKKVEncoder

+(NSString *)exec:(NSDictionary *)dic{
    NSMutableArray* arr=[[NSMutableArray alloc] init];
    for (NSString* key in dic) {
        [arr addObject:key];
    }
    if ([arr count]==0) {
        return @"";
    }
    NSArray* array = [arr sortedArrayUsingSelector:@selector(compare:)];
    NSMutableString* sbuf=[[NSMutableString alloc] init];
    for (NSString* key in array) {
        id value = [dic valueForKey:key];
        [sbuf appendFormat:@"%@=%@&",key,[HKDataUtil encodeURL:value]];
    }
    [sbuf deleteCharactersInRange:NSMakeRange([sbuf length]-1, 1)];
    return sbuf;
}

@end
