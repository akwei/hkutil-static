//
//  HKPageHelper.h
//  hk_restaurant2
//
//  Created by akwei on 13-6-21.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKPageHelper : NSObject
@property(nonatomic,assign)NSInteger begin;
@property(nonatomic,assign)NSInteger size;
@property(nonatomic,assign)NSInteger end;
@property(nonatomic,assign)NSInteger dataCount;
@property(nonatomic,assign)NSInteger page;
@property(nonatomic,assign)NSInteger totalPage;

-(void)buildWithDataCount:(NSInteger)dataCount size:(NSInteger)size;
-(void)changePage:(NSInteger)page;
-(BOOL)hasMorePage;
@end