//
//  HKTimer.h
//  hkutil-static
//
//  Created by akwei on 14-2-23.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKTimer : NSObject
//间隔执行任务时间
@property(nonatomic,assign)NSTimeInterval delay;
@property(nonatomic,strong)void (^jobBlock)(void);
@property(nonatomic,strong)NSDate* startDate;

/**
 安排任务计划
 */
-(void)schedue;

-(void)stop;

@end
