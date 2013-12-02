//
//  NSString+HKEx.h
//  hkutil-static
//
//  Created by akwei on 13-11-10.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HKEx)

/**
 仿java String.indexOf，查询字符串在其中第一个出现的位置
 @param str 查询的字符串
 */
-(NSInteger)indexOf:(NSString*)str;

@end
