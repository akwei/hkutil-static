//
//  UIViewController+HKEx.h
//  hkutil-static
//
//  Created by akwei on 4/5/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HKEx)

/**
 默认根据Controller的name来找xib文件，并创建对象
 @return 创建的对象
 */
+(id)defCreate;

@end
