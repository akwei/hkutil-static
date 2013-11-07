//
//  HKTableViewCell.m
//  hkutil-static
//
//  Created by akwei on 13-11-7.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKTableViewCell.h"

@implementation HKTableViewCell{
    NSMutableDictionary* _info;
}

-(void)setObject:(id)obj forKey:(NSString *)key{
    if (!_info) {
        _info = [[NSMutableDictionary alloc] init];
    }
    [_info setObject:obj forKey:key];
}

-(id)objectForKey:(NSString *)key{
    return [_info valueForKey:key];
}

@end
