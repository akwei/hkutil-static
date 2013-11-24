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

-(UIImage *)toMaxWidth:(CGFloat)maxWidth{
    CGFloat width = self.size.width;
    CGFloat height = self.size.height;
    if (width > maxWidth){
        CGFloat h = (height * maxWidth)/width;
        UIImage* image = [self scaleImageWithImage:self width:maxWidth height:h];
        return image;
    }
    return self;
}

-(UIImage *)toMaxWidthPixel:(CGFloat)maxWidthPixel{
    size_t widthpx = CGImageGetWidth(self.CGImage);
    CGFloat width = self.size.width;
    CGFloat maxWidth = maxWidthPixel * width / widthpx;
    return [self toMaxWidth:maxWidth];
}

-(UIImage*)scaleImageWithImage:(UIImage*)image width:(NSInteger)width height:(NSInteger)height
{
    CGSize size;
	size.width = width;
	size.height = height;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

@end
