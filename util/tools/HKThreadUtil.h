//
//  HKThreadUtil.h
//  hkutil2
//
//  Created by akwei on 13-4-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

/*
 线程工具类，使用GCD解决异步多线程问题
 */

#import <Foundation/Foundation.h>

@interface HKThreadUtil : NSObject
//单例
+(HKThreadUtil*)shareInstance;
//异步提交到并发队列中
-(void)asyncBlock:(void (^)(void))block;
//异步提交到主线程中
-(void)asyncBlockToMainThread:(void(^)(void))block;
//同步提交到主线程中
-(void)syncBlockToMainThread:(void(^)(void))block;
@end
