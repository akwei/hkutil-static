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
@property(nonatomic,strong)HKCommonPrinter* cprinter;
@end

@implementation HKXPrinter

-(id)initWithHost:(NSString *)host timeout:(NSTimeInterval)timeout {
    self = [super init];
    if (self) {
        self.cprinter = [[HKCommonPrinter alloc] initWithHost:host port:4000];
        self.cprinter.timeout = 5;
    }
    return self;
}

-(HKXPrinterStatus *)getStatus{
    HKXPrinterStatus* ps = [[HKXPrinterStatus alloc] init];
    @try {
        [self.cprinter connect];
        unsigned char cmd[] = {0x1b,0x76};
        [self.cprinter addBytesCommand:cmd length:2];
        [self.cprinter send];
        NSData* data = [self.cprinter read];
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
        [self.cprinter disconnect];
    }
}

@end
