//
//  HKAttrLabel.h
//  hkutil-static
//  可实现CoreText的UILabel
//  Created by akwei on 14-3-17.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HKAttrLabel : UILabel
@property(nonatomic,strong)NSAttributedString* attrText;

/**
 更新view
 @param fit YES:frame.size与内容边界匹配. NO:不更新自身frame.size
 */
-(void)updateToFit:(BOOL)fit;
@end
