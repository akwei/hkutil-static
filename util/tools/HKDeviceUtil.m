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

@end
