//
//  TimeUtil.m
//  Tuxiazi
//
//  Created by  on 11-8-28.
//  Copyright 2011年 __MyCompanyName__. All rights reserved.
//

#import "HKTimeUtil.h"

@implementation HKTimeInfo

-(NSString *)getWeekDayChinese{
    if (self.weekDay == 1) {
        return @"星期日";
    }
    if (self.weekDay == 2) {
        return @"星期一";
    }
    if (self.weekDay == 3) {
        return @"星期二";
    }
    if (self.weekDay == 4) {
        return @"星期三";
    }
    if (self.weekDay == 5) {
        return @"星期四";
    }
    if (self.weekDay == 6) {
        return @"星期五";
    }
    if (self.weekDay == 7) {
        return @"星期六";
    }
    return @"";
}

@end

@implementation HKTimeUtil

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

+(NSString *)stringWithDate:(NSDate *)date format:(NSString *)format{
    NSDateFormatter *fmt=[[NSDateFormatter alloc] init];
	[fmt setTimeZone:[NSTimeZone timeZoneWithAbbreviation:@"GMT+8:00"]];
	[fmt setLocale:[[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"]];
	[fmt setDateFormat:format];
    NSString* v=[fmt stringFromDate:date];
    return v;
}

+(NSString *)stringWithDoubleDate:(double)doubleDate format:(NSString *)format{
    NSDate* date=[[NSDate alloc] initWithTimeIntervalSince1970:doubleDate];
    NSString* value = [HKTimeUtil stringWithDate:date format:format];
    return value;
}

+(HKTimeInfo *)timeInfoWithDate:(NSDate *)date{
    NSCalendar* cal=[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit | NSWeekdayCalendarUnit;
    NSDateComponents* cps=[cal components:unitFlags fromDate:date];
    if (!cps) {
        return nil;
    }
    HKTimeInfo* info=[[HKTimeInfo alloc] init];
    info.year=[cps year];
    info.month=[cps month];
    info.day=[cps day];
    info.hour=[cps hour];
    info.minute=[cps minute];
    info.second=[cps second];
    info.weekDay = [cps weekday];
    return info;
}

+(HKTimeInfo *)timeInfoWithDoubleDate:(double)date{
    NSDate* ndate=[NSDate dateWithTimeIntervalSince1970:date];
    return [self timeInfoWithDate:ndate];
}

+(HKTimeInfo *)timeInfoWithDoubleDate:(double)date toDoubleDate:(double)toDate{
    NSDate* ndate=[NSDate dateWithTimeIntervalSince1970:date];
    NSDate* nToDate=[NSDate dateWithTimeIntervalSince1970:toDate];
    NSCalendar* cal=[[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    NSUInteger unitFlags = NSHourCalendarUnit | NSMinuteCalendarUnit | NSSecondCalendarUnit | NSDayCalendarUnit | NSMonthCalendarUnit | NSYearCalendarUnit;
    NSDateComponents* cps=[cal components:unitFlags fromDate:ndate toDate:nToDate options:0];
    if (!cps) {
        return nil;
    }
    HKTimeInfo* info=[[HKTimeInfo alloc] init];
    info.year=[cps year];
    info.month=[cps month];
    info.day=[cps day];
    info.hour=[cps hour];
    info.minute=[cps minute];
    info.second=[cps second];
    info.weekDay = 0;
    return info;
}

+(double)nowDoubleDate{
    return [[NSDate date] timeIntervalSince1970];
}

+(NSDate*)buildDateWithYear:(NSInteger)year
                      month:(NSInteger)month
                       day:(NSInteger)day
                       hour:(NSInteger)hour
                     minute:(NSInteger)minute
                     second:(NSInteger)second{

    NSDate* now = [NSDate date];

    HKTimeInfo* info = [HKTimeUtil timeInfoWithDate:now];
    NSDateComponents* cmp = [[NSDateComponents alloc] init];
    if (year < 1) {
        year = info.year;
    }
    if (month < 1) {
        month = info.month;
    }
    if (day < 1) {
        day = info.day;
    }
    if (hour < 0) {
        hour = info.hour;
    }
    if (minute < 0) {
        minute = info.minute;
    }
    if (second < 0) {
        second = info.second;
    }
    cmp.year = year;
    cmp.month = month;
    cmp.day = day;
    cmp.hour = hour;
    cmp.minute = minute;
    cmp.second = second;
    NSCalendar* cal = [[NSCalendar alloc] initWithCalendarIdentifier:NSGregorianCalendar];
    return [cal dateFromComponents:cmp];
}

+(NSDate *)getDateBeginWithDate:(NSDate *)date{
    HKTimeInfo* tinfo = [self timeInfoWithDate:date];
    tinfo.hour = 0;
    tinfo.minute = 0;
    tinfo.second = 0;
    NSDate* d = [self buildDateWithYear:tinfo.year month:tinfo.month day:tinfo.day hour:tinfo.hour minute:tinfo.minute second:tinfo.second];
    return d;
}

+(NSDate *)getDateEndWithDate:(NSDate *)date{
    HKTimeInfo* tinfo = [self timeInfoWithDate:date];
    tinfo.hour = 23;
    tinfo.minute = 59;
    tinfo.second = 59;
    NSDate* d = [self buildDateWithYear:tinfo.year month:tinfo.month day:tinfo.day hour:tinfo.hour minute:tinfo.minute second:tinfo.second];
    return d;
}

@end
