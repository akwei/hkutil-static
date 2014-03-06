//
//  TimeUtil.h
//  Tuxiazi
//
//  Created by  on 11-8-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKTimeInfo : NSObject
@property(nonatomic,assign)NSInteger year;
@property(nonatomic,assign)NSInteger month;
@property(nonatomic,assign)NSInteger day;
@property(nonatomic,assign)NSInteger hour;
@property(nonatomic,assign)NSInteger minute;
@property(nonatomic,assign)NSInteger second;
@property(nonatomic,assign)NSInteger weekDay;

/**
 获得星期的中文表示
 */
-(NSString*)getWeekDayChinese;

@end

@interface HKTimeUtil : NSObject

+(NSString*)stringWithDate:(NSDate*)date format:(NSString*)format;

+(NSString*)stringWithDoubleDate:(double)doubleDate format:(NSString*)format;

/**
 获得日期信息
 @param date
 */
+(HKTimeInfo*)timeInfoWithDoubleDate:(double)date;

/**
 获得日期信息
 @param date
 */
+(HKTimeInfo*)timeInfoWithDate:(NSDate*)date;

/**
 获得时间差信息
 @param date 开始时间
 @param toDate 结束时间
 @returns 时间差信息
 */
+(HKTimeInfo*)timeInfoWithDate:(NSDate*)date toDate:(NSDate*)toDate;

/**
 获得时间差信息
 @param doubleDate 开始时间
 @param toDoubleDate 结束时间
 @returns 时间差信息
 */
+(HKTimeInfo*)timeInfoWithDoubleDate:(double)doubleDate toDoubleDate:(double)toDoubleDate;

+(double)nowDoubleDate;

+(NSDate*)buildDateWithYear:(NSInteger)year
                      month:(NSInteger)month
                        day:(NSInteger)day
                       hour:(NSInteger)hour
                     minute:(NSInteger)minute
                     second:(NSInteger)second;

//获得时间的当天开始时间
+(NSDate*)getDateBeginWithDate:(NSDate*)date;
//获得时间的当天结束时间
+(NSDate*)getDateEndWithDate:(NSDate*)date;

@end
