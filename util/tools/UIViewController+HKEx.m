//
//  UIViewController+HKEx.m
//  hkutil-static
//
//  Created by akwei on 4/5/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import "UIViewController+HKEx.h"
#import "HKClassUtil.h"

@implementation UIViewController (HKEx)

+(id)defCreate{
    Class clazz = [self class];
    NSString* className= [HKClassUtil getClassName:clazz];
    return [[clazz alloc] initWithNibName:className bundle:nil];
}

@end
