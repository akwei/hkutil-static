//
//  HKClassUtil.m
//  hkutil-static
//
//  Created by akwei on 14-3-31.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKClassUtil.h"
#import <objc/message.h>

@implementation HKClassUtil

+(NSString *)getClassName:(Class)clazz{
    NSString* className=[NSString stringWithCString:class_getName(clazz) encoding:NSUTF8StringEncoding];
    return className;
}

@end
