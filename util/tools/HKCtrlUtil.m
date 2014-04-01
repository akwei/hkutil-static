//
//  HKCtrlUtil.m
//  hk_restaurant2
//
//  Created by akwei on 13-6-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKCtrlUtil.h"
#import "HKClassUtil.h"
#import <objc/message.h>

@implementation HKCtrlUtil

+(id)ctrlFromNibWithCalss:(Class)clazz{
    NSString* className= [HKClassUtil getClassName:clazz];
    return [[clazz alloc] initWithNibName:className bundle:nil];
}

+(void)doTargetWithObj:(id)obj method:(NSString*)method sender:(id)sender delegate:(id)senderDelegate{
    NSString* clsName = [HKClassUtil getClassName:[obj class]];
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    [info setValue:sender forKey:@"sender"];
    [info setValue:obj forKey:clsName];
    NSString* omethod = [NSString stringWithFormat:@"%@_%@",clsName,method];
    SEL selector = NSSelectorFromString(omethod);
    objc_msgSend(senderDelegate, selector,info);
}

+(void)doTargetWithObj:(id)obj method:(NSString*)method sender:(id)sender delegate:(id)senderDelegate dic:(NSDictionary*)dic{
    NSString* clsName = [HKClassUtil getClassName:[obj class]];
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    [info setValue:sender forKey:@"sender"];
    [info setValue:obj forKey:clsName];
    [info setValuesForKeysWithDictionary:dic];
    NSString* omethod = [NSString stringWithFormat:@"%@_%@",clsName,method];
    SEL selector = NSSelectorFromString(omethod);
    objc_msgSend(senderDelegate, selector,info);
}

@end
