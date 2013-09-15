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

@end

@interface HKTimeUtil : NSObject

+(NSString*)stringWithDate:(NSDate*)date format:(NSString*)format;

+(NSString*)stringWithDoubleDate:(double)doubleDate format:(NSString*)format;

+(HKTimeInfo*)timeInfoWithDoubleDate:(double)date;

+(HKTimeInfo*)timeInfoWithDate:(NSDate*)date;

+(HKTimeInfo*)timeInfoWithDoubleDate:(double)date toDoubleDate:(double)toDate;

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
