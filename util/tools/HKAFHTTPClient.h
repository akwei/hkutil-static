//
//  HKAFHTTPClient.h
//  hkutil2
//  同步方式使用AFNetworking
//  Created by akwei on 13-5-28.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKAFHTTPClient : NSObject
@property(nonatomic,copy) NSString* baseUrl;
@property(nonatomic,copy) NSString* subUrl;
@property(nonatomic,copy)NSString* responseString;
@property(nonatomic,copy)NSData* responseData;
@property(nonatomic,assign)BOOL forText;
@property(nonatomic,assign)NSTimeInterval timeout;
@property(nonatomic,assign)NSInteger maxRetry;
@property(nonatomic,strong)NSError* error;
@property(nonatomic,assign)NSInteger responseStatusCode;
@property(nonatomic,copy)NSString* responseStatusText;
@property(nonatomic,strong) NSArray* responseCookies;
@property(nonatomic,strong) NSMutableDictionary* params;
@property(nonatomic,assign)BOOL debug;

-(void)addString:(NSString*)value forKey:(NSString *)key;
-(void)addInteger:(NSInteger)value forKey:(NSString*)key;
-(void)addUnsignedInteger:(NSUInteger)value forKey:(NSString*)key;
-(void)addBOOL:(BOOL)value forKey:(NSString*)key;
-(void)addFloat:(float)value forKey:(NSString*)key;
-(void)addDouble:(double)value forKey:(NSString*)key;
-(void)addLong:(long)value forKey:(NSString*)key;
-(void)addUnsignedLong:(unsigned long)value forKey:(NSString*)key;
-(void)addLongLong:(long long)value forKey:(NSString*)key;
-(void)addUnsignedLongLong:(unsigned long long)value forKey:(NSString*)key;
-(void)addDoubleForDate:(NSDate*)value forKey:(NSString*)key;
-(void)addData:(NSData *)value forKey:(NSString *)key;
-(void)addPostText:(NSString*)text;

-(void)addHeaderString:(NSString*)value forKey:(NSString*)key;
-(void)addHeaderInteger:(NSInteger)value forKey:(NSString*)key;
-(void)addHeaderUnsignedInteger:(NSUInteger)value forKey:(NSString*)key;
-(void)addHeaderLong:(long)value forKey:(NSString*)key;
-(void)addHeaderUnsignedLong:(unsigned long)value forKey:(NSString*)key;
-(void)addHeaderLongLong:(long long)value forKey:(NSString*)key;
-(void)addHeaderUnsignedLongLong:(unsigned long long)value forKey:(NSString*)key;
-(void)addHeaderFloat:(float)value forKey:(NSString*)key;
-(void)addHeaderDouble:(double)value forKey:(NSString*)key;

-(void)addCookie:(NSHTTPCookie*)cookie;

-(void)doPost;

-(void)doGet;

@end
