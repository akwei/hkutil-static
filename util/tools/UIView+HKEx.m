//
//  UIView+HKEx.m
//  hkutil2
//
//  Created by akwei on 13-7-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "UIView+HKEx.h"

@implementation UIView (HKEx)

-(CGFloat)getContentHeight{
    CGFloat maxHeight = 0;
    for (UIView* view in self.subviews) {
        CGFloat height = view.frame.origin.y + view.frame.size.height;
        if (height > maxHeight) {
            maxHeight = height;
        }
    }
    return maxHeight;
}

-(CGFloat)getContentWidth{
    CGFloat maxWidth = 0;
    for (UIView* view in self.subviews) {
        CGFloat width = view.frame.origin.x + view.frame.size.width;
        if (width > maxWidth) {
            maxWidth = width;
        }
    }
    return maxWidth;
}

-(void)buildXAndAddSubview0:(UIView *)view y:(CGFloat)y refViewFrame:(CGRect)refViewFrame left:(CGFloat)left right:(CGFloat)right{
    CGFloat x = refViewFrame.origin.x;
    if (left !=0 && right != 0) {
        x = x + left;
    }
    else if (left == 0 ) {
        x = x + right;
    }
    else if (right == 0){
        x = x + left;
    }
    CGRect frame = view.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    view.frame = frame;
    [self addSubview:view];
}

-(void)buildYAndAddSubview1:(UIView *)view x:(CGFloat)x refViewFrame:(CGRect)refViewFrame top:(CGFloat)top bottom:(CGFloat)bottom{
    CGFloat y = refViewFrame.origin.y;
    if (top != 0 && bottom != 0) {
        y = y + top;
    }
    else if (top == 0){
        y = y + bottom;
    }
    else if (bottom == 0){
        y = y + top;
    }
    CGRect frame = view.frame;
    frame.origin.x = x;
    frame.origin.y = y;
    view.frame = frame;
    [self addSubview:view];
}

-(void)addSubview:(UIView *)view below:(UIView *)refView distance:(CGFloat)distance left:(CGFloat)left right:(CGFloat)right{
    if (refView.superview != self) {
        return;
    }
    CGRect refViewFrame = refView.frame;
    CGFloat y = refViewFrame.origin.y + refViewFrame.size.height + distance;
    [self buildXAndAddSubview0:view y:y refViewFrame:refViewFrame left:left right:right];
}


-(void)addSubview:(UIView *)view above:(UIView *)refView distance:(CGFloat)distance left:(CGFloat)left right:(CGFloat)right{
    if (refView.superview != self) {
        return;
    }
    CGRect refViewFrame = refView.frame;
    CGFloat y = refViewFrame.origin.y - view.frame.size.height - distance;
    [self buildXAndAddSubview0:view y:y refViewFrame:refViewFrame left:left right:right];
}

-(void)addSubview:(UIView *)view left:(UIView *)refView distance:(CGFloat)distance top:(CGFloat)top bottom:(CGFloat)bottom{
    if (refView.superview != self) {
        return;
    }
    CGRect refViewFrame = refView.frame;
    CGFloat x = refViewFrame.origin.x - view.frame.size.width - distance;
    [self buildYAndAddSubview1:view x:x refViewFrame:refViewFrame top:top bottom:bottom];
}

-(void)addSubview:(UIView *)view right:(UIView *)refView distance:(CGFloat)distance top:(CGFloat)top bottom:(CGFloat)bottom{
    if (refView.superview != self) {
        return;
    }
    CGRect refViewFrame = refView.frame;
    CGFloat x = refViewFrame.origin.x + refViewFrame.size.width + distance;
    [self buildYAndAddSubview1:view x:x refViewFrame:refViewFrame top:top bottom:bottom];
}

-(void)changeFrameOrigin:(CGPoint)origin{
    CGRect frame = self.frame;
    frame.origin = origin;
    self.frame = frame;
}

-(void)changeFrameSize:(CGSize)size{
    CGRect frame = self.frame;
    frame.size = size;
    self.frame = frame;
}

-(void)changeFrameOriginX:(CGFloat)x{
    CGRect frame = self.frame;
    frame.origin.x = x;
    self.frame = frame;
}

-(void)changeFrameOriginY:(CGFloat)y{
    CGRect frame = self.frame;
    frame.origin.y = y;
    self.frame = frame;
}

-(void)changeFrameSizeWidth:(CGFloat)width{
    CGRect frame = self.frame;
    frame.size.width = width;
    self.frame = frame;
}

-(void)changeFrameSizeHeight:(CGFloat)height{
    CGRect frame = self.frame;
    frame.size.height = height;
    self.frame = frame;
}

-(void)changePositionAbove:(UIView *)refView distance:(CGFloat)distance left:(CGFloat)left right:(CGFloat)right{
    CGRect refFrame = refView.frame;
    CGFloat x = refFrame.origin.x;
    CGFloat y = refFrame.origin.y - self.frame.size.height - distance;
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}

-(void)changePositionBelow:(UIView *)refView distance:(CGFloat)distance left:(CGFloat)left right:(CGFloat)right{
    CGRect refFrame = refView.frame;
    CGFloat x = refFrame.origin.x;
    CGFloat y = refFrame.origin.y + refFrame.size.height + distance;
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}

-(void)changePositionLeft:(UIView *)refView distance:(CGFloat)distance top:(CGFloat)top bottom:(CGFloat)bottom{
    CGRect refFrame = refView.frame;
    CGFloat x = refFrame.origin.x - self.frame.size.width - distance;
    CGFloat y = refFrame.origin.y;
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}

-(void)changePositionRight:(UIView *)refView distance:(CGFloat)distance top:(CGFloat)top bottom:(CGFloat)bottom{
    CGRect refFrame = refView.frame;
    CGFloat x = refFrame.origin.x + refFrame.size.width + distance;
    CGFloat y = refFrame.origin.y;
    self.frame = CGRectMake(x, y, self.frame.size.width, self.frame.size.height);
}

@end
