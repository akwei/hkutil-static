//
//  HKCtrlUtil.h
//  hk_restaurant2
//
//  Created by akwei on 13-6-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKCtrlUtil : NSObject

+(id)ctrlFromNibWithCalss:(Class)clazz;

+(void)doTargetWithObj:(id)obj method:(NSString*)method sender:(id)sender delegate:(id)senderDelegate;

+(void)doTargetWithObj:(id)obj method:(NSString*)method sender:(id)sender delegate:(id)senderDelegate dic:(NSDictionary*)dic;

@end
