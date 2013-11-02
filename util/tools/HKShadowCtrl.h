//
//  HKShadowCtrl.h
//  hkutil2
//
//  Created by akwei on 13-4-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

/*
 大多使用在iPad中，当前View不动，只切换小View，小View的实现为普通的UIViewController
 */

#import <UIKit/UIKit.h>

@class HKShadowCtrl;

@protocol HKShadowCtrlDelegate <NSObject>
@property(nonatomic,unsafe_unretained)HKShadowCtrl* shadowCtrl;
@end

@interface HKShadowCtrl : UIViewController
@property(nonatomic,copy)NSString* closeType;

-(void)changeShadowColor:(UIColor *)shadowColor;

-(id)initWithParentView:(UIView*)parent;
-(void)hkPushViewController:(UIViewController<HKShadowCtrlDelegate>*)viewController animated:(BOOL)animated;
-(void)hkPushViewController:(UIViewController<HKShadowCtrlDelegate>*)viewController animated:(BOOL)animated onComplete:(void (^)(void))completeBlock;
-(void)hkPushViewController:(UIViewController<HKShadowCtrlDelegate>*)viewController animation:(CAAnimation*)animation onComplete:(void (^)(void))completeBlock;

-(NSArray*)hkPopToRootViewControllerAnimated:(BOOL)animated;
-(NSArray*)hkPopToRootViewControllerAnimated:(BOOL)animated onComplete:(void (^)(void))completeBlock;
-(NSArray*)hkPopToRootViewControllerAnimation:(CAAnimation*)animation onComplete:(void (^)(void))completeBlock;

-(NSArray*)hkPopToViewController:(UIViewController<HKShadowCtrlDelegate>*)viewController animated:(BOOL)animated;
-(NSArray*)hkPopToViewController:(UIViewController<HKShadowCtrlDelegate>*)viewController animated:(BOOL)animated onComplete:(void (^)(void))completeBlock;
-(NSArray*)hkPopToViewController:(UIViewController<HKShadowCtrlDelegate>*)viewController animation:(CAAnimation*)animation onComplete:(void (^)(void))completeBlock;

-(NSArray*)hkPopAllAndCloseAnimated:(BOOL)animated;
-(NSArray*)hkPopAllAndCloseWithBlock:(void(^)(void))block delay:(NSTimeInterval)delay animation:(CAAnimation*)animation;

-(UIViewController<HKShadowCtrlDelegate>*)hkPopViewControllerAnimated:(BOOL)animated;
-(UIViewController<HKShadowCtrlDelegate>*)hkPopViewControllerAnimated:(BOOL)animated onComplete:(void (^)(void))completeBlock;
-(UIViewController<HKShadowCtrlDelegate>*)hkPopViewControllerAnimation:(CAAnimation*)animation onComplete:(void (^)(void))completeBlock;

/*
 关闭shaodw
 */
-(void)closeWithAnimated:(BOOL)animated;

/*
 关闭shaodw，关闭动画完成后，执行block
 */
-(void)closeWithBlock:(void(^)(void))block animated:(BOOL)animated;

/*
 关闭shaodw
 */
-(void)closeWithDelay:(NSTimeInterval)delay animated:(BOOL)animated;

/*
 关闭shaodw，关闭动画完成后，执行block
 */
-(void)closeWithBlock:(void(^)(void))block delay:(NSTimeInterval)delay animated:(BOOL)animated;

-(void)closeWithBlock:(void(^)(void))block delay:(NSTimeInterval)delay animation:(CAAnimation*)animation;

/*
 当前是否有view正在显示
 */
-(BOOL)isViewShow;

/*
 当前显示的是否是根view
 */
-(BOOL)isCurrentRoot;
-(void)clearControllers;
@end
