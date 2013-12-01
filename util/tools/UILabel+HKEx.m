//
//  UILabel+HKEx.m
//  hkutil-static
//
//  Created by akwei on 13-12-1.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "UILabel+HKEx.h"

@implementation UILabel (HKEx)


-(void)resizeWidth{
    CGRect frame = self.frame;
    CGSize size = CGSizeMake(MAXFLOAT, frame.size.height);
    size = [self.text sizeWithFont:self.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat _width = size.width;
    frame.size.width = _width;
    self.frame = frame;
}

-(void)resizeHeight{
    CGRect frame = self.frame;
    CGSize size = CGSizeMake(frame.size.width, MAXFLOAT);
    size = [self.text sizeWithFont:self.font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    CGFloat _height = size.height;
    frame.size.height = _height;
    self.frame = frame;
}

@end
