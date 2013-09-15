//
//  HKAutoSizeLabel.m
//  hkutil2
//
//  Created by akwei on 13-4-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKAutoSizeLabel.h"
#import <QuartzCore/QuartzCore.h>

@implementation HKAutoSizeLabel

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

-(void)autoWidthWithPadding:(CGFloat)padding maxWidth:(CGFloat)maxWidth rightAlign:(BOOL)rightAlign{
    CGRect curFrame = self.frame;
    UIFont* font = self.font;
    CGSize size = CGSizeMake(MAXFLOAT, self.frame.size.height);
    size = [self.text sizeWithFont:font constrainedToSize:size lineBreakMode:NSLineBreakByWordWrapping];
    size.width = size.width + padding;
    if (size.width > maxWidth) {
        size.width = maxWidth;
    }
    CGRect frame = self.frame;
    frame.size=size;
    if (rightAlign) {
        frame.origin.x = frame.origin.x + (curFrame.size.width - size.width);
    }
    self.frame=frame;
    self.textAlignment = NSTextAlignmentCenter;
}

-(void)roundCorner:(CGFloat)radius{
    CALayer* layer = self.layer;
    layer.cornerRadius=radius;
    layer.masksToBounds=YES;
}

-(void)borderWithWidth:(CGFloat)width color:(UIColor *)col{
    CALayer* layer = self.layer;
    layer.borderColor=col.CGColor;
    layer.borderWidth=width;
}

-(HKViewPoints)points{
    CGPoint p = self.frame.origin;
    CGSize size = self.frame.size;
    HKViewPoints points;
    points.leftTop = p;
    points.leftBottom = CGPointMake(p.x, p.y + size.height);
    points.rightBottom = CGPointMake(p.x + size.width, p.y + size.height);
    points.rightTop = CGPointMake(p.x + size.width, p.y);
    return points;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

@end
