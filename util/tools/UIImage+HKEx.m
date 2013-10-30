//
//  UIImage+HKEx.m
//  hkutil-static
//
//  Created by akwei on 13-10-30.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "UIImage+HKEx.h"

@implementation UIImage (HKEx)

+(UIImage *)imageWithColor:(UIColor *)color{
    CGRect rect=CGRectMake(0.0f, 0.0f, 1.0f, 1.0f);
    UIGraphicsBeginImageContext(rect.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    UIImage *theImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return theImage;
}

@end
