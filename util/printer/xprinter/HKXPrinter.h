//
//  HKXPrinter.h
//  hk_5wei_pad
//
//  Created by akwei on 13-11-28.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HKCommonPrinter;

@interface HKXPrinterStatus : NSObject

//打印机是否可连接
@property(nonatomic,assign)BOOL canConnect;
//钱箱电平
@property(nonatomic,assign)BOOL cashBoxHighLevel;
//打印机知否在线
@property(nonatomic,assign)BOOL online;
//打印机盖打开状态
@property(nonatomic,assign)BOOL coverOpen;
//是否通过按进纸键走纸
@property(nonatomic,assign)BOOL runPageWithFeed;
//是否有切刀错误
@property(nonatomic,assign)BOOL cutError;
//是否有不可恢复的错误发生
@property(nonatomic,assign)BOOL unrecoverableError;
//是否有可自动恢复的错误发生
@property(nonatomic,assign)BOOL recoverableError;
//是否有探测到打印机纸将尽
@property(nonatomic,assign)BOOL pageWillUseUp;
//打印机是否有纸
@property(nonatomic,assign)BOOL pageEmpty;
@end

@interface HKXPrinter : NSObject

-(id)initWithHost:(NSString*)host timeout:(NSTimeInterval)timeout;

/**
 获得打印机当前状态
 */
-(HKXPrinterStatus*)getStatus;



@end
