//
//  LanUtil.m
//  huoku_paidui
//
//  Created by 伟 袁 on 12-7-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HKLanUtil.h"

static HKLanUtil* lanUtil=nil;
@implementation HKLanUtil
static NSString *sysloc = @"zh-Hans";

+(HKLanUtil *)instance{
    if (!lanUtil) {
        lanUtil=[[HKLanUtil alloc] init];
    }
    return lanUtil;
}

+(void)setSysLoc:(NSString *)loc{
    @synchronized([HKLanUtil class]){
        sysloc=nil;
        sysloc=loc;     
    }
}

-(NSString*)localWithKey:(NSString *)key comment:(NSString *)comment{
    NSString *path = [[NSBundle mainBundle] pathForResource:@"Localizable"
                                                     ofType:@"strings"                                                       
                                                inDirectory:nil
                                            forLocalization:sysloc];
    NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:path];
    NSString *str = [dict objectForKey:key];
    if (str) {
        return str;
    }
    return key;
}

@end
