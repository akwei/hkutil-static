//
//  EncUtil.h
//  encutil
//
//  Created by 伟 袁 on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKEncUtil : NSObject

+(NSString*)MD5:(NSString*)value;

+(NSString *)BASE64EncryptString:(NSString *)value;
+(NSString *)BASE64EncryptData:(NSData *)data;
+(NSData *)BASE64DecryptString:(NSString *)value;

+(NSData*)DESEncryptWithData:(NSData*)data forKey:(NSString *)key;
+(NSData*)DESDecryptWithData:(NSData*)data forKey:(NSString *)key;

+(NSData*)DESEDEEncryptWithData:(NSData*)data forKey:(NSString *)key;
+(NSData*)DESEDEDecryptWithData:(NSData*)data forKey:(NSString *)key;

+(NSData *)AES256EncryptWithData:(NSData*)data forKey:(NSString *)key;
+(NSData *)AES256DecryptWithData:(NSData*)data forKey:(NSString *)key;

+(NSData *)AES128EncryptWithData:(NSData*)data forKey:(NSString *)key;
+(NSData *)AES128DecryptWithData:(NSData*)data forKey:(NSString *)key;

+(NSString*)bytes2Hex:(NSData*)data;
+(NSData*)hex2Bytes:(NSString*)str;

@end
