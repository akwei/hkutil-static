//
//  HKViewUtil.h
//  hk_restaurant2
//
//  Created by akwei on 13-6-25.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKViewUtil : NSObject<UIAlertViewDelegate>
+ (UIImage*)imageFromView:(UIView*)view;

/**
 UIAlertView扩展
 @param title 同UIAlertView title
 @param message 同UIAlertView message
 @param buttonTitles 按钮标题数组 第一个元素代表的是cancelButtonTitle,其他元素代表 otherButtonTitles
 @param onClickButtonBlock 当点击button执行的block
 */
+ (void)showAlertWithTitle:(NSString *)title message:(NSString *)message buttonTitles:(NSArray*)buttonTitles onClickButtonBlock:(void (^)(UIAlertView* alertView,NSUInteger buttonIndex))onClickButtonBlock;

/**
 去除UITableViewCell中点击延迟效果
 @param cell UITableViewCell
 */
+(void)disableDelayTouchInCell:(UITableViewCell*)cell;

@end
