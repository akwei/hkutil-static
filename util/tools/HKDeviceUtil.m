//
//  DeviceUtil.m
//  myutil
//
//  Created by 伟 袁 on 12-7-21.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HKDeviceUtil.h"
#import "HKMyIp.h"


@implementation HKDeviceUtil

+(NSString *)localIp{
    HKMyIp* m=[[HKMyIp alloc] init];
    NSString* ip=[[m deviceIPAdress] copy];
    return ip;
}

+(CGSize)deviceSize{
    CGRect rect = [UIScreen mainScreen].bounds;
    return rect.size;
}

+(BOOL)isBelowiOS6{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 6.0) {
        return NO;
    }
    return YES;
}

+(BOOL)isBelowiOS7{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 7.0) {
        return NO;
    }
    return YES;
}

+(BOOL)isBelowiOS8{
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        return NO;
    }
    return YES;
}

@end
