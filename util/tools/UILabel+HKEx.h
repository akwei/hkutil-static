//
//  UILabel+HKEx.h
//  hkutil-static
//
//  Created by akwei on 13-12-1.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UILabel (HKEx)

/**
 固定高度，根据文字匹配宽度
 */
-(void)resizeWidth;

/**
 固定宽度，根据文字匹配高度
 */
-(void)resizeHeight;

@end
