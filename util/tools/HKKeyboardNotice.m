//
//  KeyboardUtil.m
//  huoku_paidui3
//
//  Created by akwei on 12-8-16.
//  Copyright (c) 2012年 akwei. All rights reserved.
//

#import "HKKeyboardNotice.h"

@interface HKKeyboardNotice ()
@property(nonatomic,assign)UIView* viewContainer;
@property(nonatomic,assign)UIView* viewForMove;
@property(nonatomic,assign)CGRect oldFrame;
@property(nonatomic,assign)BOOL moved;
@end

@implementation HKKeyboardNotice


-(id)initWithViewContainer:(UIView *)vc viewForMove:(UIView *)v{
    self=[super init];
    if (self) {
        self.viewContainer=vc;
        self.viewForMove=v;
        self.disHeight=0;
        self.oldFrame=CGRectZero;
        self.moved=NO;
    }
    return self;
}

-(void)regist{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

-(void)unRegist{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
}

-(void)keyboardWillShow:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    NSValue* aValue = [userInfo objectForKey:UIKeyboardFrameEndUserInfoKey];
    CGRect keyboardRect = [aValue CGRectValue];
    keyboardRect = [self.viewContainer convertRect:keyboardRect fromView:nil];
    CGRect vFrame = self.viewForMove.frame;
    if (!self.moved) {
        self.oldFrame = vFrame;
    }
    self.moved=YES;
    CGFloat distance = vFrame.origin.y + vFrame.size.height - self.disHeight - keyboardRect.origin.y;
    if (distance > 0) {
        vFrame.origin.y = vFrame.origin.y - distance;
        NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
        NSTimeInterval animationDuration;
        [animationDurationValue getValue:&animationDuration];
        [UIView beginAnimations:nil context:NULL];
        [UIView setAnimationDuration:animationDuration];
        self.viewForMove.frame = vFrame;
        [UIView commitAnimations];
    }
}

-(void)keyboardWillHide:(NSNotification*)notification{
    if (!self.moved) {
        return;
    }
    self.moved=NO;
    NSDictionary *userInfo = [notification userInfo];
    NSValue *animationDurationValue = [userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey];
    NSTimeInterval animationDuration;
    [animationDurationValue getValue:&animationDuration];
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationDuration:animationDuration];
    self.viewForMove.frame = self.oldFrame;
    [UIView commitAnimations];
}

@end
