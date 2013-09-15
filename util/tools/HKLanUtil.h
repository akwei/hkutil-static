//
//  LanUtil.h
//  huoku_paidui
//
//  Created by 伟 袁 on 12-7-25.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

#define NSHKLocal(_key,_comment) [[LanUtil instance] localWithKey:_key comment:_comment]

@interface HKLanUtil : NSObject

+(HKLanUtil*)instance;

//设置全局选择语言
+(void)setSysLoc:(NSString*)loc;

-(NSString*)localWithKey:(NSString *)key comment:(NSString *)comment;
@end
