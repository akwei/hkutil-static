//
//  HKPrinter.h
//  huoku_starprinter_arc
//
//  Created by akwei on 13-7-8.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HKPrinterCfg.h"
#import "HKTableText.h"


@interface HKPrinter : NSObject
@property(nonatomic,strong,readonly)NSMutableData* commandData;
@property(nonatomic,assign)NSInteger timeoutMillis;//超时时间，单位:毫秒

+(NSArray*)searchPrinters;
//打印机当前是否可以打印
-(BOOL)canPrint;

//添加命令
-(void)addCommand:(NSData*)data;

//添加命令
- (void)addBytesCommand:(const void *)bytes length:(NSUInteger)length;

//添加开启钱箱命令
-(void)addOpenCashDrawer;

//进行打印
-(void)execute;

//打印图片
-(void)printImage:(UIImage*)imageToPrint
         maxWidth:(int)maxWidth
       leftMargin:(NSUInteger)leftMargin;

//打印表格式文本
-(void)printTableTextCommand:(HKTableText*)tableText leftMargin:(NSUInteger)leftMargin;

@end
