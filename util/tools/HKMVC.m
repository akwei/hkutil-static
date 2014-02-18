//
//  HKMVC.m
//  hkutil-static
//
//  Created by akwei on 14-2-18.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKMVC.h"

@implementation HKMVC

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context{
    if ([keyPath isEqualToString:@"result"]) {
        __weak HKKVO* me = self;
        dispatch_async(dispatch_get_main_queue(), ^{
            [me.hkKVODelegate hkKVOOnReceive:me];
        });
    }
}

@end
