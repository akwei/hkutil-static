//
//  KeyboardUtil.h
//  huoku_paidui3
//
//  Created by akwei on 12-8-16.
//  Copyright (c) 2012年 akwei. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKKeyboardNotice : NSObject

@property(nonatomic,assign)CGFloat disHeight;//键盘与view可以有此差异的高度，不一定非要view点高度完全高于键盘顶端

-(id)initWithViewContainer:(UIView*)vc viewForMove:(UIView*)v;

-(void)regist;

-(void)unRegist;


@end
