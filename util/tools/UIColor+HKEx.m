//
//  UIColor+HKEx.m
//  hkutil-static
//
//  Created by akwei on 7/29/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import "UIColor+HKEx.h"

@implementation UIColor (HKEx)

+(UIColor *)colorFromRGB:(unsigned int)rgbValue{
    return [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0];
}

@end
