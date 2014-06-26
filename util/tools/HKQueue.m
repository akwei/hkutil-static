//
//  HKQueue.m
//  hkutil-static
//
//  Created by akwei on 6/25/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import "HKQueue.h"

@interface HKQueue ()
@property(nonatomic,strong)NSMutableArray* objList;
@end

@implementation HKQueue{
    dispatch_queue_t _serQueue;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.objList = [NSMutableArray array];
        NSString* queueName = [NSString stringWithFormat:@"HKQueue_queueName_%@",[self description]];
        _serQueue = dispatch_queue_create([queueName UTF8String], DISPATCH_QUEUE_SERIAL);
    }
    return self;
}

-(void)push:(id)obj{
    __weak HKQueue* me = self;
    dispatch_sync(_serQueue, ^{
        [me.objList addObject:obj];
    });
}

-(id)pop{
    __weak HKQueue* me = self;
    __block id obj;
    dispatch_sync(_serQueue, ^{
        if ([me.objList count] > 0) {
            obj =[me.objList lastObject];
            [me.objList removeLastObject];
        }
    });
    return obj;
}

@end
