//
//  HKXPrinter.m
//  hk_5wei_pad
//
//  Created by akwei on 13-11-28.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKXPrinter.h"
#import "HKCommonPrinter.h"
#import "NSData+HKEx.h"

@implementation HKXPrinterStatus
@end

@interface HKXPrinter ()
@property(nonatomic,strong)HKCommonPrinter* cStatusprinter;
@property(nonatomic,strong)HKCommonPrinter* printer;
//开启文本调试模式时，文本内容都存储到此变量中
@property(nonatomic,strong)NSMutableString* debugBuf;
@end

@implementation HKXPrinter

-(id)initWithHost:(NSString *)host timeout:(NSTimeInterval)timeout {
    self = [super init];
    if (self) {
        self.cStatusprinter = [[HKCommonPrinter alloc] initWithHost:host port:4000];
        self.cStatusprinter.timeout = 5;
        self.printer = [[HKCommonPrinter alloc] initWithHost:host port:9100];
        self.printer.timeout = 10;
        self.textDebug = NO;
        self.debugBuf = [[NSMutableString alloc] init];
    }
    return self;
}

-(HKXPrinterStatus *)getStatus{
    HKXPrinterStatus* ps = [[HKXPrinterStatus alloc] init];
    if (self.textDebug) {
        ps.online = YES;
        return ps;
    }
    @try {
        [self.cStatusprinter connect];
        unsigned char cmd[] = {0x1b,0x76};
        [self.cStatusprinter addBytesCommand:cmd length:2];
        [self.cStatusprinter send];
        NSData* data = [self.cStatusprinter read];
        ps.canConnect = YES;
        //打印机信息
        int byte_cashbox = [data getByte:0 bitIndex:2];
        int byte_online = [data getByte:0 bitIndex:3];
        int byte_cover = [data getByte:0 bitIndex:5];
        int byte_feed = [data getByte:0 bitIndex:6];
        
        //打印机信息
        int byte_cut = [data getByte:1 bitIndex:3];
        int byte_unrecoverable_err = [data getByte:1 bitIndex:5];
        int byte_recoverable_err = [data getByte:1 bitIndex:6];
        
        //纸传感器信息
        int byte_page_will_user_up0 = [data getByte:2 bitIndex:0];
        int byte_page_will_user_up1 = [data getByte:2 bitIndex:1];
        int byte_page_empty2 = [data getByte:2 bitIndex:2];
        int byte_page_empty3 = [data getByte:2 bitIndex:3];
        
        if (byte_cashbox == 0) {
            ps.cashBoxHighLevel = NO;
        }
        else{
            ps.cashBoxHighLevel = YES;
        }
        if (byte_online == 0) {
            ps.online = YES;
        }
        else{
            ps.online = NO;
        }
        if (byte_cover == 0) {
            ps.coverOpen = NO;
        }
        else{
            ps.coverOpen = YES;
        }
        if (byte_feed == 0) {
            ps.runPageWithFeed = NO;
        }
        else{
            ps.runPageWithFeed = YES;
        }
        if (byte_cut == 0) {
            ps.cutError = NO;
        }
        else{
            ps.cutError = YES;
        }
        if (byte_unrecoverable_err == 0) {
            ps.unrecoverableError = NO;
        }
        else{
            ps.unrecoverableError = YES;
        }
        if (byte_recoverable_err == 0) {
            ps.recoverableError = NO;
        }
        else{
            ps.recoverableError = YES;
        }
        if (byte_page_will_user_up0 == 0 && byte_page_will_user_up1 == 0) {
            ps.pageWillUseUp = NO;
        }
        else{
            ps.pageWillUseUp = YES;
        }
        if (byte_page_empty2 == 0 && byte_page_empty3 == 0) {
            ps.pageEmpty = NO;
        }
        else{
            ps.pageEmpty = YES;
        }
        return ps;
    }
    @catch (NSException* ex) {
        ps.canConnect = NO;
        ps.online = NO;
        return ps;
    }
    @finally {
        [self.cStatusprinter disconnect];
    }
}

-(void)addCut:(enum HKXPrinterCutType)cutType{
    if (self.textDebug) {
        [self.debugBuf appendString:@"\n------- 剪切 -------\n"];
        return;
    }
    unsigned char cmd[] = {0x1d,0x56,0x41,0};
    if (cutType == HKXPrinterCutTypePart) {
        cmd[2] = 0x41;
    }
    else if (cutType == HKXPrinterCutTypeFull){
        cmd[2] = 0x42;
    }
    [self.printer addBytesCommand:cmd length:4];
}

-(void)addTweetCmd{
    if (self.textDebug) {
        [self.debugBuf appendString:@"\n------- 蜂鸣 -------\n"];
        return;
    }
    unsigned char cmd[] = {0x1b,0x70,0,50,7};
    [self.printer addBytesCommand:cmd length:5];
}

-(void)addInitCmd{
    if (self.textDebug) {
        [self.debugBuf appendString:@"\n------- 初始化 -------\n"];
        return;
    }
    unsigned char cmd[] = {0x1b,0x40};
    [self.printer addBytesCommand:cmd length:2];
}

-(void)addSizeCmd:(NSInteger)size{
    if (self.textDebug) {
        return;
    }
    unsigned char cmd[] = {0x1d,0x21,0x00};
    if (size == 1) {
        cmd[2] = 0x00;
    }
    else if (size == 2){
        cmd[2] = 0x11;
    }
    else if (size == 3){
        cmd[2] = 0x22;
    }
    [self.printer addBytesCommand:cmd length:3];
}

-(void)addAlignmentCmd:(enum HKXPrinterTextAlignment)align{
    if (self.textDebug) {
        return;
    }
    unsigned char cmd[] = {0x1b,0x61,0};
    if (align == HKXPrinterTextAlignmentLeft) {
        cmd[2] = 0;
    }
    else if (align == HKXPrinterTextAlignmentCenter) {
        cmd[2] = 1;
    }
    else if (align == HKXPrinterTextAlignmentRight) {
        cmd[2] = 2;
    }
    [self.printer addBytesCommand:cmd length:3];
}

-(void)addDoPrintCmd:(NSUInteger)n{
    if (self.textDebug) {
        return;
    }
    unsigned char cmd[] = {0x1b,0x64,n};
    [self.printer addBytesCommand:cmd length:3];
}

//-(void)addTableCmd{
//    unsigned char cmd0[] = {0x1b,0x44,10,20,0x00};
//    [self.printer addBytesCommand:cmd0 length:5];
//}

-(void)addTableCmd:(NSArray *)list{
    if (self.textDebug) {
        return;
    }
    NSMutableData* mdata = [[NSMutableData alloc] init];
    unsigned char cmd_begin[] = {0x1b,0x44};
    [mdata appendBytes:cmd_begin length:2];
    for (NSNumber* n in list) {
        unsigned char cmd_n[] = {[n charValue]};
        [mdata appendBytes:cmd_n length:1];
    }
    unsigned char cmd_end[] = {0x00};
    [mdata appendBytes:cmd_end length:1];
    [self.printer addCommand:mdata];
}

-(void)addMoveTabCmd:(NSInteger)num{
    if (self.textDebug) {
        for (int i = 0; i < num; i++) {
            [self.debugBuf appendString:@"  "];
        }
        return;
    }
    for (int i = 0; i < num; i++) {
        unsigned char cmd[] = {0x09};
        [self.printer addBytesCommand:cmd length:1];
    }
}

-(void)addText:(NSString *)text{
    if (self.textDebug) {
        [self.debugBuf appendString:text];
        return;
    }
    [self.printer addTextCommand:text];
}

-(void)printWithNum:(NSInteger)n{
    if (self.textDebug) {
        return ;
    }
    unsigned char cmd[] = {0x1b,0x64,n};
    [self.printer addBytesCommand:cmd length:3];
    
}

-(HKXPrinterStatus *)doCmd{
    if (self.textDebug) {
        NSLog(@"\n== printer text ==\n%@",self.debugBuf);
        return nil;
    }
    [self.printer executeWithBlockSize:16];
    return nil;
}

@end
