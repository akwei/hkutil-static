//
//  HKXCodeData.m
//  hkutil-static
//
//  Created by akwei on 14-3-27.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKXCode93Data.h"

@interface HKXCode93Data ()
@property(nonatomic,strong)NSMutableData* mData;
@property(nonatomic,strong)NSMutableData* data;
@end

@implementation HKXCode93Data

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.width = 0;
        self.height = 0;
        self.mData = [[NSMutableData alloc] init];
        self.data = [[NSMutableData alloc] init];
    }
    return self;
}

-(void)addCmd:(NSData *)data{
    [self.mData appendData:data];
}

-(void)addBytesCommand:(const void *)bytes length:(NSUInteger)length{
    [self.mData appendBytes:bytes length:length];
}

-(void)addString:(NSString *)string{
    for (int i=0; i<[string length]; i++) {
        unichar c = [string characterAtIndex:i];
        unsigned char ch[] = {c};
        [self.mData appendBytes:ch length:1];
    }
}

-(NSUInteger)getLength{
    return [self.mData length];
}

-(NSData *)getData{
    CGFloat owidth = 0;
    CGFloat oheight = 0;
    if (self.height >= 1 && self.height <= 255) {
        oheight = self.height;
    }
    if (self.width >=2 && self.width <= 6) {
        owidth = self.width;
    }
    if (owidth > 0) {
        unsigned char widthCmd[] = {29,119,owidth};
        [self.data appendBytes:widthCmd length:3];
    }
    if (oheight > 0) {
        unsigned char heightCmd[] = {29,104,oheight};
        [self.data appendBytes:heightCmd length:3];
    }
    NSUInteger len = [self.mData length];
    unsigned char cmd[] = {29,107,72,len};
    [self.data appendBytes:cmd length:4];
    [self.data appendData:self.mData];
    return self.data;
}

@end
