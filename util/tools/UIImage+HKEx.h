//
//  UIImage+HKEx.h
//  hkutil-static
//
//  Created by akwei on 13-10-30.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (HKEx)

/**
 创建一个颜色为color的图片
 @param color 图片的颜色
 */
+(UIImage*)imageWithColor:(UIColor*)color;

/**
 缩放到最宽边
 @param maxWidth 最宽边
 */
-(UIImage*)toMaxWidth:(CGFloat)maxWidth;

/**
 缩放到最宽边像素
 @param maxWidth 最宽边像素
 */
-(UIImage*)toMaxWidthPixel:(CGFloat)maxWidthPixel;

@end
