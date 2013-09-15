//
//  HKPageHelper.m
//  hk_restaurant2
//
//  Created by akwei on 13-6-21.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKPageHelper.h"

@implementation HKPageHelper

-(id)init{
    self = [super init];
    if (self) {
        self.begin = 0;
        self.size = 0;
        self.end = 0;
        self.dataCount = 0;
        self.page = 1;
        self.totalPage = 0;
    }
    return self;
}

-(void)buildWithDataCount:(NSInteger)dataCount size:(NSInteger)size{
    self.dataCount = dataCount;
    self.size = size;
    self.totalPage = (self.dataCount + self.size - 1) / self.size;
}

-(void)changePage:(NSInteger)page{
    self.page = page;
    if (self.page < 0) {
        NSLog(@"HKPageHelper page %d < 0",self.page);
    }
    self.begin = self.size * (page - 1);
    self.end = self.begin + self.size - 1;
    if (self.end >= self.dataCount) {
        self.end = self.dataCount - 1;
    }
}

-(BOOL)hasMorePage{
    if (self.page < self.totalPage) {
        return YES;
    }
    return NO;
}

@end