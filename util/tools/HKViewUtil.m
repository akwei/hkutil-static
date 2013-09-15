//
//  HKViewUtil.m
//  hk_restaurant2
//
//  Created by akwei on 13-6-25.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKViewUtil.h"
#import <QuartzCore/QuartzCore.h>

@implementation HKViewUtil

+ (UIImage*)imageFromView:(UIView*)view
{
    [self beginImageContextWithSize:[view bounds].size];
    BOOL hidden = [view isHidden];
    [view setHidden:NO];
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    [view setHidden:hidden];
    return image;
}

+ (UIImage*)imageFromView:(UIView*)view scaledToSize:(CGSize)newSize
{
    UIImage *image = [self imageFromView:view];
    if ([view bounds].size.width != newSize.width ||
        [view bounds].size.height != newSize.height) {
        image = [self imageWithImage:image scaledToSize:newSize];
    }
    return image;
}

+ (UIImage*)imageWithImage:(UIImage*)image scaledToSize:(CGSize)newSize
{
    [self beginImageContextWithSize:newSize];
    [image drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    [self endImageContext];
    return newImage;
}

+ (void)beginImageContextWithSize:(CGSize)size
{
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)]) {
        if ([[UIScreen mainScreen] scale] == 2.0) {
            UIGraphicsBeginImageContextWithOptions(size, YES, 2.0);
        } else {
            UIGraphicsBeginImageContext(size);
        }
    } else {
        UIGraphicsBeginImageContext(size);
    }
}

+ (void)endImageContext
{
    UIGraphicsEndImageContext();
}

@end
