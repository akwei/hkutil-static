//
//  HKAnimationUtil.m
//  hkutil-static
//
//  Created by akwei on 13-9-17.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKAnimationUtil.h"

@implementation HKAnimationUtil

+ (CGFloat) degreesToRadians:(CGFloat)degrees {
	return degrees * M_PI / 180;
}
+ (CGFloat) radiansToDegrees:(CGFloat)radians {
	return radians * 180 / M_PI;
}

@end
