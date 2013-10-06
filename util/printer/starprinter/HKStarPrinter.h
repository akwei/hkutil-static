//
//  HKStarPrinter.h
//  huoku_starprinter_arc
//
//  Created by akwei on 13-6-26.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "StarIO/SMPort.h"
#import "HKPrinter.h"

typedef enum
{
    HKCutType_FULL_CUT = 0,
    HKCutType_PARCIAL_CUT = 1,
    HKCutType_FULL_CUT_FEED = 2,
    HKCutType_PARTIAL_CUT_FEED = 3
} HKCutType;


typedef enum{
    HKStarPrinterTextAlignmentLeft = 0,
    HKStarPrinterTextAlignmentCenter = 1,
    HKStarPrinterTextAlignmentRight = 2
}HKStarPrinterTextAlignment;



@interface HKStarPrinter : NSObject
@property(nonatomic,copy)NSString* ip;
@property(nonatomic,copy)NSString* portName;
@property(nonatomic,strong,readonly)NSMutableData* commandData;
@property(nonatomic,assign)NSInteger timeoutMillis;//超时时间，单位:毫秒

//查看状态
-(StarPrinterStatus_2)checkStatus;

//添加命令
-(void)addCommand:(NSData*)data;

//添加命令
- (void)addBytesCommand:(const void *)bytes length:(NSUInteger)length;

//添加文本命令
-(void)addTextCommand:(NSString*)text;

//添加切纸命令
-(void)addCut:(HKCutType)cutType;

-(void)addAlignment:(HKStarPrinterTextAlignment)align;

//添加开启钱箱命令
-(void)addOpenCashDrawer;

//进行打印
-(void)execute;

@end
