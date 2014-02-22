//
//  HKMVC.h
//  hkutil-static
//
//  Created by akwei on 14-2-18.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKKVO.h"

@interface HKMVC : HKKVO<HKKVODelegate>
@property(nonatomic,assign)id mvcDelegate;

-(id)initWithMvcDelegate:(id)mvcDelegate;
-(void)setInfoValue:(id)value forKey:(NSString*)key;
-(id)infoValueForKey:(NSString *)key;

@end
