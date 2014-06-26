//
//  HKNFCReader2.h
//  hkutil-static
//
//  Created by akwei on 6/25/14.
//  Copyright (c) 2014 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKNFCReader2 : NSObject
@property(nonatomic,assign)NSTimeInterval writeTimeout;
@property(nonatomic,assign)NSTimeInterval readTimeout;
@property(nonatomic,strong)void (^openedBlock)(void);
@property(nonatomic,strong)void (^closedBlock)(void);
@property(nonatomic,strong)void (^getNFCBlock)(NSString* nfc);
@property(nonatomic,strong)void (^failBlock)(NSError* error);

-(instancetype)initWithHost:(NSString*)host
                       port:(NSUInteger)port
                    timeout:(NSTimeInterval)timeout;

-(BOOL)test;

-(void)open;

-(BOOL)isConnected;

-(void)swipe;

-(void)stop;
@end
