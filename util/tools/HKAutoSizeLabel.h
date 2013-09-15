//
//  HKAutoSizeLabel.h
//  hkutil2
//
//  Created by akwei on 13-4-23.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <UIKit/UIKit.h>

/*
 view的四个顶点
 */
struct HKViewPoints {
    CGPoint leftTop;
    CGPoint rightTop;
    CGPoint rightBottom;
    CGPoint leftBottom;
};
typedef struct HKViewPoints HKViewPoints;

@interface HKAutoSizeLabel : UILabel

/*
 自动根据文字匹配宽度，设定内容padding为居中时使用，宽度不能超过设定的maxWidth
 */
-(void)autoWidthWithPadding:(CGFloat)padding maxWidth:(CGFloat)maxWidth rightAlign:(BOOL)rightAlign;

-(void)roundCorner:(CGFloat)radius;

-(void)borderWithWidth:(CGFloat)width color:(UIColor*)col;

-(HKViewPoints)points;

@end
