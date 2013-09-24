//
//  UIView+HKEx.h
//  hkutil2
//
//  Created by akwei on 13-7-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (HKEx)

/**
 计算内容最大高度
 **/
-(CGFloat)getContentHeight;

/**
 计算内容最大宽度
 **/
-(CGFloat)getContentWidth;

/**
 在refView下边添加view
 @param view 添加的view
 @param refView 在当前view中需要位置参考的view
 @param distance 与refView下边距离
 @param left 与refView左边界的距离 >0向右 <0向左
 @param right 与refView右边界的距离 >0向右 <0向左
 当left right其中一个=0，一个!=0时，选取!=0的值使用,left right 都!=0时，取left计算
 **/
-(void)addSubview:(UIView*)view below:(UIView*)refView distance:(CGFloat)distance left:(CGFloat)left right:(CGFloat)right;

/**
 在refView上边添加view
 @param view 添加的view
 @param refView 在当前view中需要位置参考的view
 @param distance 与refView上边距离
 @param left 与refView左边界的距离 >0向右 <0向左
 @param right 与refView右边界的距离 >0向右 <0向左
 当left right其中一个=0，一个!=0时，选取!=0的值使用,left right 都!=0时，取left计算
 **/
-(void)addSubview:(UIView*)view above:(UIView*)refView distance:(CGFloat)distance left:(CGFloat)left right:(CGFloat)right;

/**
 在refView左边添加view
 @param view 添加的view
 @param refView 在当前view中需要位置参考的view
 @param distance 与refView右边距离
 @param top 与refView上边界的距离 >0向下 <0向上
 @param bottom 与refView下边界的距离 >0向下 <0向上
 当top bottom其中一个=0，一个!=0时，选取!=0的值使用,top bottom都!=0时，取top计算
 **/
-(void)addSubview:(UIView*)view left:(UIView*)refView distance:(CGFloat)distance top:(CGFloat)top bottom:(CGFloat)bottom;

/**
 在refView左边添加view
 @param view 添加的view
 @param refView 在当前view中需要位置参考的view
 @param distance 与refView右边距离
 @param top 与refView上边界的距离 >0向下 <0向上
 @param bottom 与refView下边界的距离 >0向下 <0向上
 当top bottom其中一个=0，一个!=0时，选取!=0的值使用,top bottom都!=0时，取top计算
 **/
-(void)addSubview:(UIView*)view right:(UIView*)refView distance:(CGFloat)distance top:(CGFloat)top bottom:(CGFloat)bottom;

-(void)changeFrameOrigin:(CGPoint)origin;

-(void)changeFrameSize:(CGSize)size;

-(void)changeFrameOriginX:(CGFloat)x;
-(void)changeFrameOriginY:(CGFloat)y;
-(void)changeFrameSizeWidth:(CGFloat)width;
-(void)changeFrameSizeHeight:(CGFloat)height;

@end
