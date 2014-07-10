//
//  UILabel+HKEx.m
//  hkutil-static
//
//  Created by akwei on 13-12-1.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "UILabel+HKEx.h"

@implementation UILabel (HKEx)

+(CGFloat)heightForFixedWidth:(CGFloat)width text:(NSString *)text font:(UIFont*)font lineBreakMode:(NSLineBreakMode)lineBreakMode{
    CGSize size = CGSizeMake(width, MAXFLOAT);
    size = [text sizeWithFont:font constrainedToSize:size lineBreakMode:lineBreakMode];
    return size.height;
}

-(void)resizeWidth{
    CGRect frame = self.frame;
    if (!self.text) {
        frame.size.width = 0;
        self.frame = frame;
        return ;
    }
    CGSize size = CGSizeMake(MAXFLOAT, frame.size.height);
    size = [self.text sizeWithFont:self.font constrainedToSize:size lineBreakMode:self.lineBreakMode];
    CGFloat _width = size.width;
    frame.size.width = _width;
    self.frame = frame;
}

-(void)resizeHeight{
    CGRect frame = self.frame;
    if (!self.text) {
        frame.size.height = 0;
        self.frame = frame;
        return ;
    }
    CGSize size = CGSizeMake(frame.size.width, MAXFLOAT);
    size = [self.text sizeWithFont:self.font constrainedToSize:size lineBreakMode:self.lineBreakMode];
    CGFloat _height = size.height;
    frame.size.height = _height;
    self.frame = frame;
}

@end
