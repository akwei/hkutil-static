//
//  HKQueue.h
//  hkutil-static
//
//  Created by akwei on 6/25/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKQueue : NSObject

/**
 向队列添加对象
 @param obj 对象
 */
-(void)push:(id)obj;

-(id)pop;

@end
