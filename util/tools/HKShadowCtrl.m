//
//  HKShadowCtrl.m
//  hkutil2
//
//  Created by akwei on 13-4-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKShadowCtrl.h"
#import "UIView+HKEx.h"
#import <QuartzCore/QuartzCore.h>

#define kBlockKey @"block"
#define kAnimationKey @"animation"
#define kCloseAni @"closeAni"

@interface HKShadowCtrl ()
@property(nonatomic,strong)NSMutableArray* viewControllers;
@property(nonatomic,strong)UIView* shadow;//作用是渐变式弹出阴影层，不收view切换影响
@property(nonatomic,strong)UIView* hkViewContainer;
@property(nonatomic,assign)CGRect viewFrame;
@property(nonatomic,assign)UIView* parent;
@property(nonatomic,assign)NSTimeInterval animationTime;//动画持续时间
@property(nonatomic,copy)NSString* forwardType;
@property(nonatomic,copy)NSString* backwardType;
@property(nonatomic,copy)NSString* forwardSubType;
@property(nonatomic,copy)NSString* backwardSubType;
@property(nonatomic,strong)UIColor* shadowColor;
//动画未完成时，需要执行的block放入此中，当动画完成，并且动画结束的block完成后，从数组中取出需要执行的block来执行，并删除已经执行过的block
@property(nonatomic,strong)NSMutableArray* stackBlockArray;
//一个透明遮挡view
@property(nonatomic,strong)UIView* bgView;
@end

@implementation HKShadowCtrl{
    BOOL animating;
}

-(id)initWithParentView:(UIView *)parent{
    self = [super init];
    if (self) {
        animating = NO;
        self.debug = NO;
        self.viewControllers=[[NSMutableArray alloc] init];
        self.parent=parent;
        self.viewFrame = self.parent.bounds;
        self.animationTime = .4;
        self.forwardType = kCATransitionPush;
        self.forwardSubType = kCATransitionFromRight;
        self.backwardType = kCATransitionPush;
        self.backwardSubType = kCATransitionFromLeft;
        self.closeType = kCATransitionFade;
        self.stackBlockArray = [[NSMutableArray alloc] init];
        self.bgView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 0, 0)];
        self.bgView.backgroundColor = nil;
//        [UIColor colorWithRed:0 green:0 blue:0 alpha:.8];
        self.bgView.clipsToBounds = NO;
        self.bgView.hidden = YES;
    }
    return self;
}

-(id)init{
    return nil;
}

-(void)loadView{
    self.view = [[UIView alloc] initWithFrame:self.parent.bounds];
}

-(void (^)(void))popFromStackBlockArray{
    void(^block)(void) = [self.stackBlockArray firstObject];
    if (block) {
        [self.stackBlockArray removeObjectAtIndex:0];
        return block;
    }
    return nil;
}

-(void)pushToStack:(void (^)(void))block{
    [self.stackBlockArray insertObject:block atIndex:0];
}

-(void)viewDidLoad{
//    if (!self.shadowColor) {
//        self.shadowColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:.7];
//    }
    CGRect rect = self.viewFrame;
    self.view.hidden=YES;
    self.view.frame = rect;
    self.view.backgroundColor = nil;
    self.view.clipsToBounds=YES;
    UIViewAutoresizing defViewAutoresizing = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
    self.shadow=[[UIView alloc] initWithFrame:self.view.bounds];
    if (self.shadowColor) {
        self.shadow.backgroundColor = self.shadowColor;
    }
    else{
        self.shadow.backgroundColor = nil;
    }
    self.shadow.autoresizesSubviews=YES;
    self.shadow.autoresizingMask=defViewAutoresizing;
    [self.view addSubview:self.shadow];
    self.hkViewContainer=[[UIView alloc] initWithFrame:self.view.bounds];
    self.hkViewContainer.autoresizingMask=defViewAutoresizing;
    self.hkViewContainer.clipsToBounds=YES;
    self.hkViewContainer.backgroundColor=nil;
    self.hkViewContainer.clearsContextBeforeDrawing=YES;
    [self.view addSubview:self.hkViewContainer];
    [self.view addSubview:self.bgView];
}

-(void)changeShadowColor:(UIColor *)shadowColor{
    self.shadowColor = shadowColor;
    self.shadow.backgroundColor = self.shadowColor;
}

#pragma mark - push
-(void)hkPushViewController:(UIViewController<HKShadowCtrlDelegate> *)viewController animated:(BOOL)animated{
//    if (![self canProcess]) {
//        return;
//    }
    [self hkPushViewController:viewController animated:animated onComplete:nil];
}

-(void)hkPushViewController:(UIViewController<HKShadowCtrlDelegate> *)viewController animated:(BOOL)animated onComplete:(void (^)(void))completeBlock{
//    if (![self canProcess]) {
//        return;
//    }
    CAAnimation* tr;
    if (animated) {
        tr = [self createAnimationWithtype:self.forwardType subType:self.forwardSubType];
    }
    [self hkPushViewController:viewController animation:tr onComplete:completeBlock];
}

-(void)hkPushViewController:(UIViewController<HKShadowCtrlDelegate> *)viewController animation:(CAAnimation *)animation onComplete:(void (^)(void))completeBlock{
    if (![self doProcessing]) {
        __weak HKShadowCtrl* me = self;
        [self pushToStack:^{
            [me hkPushViewController:viewController animation:animation onComplete:completeBlock];
        }];
        return;
    }
    viewController.shadowCtrl=self;
    [self.viewControllers insertObject:viewController atIndex:0];
    [self showViewController:viewController animation:animation onComplete:completeBlock];
    if (self.debug) {
        NSLog(@"current viewControllers count:%llu",(unsigned long long)[self.viewControllers count]);
    }
}

#pragma mark - popToRoot

-(NSArray *)hkPopToRootViewControllerAnimated:(BOOL)animated{
    if (![self canProcess]) {
        return nil;
    }
    return [self hkPopToRootViewControllerAnimated:animated onComplete:nil];
}

-(NSArray *)hkPopToRootViewControllerAnimated:(BOOL)animated onComplete:(void (^)(void))completeBlock{
//    if (![self canProcess]) {
//        return nil;
//    }
    CAAnimation* tr;
    if (animated) {
        tr = [self createAnimationWithtype:self.backwardType subType:self.backwardSubType];
    }
    return [self hkPopToRootViewControllerAnimation:tr onComplete:completeBlock];
}

-(NSArray *)hkPopToRootViewControllerAnimation:(CAAnimation *)animation onComplete:(void (^)(void))completeBlock{
//    if (![self canProcess]) {
//        return nil;
//    }
    if ([self.viewControllers count]>0) {
        UIViewController<HKShadowCtrlDelegate>* root = [self.viewControllers lastObject];
        return [self hkPopToViewController:root animation:animation onComplete:completeBlock];
    }
    return nil;
}

#pragma mark - popAll

-(NSArray *)hkPopAllAndCloseAnimated:(BOOL)animated{
    CAAnimation* tr;
//    if (![self canProcess]) {
//        return nil;
//    }
    if (animated) {
        tr = [self createAnimationWithtype:self.closeType subType:nil];
    }
    return [self hkPopAllAndCloseWithBlock:nil delay:0 animation:tr];
}

-(NSArray *)hkPopAllAndCloseWithBlock:(void (^)(void))block delay:(NSTimeInterval)delay animation:(CAAnimation *)animation{
//    if (![self canProcess]) {
//        return nil;
//    }
    if ([self.viewControllers count]>0) {
        [self closeWithBlock:block delay:delay animation:animation];
        return [NSArray arrayWithArray:self.viewControllers];
    }
    return nil;
}

#pragma mark - popToView
-(NSArray *)hkPopToViewController:(UIViewController<HKShadowCtrlDelegate> *)viewController animated:(BOOL)animated{
//    if (![self canProcess]) {
//        return nil;
//    }
    return [self hkPopToViewController:viewController animated:animated onComplete:nil];
}

-(NSArray *)hkPopToViewController:(UIViewController<HKShadowCtrlDelegate> *)viewController animated:(BOOL)animated onComplete:(void (^)(void))completeBlock{
//    if (![self canProcess]) {
//        return nil;
//    }
    CAAnimation* tr;
    if (animated) {
        tr = [self createAnimationWithtype:self.backwardType subType:self.backwardSubType];
    }
    return [self hkPopToViewController:viewController animation:tr onComplete:completeBlock];
}

-(NSArray *)hkPopToViewController:(UIViewController<HKShadowCtrlDelegate> *)viewController animation:(CAAnimation *)animation onComplete:(void (^)(void))completeBlock{
    if (![self doProcessing]) {
        __weak HKShadowCtrl* me = self;
        [me pushToStack:^{
            [me hkPopToViewController:viewController animation:animation onComplete:completeBlock];
        }];
        return nil;
    }
    [self showViewController:viewController animation:animation onComplete:completeBlock];
    NSRange range = [self rangeForRemoveViewControllers:viewController];
    return [self arrayForRemoved:range];
}

#pragma mark - popView
-(UIViewController<HKShadowCtrlDelegate> *)hkPopViewControllerAnimated:(BOOL)animated{
//    if (![self canProcess]) {
//        return nil;
//    }
    return [self hkPopViewControllerAnimated:animated onComplete:nil];
}

-(UIViewController<HKShadowCtrlDelegate> *)hkPopViewControllerAnimated:(BOOL)animated onComplete:(void (^)(void))completeBlock{
    CAAnimation* tr;
//    if (![self canProcess]) {
//        return nil;
//    }
    if (animated) {
        tr = [self createAnimationWithtype:self.backwardType subType:self.backwardSubType];
    }
    return [self hkPopViewControllerAnimation:tr onComplete:completeBlock];
}

-(UIViewController<HKShadowCtrlDelegate> *)hkPopViewControllerAnimation:(CAAnimation *)animation onComplete:(void (^)(void))completeBlock{
    if (![self canProcess]) {
        return nil;
    }
    if ([self.viewControllers count] <= 1) {
        [self closeWithBlock:completeBlock delay:0 animation:animation];
        return nil;
    }
    UIViewController<HKShadowCtrlDelegate>* second = [self.viewControllers objectAtIndex:1];
    UIViewController<HKShadowCtrlDelegate>* top = [self.viewControllers objectAtIndex:0];
    [self hkPopToViewController:second animation:animation onComplete:completeBlock];
    return top;
}

#pragma mark - close
-(void)closeWithAnimated:(BOOL)animated{
    if (![self canProcess]) {
        return ;
    }
    [self closeWithBlock:nil animated:animated];
}

-(void)closeWithBlock:(void (^)(void))block animated:(BOOL)animated{
    if (![self canProcess]) {
        return ;
    }
    [self closeWithBlock:block delay:0 animated:animated];
}

-(void)closeWithDelay:(NSTimeInterval)delay animated:(BOOL)animated{
    if (![self canProcess]) {
        return ;
    }
    [self closeWithBlock:nil delay:delay animated:animated];
}

-(void)closeWithBlock:(void (^)(void))block delay:(NSTimeInterval)delay animated:(BOOL)animated{
    CAAnimation* tr;
    if (![self canProcess]) {
        return ;
    }
    if (animated) {
        tr = [self createAnimationWithtype:self.closeType subType:nil];
    }
    [self closeWithBlock:block delay:delay animation:tr];
}

-(void)closeWithBlock:(void (^)(void))block delay:(NSTimeInterval)delay animation:(CAAnimation *)animation{
    if (![self canProcess]) {
        return ;
    }
    NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
    if (animation) {
        [info setValue:animation forKey:kAnimationKey];
    }
    if (block) {
        [info setValue:block forKey:kBlockKey];
    }
    if (delay <= 0) {
        [self closeWithInfo:info];
    }
    else{
        [self performSelector:@selector(closeWithInfo:) withObject:info afterDelay:delay];
    }
}

#pragma mark - private method

-(void)showViewController:(UIViewController*)viewController animation:(CAAnimation*)animation onComplete:(void (^)(void))completeBlock{
    if (animation) {
        animation.delegate = self;
        [animation setValue:completeBlock forKey:kBlockKey];
        [self showBgView];
        [self showView:viewController.view];
        [self.hkViewContainer.layer addAnimation:animation forKey:@"ani"];
//        [self finishProcessing];
    }
    else{
        [self showBgView];
        [self showView:viewController.view];
        [self finishProcessing];
        [self hideBgView];
    }
}

/*
 返回删除的ViewControllers
 */
-(NSArray*)arrayForRemoved:(NSRange)range{
    if (range.length==0) {
        return nil;
    }
    NSMutableArray* arr = [[NSMutableArray alloc] init];
    for (int i=range.location; i<range.length; i++) {
        [arr addObject:[self.viewControllers objectAtIndex:i]];
    }
    [self.viewControllers removeObjectsInRange:range];
    if (self.debug) {
        NSLog(@"current viewControllers count:%llu",(unsigned long long)[self.viewControllers count]);
    }
    return arr;
}

//private
-(void)closeWithInfo:(NSDictionary*)info{
    if (![self doProcessing]) {
        return ;
    }
    CAAnimation* tr = [info valueForKey:kAnimationKey];
    void (^block)(void) = [info valueForKey:kBlockKey];
    if (tr) {
        if (block) {
            [tr setValue:block forKey:kBlockKey];
        }
        
        self.view.hidden = YES;
        [self clearAll];
        [self.view.layer addAnimation:tr forKey:@"ani"];
    }
    else{
        self.view.hidden = YES;
        [self clearAll];
        if (block) {
            block();
        }
        [self finishProcessing];
    }
}

-(BOOL)isViewShow{
    if ([[self.hkViewContainer subviews] count]>0) {
        return YES;
    }
    return NO;
}

-(BOOL)isCurrentRoot{
    if ([self.viewControllers count]==1) {
        return YES;
    }
    return NO;
}

/*
 找到需要显示的viewController的位置，返回此位置以前的范围
 */
-(NSRange)rangeForRemoveViewControllers:(UIViewController*)toViewController{
    int i=0;
    for (UIViewController* ctrl in self.viewControllers) {
        if (ctrl==toViewController) {
            NSRange range= NSMakeRange(0, i);
            return range;
        }
        i++;
    }
    return NSMakeRange(0, 0);
}

-(void)clearAll{
    NSArray* views = [self.hkViewContainer subviews];
    for (UIView* sview in views) {
        [sview removeFromSuperview];
    }
    [self clearControllers];
}

#pragma mark - animation ref
-(CAAnimation*)createAnimationWithtype:(NSString*)type subType:(NSString*)subType {
    CATransition *transition = [CATransition animation];
    transition.duration = self.animationTime;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type = type;
    transition.subtype = subType;
    transition.delegate = self;
    transition.removedOnCompletion = YES;
    transition.fillMode = kCAFillModeBoth;
    return transition;
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
    [self finishProcessing];
    [self hideBgView];
    NSNumber* n_closeAni = [anim valueForKey:kCloseAni];
    if (n_closeAni) {
        self.view.hidden = YES;
    }
    void(^block)(void) = [anim valueForKey:kBlockKey];
    if (block) {
        block();
    }
    void (^stackBlock) (void) = [self popFromStackBlockArray];
    if (stackBlock) {
        stackBlock();
    }
}

-(BOOL)canProcess{
    if (animating) {
        return NO;
    }
    return YES;
}

-(BOOL)doProcessing{
    if (animating) {
        return NO;
    }
    animating = YES;
    return YES;
}

-(void)finishProcessing{
    animating = NO;
    self.bgView.hidden = YES;
}

-(void)showView:(UIView*)view{
    self.view.frame = self.parent.bounds;
    self.view.hidden = NO;
    if (!self.view.superview) {
        [self.parent addSubview:self.view];
    }
    [self.parent bringSubviewToFront:self.view];
    CGPoint centerP=self.hkViewContainer.center;
    centerP = [self.hkViewContainer convertPoint:centerP fromView:self.hkViewContainer.superview];
    view.center=centerP;
    NSArray* subViews = [self.hkViewContainer subviews];
    for (UIView* sview in subViews) {
        [sview removeFromSuperview];
    }
    [self.hkViewContainer addSubview:view];
}

-(void)showBgView{
    self.bgView.frame = self.view.bounds;
    self.bgView.hidden = NO;
    [self.view bringSubviewToFront:self.bgView];
}

-(void)hideBgView{
    self.bgView.hidden = YES;
}

-(void)clearControllers{
    [self.viewControllers removeAllObjects];
}
@end
