//
//  HKCtrlUtil.m
//  hk_restaurant2
//
//  Created by akwei on 13-6-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKCtrlUtil.h"
#import <objc/runtime.h>
//#import <objc/message.h>

@implementation HKCtrlUtil

+(id)ctrlFromNibWithCalss:(Class)clazz{
    NSString* className=[NSString stringWithCString:class_getName(clazz) encoding:NSUTF8StringEncoding];
    return [[clazz alloc] initWithNibName:className bundle:nil];
}

@end
