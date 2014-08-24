//
//  HKRSAUtil.h
//  hkutil2
//
//  Created by akwei on 13-5-1.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface HKRSAUtil : NSObject

-(instancetype)initWithPublickKeyData:(NSData*)publicKeyData
                     isX509PublickKey:(BOOL)isX509PublickKey
                       privateKeyData:(NSData*)privateKeyData
                         publicKeyTag:(NSString*)publicKeyTag
                        privateKeyTag:(NSString*)privateKeyTag;

-(void)generateKeyPair:(NSUInteger)keySize;
- (void)setPublicKey:(NSData*)keyData tag:(NSData *)tagData;
- (void)setPrivateKey:(NSData *)keyData tag:(NSData *)tagData;
-(NSData*)encryptData:(NSData*)data;
-(NSData*)decryptData:(NSData*)data;


@end
