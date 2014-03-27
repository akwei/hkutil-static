//
//  HKXCodeData.h
//  hkutil-static
//
//  Created by akwei on 14-3-27.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKXCode93Data : NSObject
@property(nonatomic,assign)CGFloat width;// 2 ≤ w ≤ 6
@property(nonatomic,assign)CGFloat height;// 1 ≤ h ≤ 255


-(void)addCmd:(NSData*)data;

-(void)addBytesCommand:(const void *)bytes length:(NSUInteger)length;

/**
 添加的字符串必须都是ASCII标准字符
 */
-(void)addString:(NSString*)string;

-(NSUInteger)getLength;

-(NSData*)getData;

@end
