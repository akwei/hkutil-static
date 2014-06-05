//
//  HKNFCReader.h
//  hkutil-static
//
//  Created by akwei on 5/23/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

/**
 本类的作用是iPad与android进行通信
 */
@interface HKNFCReader : NSObject
@property(nonatomic,assign)NSTimeInterval writeTimeout;
@property(nonatomic,assign)NSTimeInterval readTimeout;

-(instancetype)initWithHost:(NSString*)host
                       port:(NSUInteger)port
                    timeout:(NSTimeInterval)timeout;

-(BOOL)test;

-(NSString*)swipeWithBeginSwipeBlock:(void (^)(void))beginSwipeBlock;

-(void)stopSwipe;

@end
