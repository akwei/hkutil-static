//
//  HKShadowView.m
//  hkutil2
//
//  Created by akwei on 13-4-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKShadowView.h"

#define kBlockKey @"block"
#define kAnimationKey @"animation"

@interface HKShadowView ()
@property (strong, nonatomic) UIView *viewContainer;
@property(nonatomic,retain)UIView* currentShowView;
//@property(nonatomic,assign)BOOL aniProcessing;//动画是否正在进行
@property(nonatomic,strong)UIView* shadow;//作用是渐变式弹出阴影层，不收view切换影响
//当前添加的所有view
@property(nonatomic,strong)NSMutableArray* views;
@end


@implementation HKShadowView

-(id)initWithParentView:(UIView*)parentView{
    CGRect parentFrame = parentView.frame;
    CGRect oframe=CGRectMake(0, 0, parentFrame.size.width, parentFrame.size.height);
    self = [super initWithFrame:oframe];
    if (self) {
        self.aniTime = .5;
        UIViewAutoresizing defViewAutoresizing = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        self.hidden=YES;
        self.backgroundColor=[UIColor clearColor];
        self.alpha=1;
        self.autoresizesSubviews=YES;
        self.autoresizingMask=defViewAutoresizing;
        
        [parentView addSubview:self];
        CGRect ooframe=oframe;
        ooframe.origin.x=0;
        ooframe.origin.y=0;
        UIColor* clearColor = [UIColor clearColor];
        self.backgroundColor = clearColor;
        self.shadow=[[UIView alloc] initWithFrame:ooframe];
        self.shadow.backgroundColor=nil;
        self.shadow.autoresizesSubviews=YES;
        self.shadow.autoresizingMask=defViewAutoresizing;
        [self addSubview:self.shadow];
        self.viewContainer=[[UIView alloc] initWithFrame:ooframe];
        self.viewContainer.backgroundColor=[UIColor colorWithRed:0 green:0 blue:0 alpha:.5];
        self.viewContainer.alpha=1;
        self.viewContainer.autoresizesSubviews=YES;
        self.viewContainer.autoresizingMask=defViewAutoresizing;
        self.viewContainer.backgroundColor = clearColor;
        [self addSubview:self.viewContainer];
    }
    return self;
}


#pragma mark - show method

-(void)showView:(UIView *)view animated:(BOOL)animated{
    [self showView:view completeBlock:nil animated:animated];
}

-(void)showView:(UIView *)view completeBlock:(void (^)(void))block animation:(CAAnimation*)animation{
    if (animation) {
//        if (self.aniProcessing) {
//            return ;
//        }
//        self.aniProcessing=YES;
        [animation setRemovedOnCompletion:YES];
        animation.delegate = self;
        [animation setValue:block forKey:kBlockKey];
        [self.viewContainer.layer addAnimation:animation forKey:nil];
        [self showView:view];
    }
    else{
//        self.aniProcessing=YES;
        [self showView:view];
        if (block) {
            block();
        }
//        self.aniProcessing = NO;
    }
}

-(void)showView:(UIView *)view completeBlock:(void (^)(void))block animated:(BOOL)animated{
    CAAnimation* animation;
    if (animated) {
        animation = [self createAnimationWithtype:kCATransitionFade subType:nil];
    }
    [self showView:view completeBlock:block animation:animation];
}

#pragma mark - close method

-(void)closeViewWithAnimated:(BOOL)animated{
    [self closeViewWithCompleteBlock:nil delay:0 animated:YES];
}

-(void)closeViewWithCompleteBlock:(void (^)(void))block delay:(NSTimeInterval)delay animation:(CAAnimation *)animation{
    if (delay>0) {
        NSMutableDictionary* info = [[NSMutableDictionary alloc] init];
        if (block) {
            [info setValue:block forKey:kBlockKey];
        }
        if (animation) {
            [info setValue:animation forKey:kAnimationKey];
        }
        [self performSelector:@selector(closeViewWithInfo:) withObject:info afterDelay:delay];
    }
    else{
        [self closeViewWithCompleteBlock:block animation:animation];
    }
}

-(void)closeViewWithCompleteBlock:(void (^)(void))block delay:(NSTimeInterval)delay animated:(BOOL)animated{
    CAAnimation* animation;
    if (animated) {
        animation = [self createAnimationWithtype:kCATransitionFade subType:nil];
    }
    [self closeViewWithCompleteBlock:block delay:delay animation:animation];
}

#pragma mark - private method

-(void)closeViewWithInfo:(NSDictionary*)info{
    void (^block)(void) = [info valueForKey:kBlockKey];
    CAAnimation* animation = [info valueForKey:kAnimationKey];
    [self closeViewWithCompleteBlock:block animation:animation];
    
}

-(void)closeViewWithCompleteBlock:(void (^)(void))block animation:(CAAnimation *)animation{
    if (animation) {
//        if (self.aniProcessing) {
//            return ;
//        }
//        self.aniProcessing=YES;
        animation.removedOnCompletion = YES;
        animation.delegate = self;
        [animation setValue:block forKey:kBlockKey];
        [self.layer addAnimation:animation forKey:nil];
        [self hideView];
    }
    else{
        [self hideView];
        if (block) {
            block();
        }
//        self.aniProcessing = NO;
    }
}

-(void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag{
//    self.aniProcessing=NO;
    void (^block)(void) = [anim valueForKey:kBlockKey];
    if (block) {
        block();
    }
}

-(void)changeShadowColor:(UIColor *)shadowColor{
    self.shadow.backgroundColor = shadowColor;
}

-(void)showView:(UIView *)view{
    if (self.currentShowView==view) {
        return ;
    }
    [self.superview bringSubviewToFront:self];
    self.hidden=NO;
    [self hideSubView];
    CGPoint centerP=self.viewContainer.center;
    centerP = [self.viewContainer convertPoint:centerP fromView:self.viewContainer.superview];
    view.center=centerP;
    view.hidden = YES;
    [self.viewContainer addSubview:view];
    view.hidden = NO;
    self.currentShowView=view;
    self.currentShowView.autoresizingMask=UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleBottomMargin;
}

-(void)hideView{
    [self hideSubView];
    self.hidden=YES;
}

-(void)hideSubView{
    NSArray* views = [self.viewContainer subviews];
    for (UIView* _view in views) {
        [_view removeFromSuperview];
        break;
    }
    self.currentShowView=nil;
}

-(CATransition*)createAnimationWithtype:(NSString*)type subType:(NSString*)subType{
    CATransition *transition = [CATransition animation];
    transition.delegate = self;
    transition.duration = self.aniTime;
    transition.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
    transition.type=type;
    transition.subtype=subType;
    transition.removedOnCompletion = YES;
    return transition;
}

@end
