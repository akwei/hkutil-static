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
 添加子视图，位置居中
 @param animated 是否需要默认动画
 @param toCenter 是否添加到视图的中间位置
 */
-(void)addSubviewToCenter:(UIView *)view;

/**
 添加子视图，并显示在最前
 @param animated 是否需要默认动画
 @param onCompleteBlock 添加完成后执行的block
 */
-(void)addSubview:(UIView *)view animated:(BOOL)animated onCompleteBlock:(void(^)(void))onCompleteBlock;

/**
 添加子视图，并显示在最前
 @param animated 是否需要默认动画
 @param onCompleteBlock 添加完成后执行的block
 */
-(void)addSubview:(UIView *)view animated:(BOOL)animated;

/**
 添加子视图，并显示在最前
 @param animated 是否需要默认动画
 @param toCenter 是否添加到视图的中间位置
 @param onCompleteBlock 添加完成后执行的block
 */
-(void)addSubview:(UIView *)view animated:(BOOL)animated toCenter:(BOOL)toCenter onCompleteBlock:(void(^)(void))onCompleteBlock;

/**
 添加子视图，并显示在最前
 @param animated 是否需要默认动画
 @param toCenter 是否添加到视图的中间位置
 @param onCompleteBlock 添加完成后执行的block
 */
-(void)addSubview:(UIView *)view animated:(BOOL)animated toCenter:(BOOL)toCenter;

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
 在refView右边添加view
 @param view 添加的view
 @param refView 在当前view中需要位置参考的view
 @param distance 与refView右边距离
 @param top 与refView上边界的距离 >0向下 <0向上
 @param bottom 与refView下边界的距离 >0向下 <0向上
 当top bottom其中一个=0，一个!=0时，选取!=0的值使用,top bottom都!=0时，取top计算
 **/
-(void)addSubview:(UIView*)view right:(UIView*)refView distance:(CGFloat)distance top:(CGFloat)top bottom:(CGFloat)bottom;

/**
 添加子视图，距离左边内边距和下边内边距
 @param paddingLeft 左边内边距
 @param paddingBottom 下边内边距
 */
-(void)addSubview:(UIView*)view paddingLeft:(CGFloat)paddingLeft paddingBottom:(CGFloat)paddingBottom;

/**
 添加子视图，距离右边内边距和上边内边距
 @param paddingRight 右边内边距
 @param paddingTop 上边内边距
 */
-(void)addSubview:(UIView*)view paddingRight:(CGFloat)paddingRight paddingTop:(CGFloat)paddingTop;

/**
 添加子视图，距离右边内边距和下边内边距
 @param paddingRight 右边内边距
 @param paddingBottom 下边内边距
 */
-(void)addSubview:(UIView*)view paddingRight:(CGFloat)paddingRight paddingBottom:(CGFloat)paddingBottom;

-(void)removeFromSuperviewAnimated;

/**
 从父级视图中删除
 @param animated 是否需要默认动画
 @param delay 延迟删除的时间
 @param onCompleteBlock 添加完成后执行的block
 */
-(void)removeFromSuperviewWithAnimated:(BOOL)animated delay:(NSTimeInterval)delay onCompleteBlock:(void(^)(void))onCompleteBlock;

-(void)changeFrameOrigin:(CGPoint)origin;

-(void)changeFrameSize:(CGSize)size;

-(void)changeFrameOriginX:(CGFloat)x;
-(void)changeFrameOriginY:(CGFloat)y;
-(void)changeFrameSizeWidth:(CGFloat)width;
-(void)changeFrameSizeHeight:(CGFloat)height;

/**
 更改view的位置在refView上边
 @param refView 在当前view中需要位置参考的view
 @param distance 与refView上边距离
 @param left 与refView左边界的距离 >0向右 <0向左
 @param right 与refView右边界的距离 >0向右 <0向左
 当left right其中一个=0，一个!=0时，选取!=0的值使用,left right 都!=0时，取left计算
 **/
-(void)changePositionAbove:(UIView*)refView distance:(CGFloat)distance left:(CGFloat)left right:(CGFloat)right;

/**
 更改view的位置在refView下边
 @param refView 在当前view中需要位置参考的view
 @param distance 与refView下边距离
 @param left 与refView左边界的距离 >0向右 <0向左
 @param right 与refView右边界的距离 >0向右 <0向左
 当left right其中一个=0，一个!=0时，选取!=0的值使用,left right 都!=0时，取left计算
 **/
-(void)changePositionBelow:(UIView*)refView distance:(CGFloat)distance left:(CGFloat)left right:(CGFloat)right;

/**
 更改view的位置在refView左边
 @param refView 在当前view中需要位置参考的view
 @param distance 与refView右边距离
 @param top 与refView上边界的距离 >0向下 <0向上
 @param bottom 与refView下边界的距离 >0向下 <0向上
 当top bottom其中一个=0，一个!=0时，选取!=0的值使用,top bottom都!=0时，取top计算
 **/
-(void)changePositionLeft:(UIView*)refView distance:(CGFloat)distance top:(CGFloat)top bottom:(CGFloat)bottom;

/**
 更改view的位置在refView右边
 @param refView 在当前view中需要位置参考的view
 @param distance 与refView右边距离
 @param top 与refView上边界的距离 >0向下 <0向上
 @param bottom 与refView下边界的距离 >0向下 <0向上
 当top bottom其中一个=0，一个!=0时，选取!=0的值使用,top bottom都!=0时，取top计算
 **/
-(void)changePositionRight:(UIView*)refView distance:(CGFloat)distance top:(CGFloat)top bottom:(CGFloat)bottom;

/**
 在superview中垂直居中
 */
-(void)moveToVerticalCenter;

/**
 在superview中水平居中
 */
-(void)moveToHorizontalCenter;

/**
 在superview中垂直和水平居中
 */
-(void)moveToCenter;

/**
 创建一个与自己一样大的view，默认背景色为clearColor
 */
-(UIView*)createViewFromSelf;

/**
 调整自身frame，来适配子视图的完整显示
 */
-(void)fitSizeToSubviewsSize;

/**
 获得子视图的中心点
 */
-(CGPoint)getSubViewCenter;

/**
 是否能完全显示需要添加的视图，view将在当前子视图的左边出现
 @param view 将要添加的视图
 @para refView 已经添加的子视图
 @param distance 距离reView左边的距离，正数向左，负数向右
 */
-(BOOL)canShowView:(UIView*)view left:(UIView*)refView distance:(CGFloat)distance;

/**
 是否能完全显示需要添加的视图，view将在当前子视图的右边出现
 @param view 将要添加的视图
 @para refView 已经添加的子视图
 @param distance 距离reView右边的距离，正数向右，负数向左
 */
-(BOOL)canShowView:(UIView*)view right:(UIView*)refView distance:(CGFloat)distance;

-(id)viewWithTagEx:(NSInteger)tag;

-(CGFloat)getBottomY;

-(CGFloat)getRightX;

/**
 把所有子视图从当前视图中移除
 */
//-(void)removeAllSubviews;

@end
