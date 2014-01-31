//
//  HKXPrinter.h
//  hk_5wei_pad
//
//  Created by akwei on 13-11-28.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@class HKCommonPrinter;

enum HKXPrinterTextAlignment {
    HKXPrinterTextAlignmentLeft = 0,
    HKXPrinterTextAlignmentCenter = 1,
    HKXPrinterTextAlignmentRight = 2
};

enum HKXPrinterCutType {
    HKXPrinterCutTypePart = 0,
    HKXPrinterCutTypeFull = 1
};

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
@property(nonatomic,assign)BOOL textDebug;

-(id)initWithHost:(NSString*)host timeout:(NSTimeInterval)timeout;

/**
 获得打印机当前状态
 */
-(HKXPrinterStatus*)getStatus;

/**
 添加切纸命令
 @param cutType 切纸方式
 */
-(void)addCut:(enum HKXPrinterCutType)cutType;

/**
 添加蜂鸣器命令
 */
-(void)addTweetCmd;

/**
 添加初始化命令
*/
-(void)addInitCmd;

/**
 添加文笔大小命令
 @param size 文本大小 1 - 3
 */
-(void)addSizeCmd:(NSInteger)size;

/**
 添加打印对齐命令
 @param align 对齐方式
 */
-(void)addAlignmentCmd:(enum HKXPrinterTextAlignment)align;

/**
 添加打印命令，并换n行
 @param n 换行n
 */
-(void)addDoPrintCmd:(NSUInteger)n;

/**
 添加制表符命令
 @param list 集合中是制表符间隔数
 */
-(void)addTableCmd:(NSArray*)list;

/**
 添加移动制表符命令
 @param num 移动制表符数量
 */
-(void)addMoveTabCmd:(NSInteger)num;

/**
 添加要打印的文本信息
 @param text 文本信息
 */
-(void)addText:(NSString*)text;

/**
 打印添加的命令，并走纸n行
 @param n 走纸行数
 */
-(void)printWithNum:(NSInteger)n;

/**
 执行打印机命令
 @return 返回打印机当前状态(如果开启了打印状态返回模式，没有开启时，返回nil)
 */
-(HKXPrinterStatus*)doCmd;

@end
