//
//  EncUtil.m
//  encutil
//
//  Created by 伟 袁 on 12-7-19.
//  Copyright (c) 2012年 __MyCompanyName__. All rights reserved.
//

#import "HKEncUtil.h"
#import <CommonCrypto/CommonDigest.h>
#import <CommonCrypto/CommonCryptor.h>
#import "GTMStringEncoding.h"
#import <Security/Security.h>

@implementation HKEncUtil

+(NSString *)MD5:(NSString *)value{
	int len=CC_MD5_DIGEST_LENGTH;
    const char* ch = [value UTF8String];
    unsigned char result[len];
    CC_MD5(ch, strlen(ch), result);
    NSMutableString *ret = [NSMutableString stringWithCapacity:len];
    for(int i = 0; i<len; i++) {
        [ret appendFormat:@"%02x",result[i]];
    }
    return ret;
}

+(NSString *)bytes2Hex:(NSData *)data{
    unichar* hexChars = (unichar*)malloc(sizeof(unichar) * (data.length*2));
    unsigned char* bytes = (unsigned char*)data.bytes;
    for (NSUInteger i = 0; i < data.length; i++) {
        unichar c = bytes[i] / 16;
        if (c < 10) c += '0';
        else c += 'a' - 10;
        hexChars[i*2] = c;
        c = bytes[i] % 16;
        if (c < 10) c += '0';
        else c += 'a' - 10;
        hexChars[i*2+1] = c;
    }
    NSString* retVal = [[NSString alloc] initWithCharactersNoCopy:hexChars
                                                           length:data.length*2
                                                     freeWhenDone:YES];
    return retVal;
}

+(NSData *)hex2Bytes:(NSString *)str{
    NSMutableData *stringData = [[NSMutableData alloc] init];
    unsigned char whole_byte;
    char byte_chars[3] = {'\0','\0','\0'};
    int i;
    for (i=0; i < [str length] / 2; i++) {
        byte_chars[0] = [str characterAtIndex:i*2];
        byte_chars[1] = [str characterAtIndex:i*2+1];
        whole_byte = strtol(byte_chars, NULL, 16);
        [stringData appendBytes:&whole_byte length:1];
    }
    return stringData;
}

+(NSString *)BASE64EncryptString:(NSString *)value{
    GTMStringEncoding *coder = [GTMStringEncoding rfc4648Base64StringEncoding];
    return [coder encodeString:value];
}

+(NSString *)BASE64EncryptData:(NSData *)data{
    GTMStringEncoding *coder = [GTMStringEncoding rfc4648Base64StringEncoding];
    return [coder encode:data];
}

+(NSData *)BASE64DecryptString:(NSString *)value{
    GTMStringEncoding *coder = [GTMStringEncoding rfc4648Base64StringEncoding];
    return [coder decode:value];
}

+(NSData *)DESEncryptWithData:(NSData *)data forKey:(NSString *)key{
    NSData* encData=[HKEncUtil desData:data key:key CCOperation:kCCEncrypt];
    return encData;
}

+(NSData *)DESDecryptWithData:(NSData *)data forKey:(NSString *)key{
    NSData* deData=[HKEncUtil desData:data key:key CCOperation:kCCDecrypt];
    return deData;
}

+(NSData *)DESEDEEncryptWithData:(NSData *)data forKey:(NSString *)key{
    const void *vplainText = (const void *)[data bytes];
    size_t plainTextBufferSize = [data length];
    NSData* encData = [self encodeAndDecodeDESEDEWithKey:key size_t:plainTextBufferSize vplainText:vplainText encryptOrDecrypt:kCCEncrypt];
    return encData;
}

+(NSData *)DESEDEDecryptWithData:(NSData *)data forKey:(NSString *)key{
    const void *vplainText = (const void *)[data bytes];
    size_t plainTextBufferSize = [data length];
    NSData* deData = [self encodeAndDecodeDESEDEWithKey:key size_t:plainTextBufferSize vplainText:vplainText encryptOrDecrypt:kCCDecrypt];
    return deData;
}

+ (NSData *)AES128EncryptWithData:(NSData*)data forKey:(NSString *)key {
	return [self AESEncryptWithData:data forKey:key algorithm:kCCAlgorithmAES128 size:kCCKeySizeAES128 blockSize:kCCBlockSizeAES128];
}

+ (NSData *)AES128DecryptWithData:(NSData*)data forKey:(NSString *)key {
    return [self AESDecryptWithData:data forKey:key algorithm:kCCAlgorithmAES128 size:kCCKeySizeAES128 blockSize:kCCBlockSizeAES128];
}

+ (NSData *)AES256EncryptWithData:(NSData*)data forKey:(NSString *)key {
    return [self AESEncryptWithData:data forKey:key algorithm:kCCAlgorithmAES128 size:kCCKeySizeAES256 blockSize:kCCBlockSizeAES128];
}

+ (NSData *)AES256DecryptWithData:(NSData*)data forKey:(NSString *)key {
	return [self AESDecryptWithData:data forKey:key algorithm:kCCAlgorithmAES128 size:kCCKeySizeAES256 blockSize:kCCBlockSizeAES128];
}

+ (NSData *)desData:(NSData *)data key:(NSString *)keyString CCOperation:(CCOperation)op
{
    char buffer [1024] ;
    memset(buffer, 0, sizeof(buffer));
    size_t bufferNumBytes;
    CCCryptorStatus cryptStatus = CCCrypt(op,
                                          
                                          kCCAlgorithmDES,
                                          
                                          kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          
                                          [keyString UTF8String],
                                          
                                          kCCKeySizeDES,
                                          
                                          NULL,
                                          
                                          [data bytes],
                                          
                                          [data length],
                                          
                                          buffer,
                                          
                                          1024,
                                          
                                          &bufferNumBytes);
    if(cryptStatus == kCCSuccess){
        NSData *returnData =  [NSData dataWithBytes:buffer length:bufferNumBytes];
        return returnData;
    }
    NSLog(@"des failed！");
    return nil;
    
}

+(NSString*)formatKey:(NSString*)key{
    NSData* keyData=[key dataUsingEncoding:NSUTF8StringEncoding];
    Byte* keyBytes=(Byte*)[keyData bytes];
    NSMutableData *nKeyMutableData=[[NSMutableData alloc] init];
    for (int i=0; i<24; i++) {
        Byte byte[]={0};
        [nKeyMutableData appendBytes:byte length:sizeof(byte)];
    }
    int keyLen=[keyData length];
    Byte* newKeyBytes=(Byte*)[nKeyMutableData bytes];
    for (int i=0; i<keyLen && i<[nKeyMutableData length]; i++) {
        newKeyBytes[i]=keyBytes[i];
    }
    int newKeyBytesLen=[nKeyMutableData length];
    NSData* newKeydata=[NSData dataWithBytes:newKeyBytes length:newKeyBytesLen];
    NSString* newKey=[[NSString alloc] initWithData:newKeydata encoding:NSUTF8StringEncoding];
    return newKey;
}

+(NSData *)encodeAndDecodeDESEDEWithKey:(NSString *)key size_t:(size_t)plainTextBufferSize vplainText:(const void *)vplainText encryptOrDecrypt:(CCOperation)encryptOrDecrypt{
    
    CCCryptorStatus ccStatus;
    uint8_t *bufferPtr = NULL;
    size_t bufferPtrSize = 0;
    size_t movedBytes = 0;
    
    bufferPtrSize = (plainTextBufferSize + kCCBlockSize3DES) & ~(kCCBlockSize3DES - 1);
    bufferPtr = malloc( bufferPtrSize * sizeof(uint8_t));
    memset((void *)bufferPtr, 0x0, bufferPtrSize);
    // memset((void *) iv, 0x0, (size_t) sizeof(iv));
    
    NSString* nKey=[HKEncUtil formatKey:key];
    const void *vkey = (const void *) [nKey UTF8String];
    // NSString *initVec = @"init Vec";
    //const void *vinitVec = (const void *) [initVec UTF8String];
    //  Byte iv[] = {0x12, 0x34, 0x56, 0x78, 0x90, 0xAB, 0xCD, 0xEF};
    ccStatus = CCCrypt(encryptOrDecrypt,
                       kCCAlgorithm3DES,
                       kCCOptionPKCS7Padding | kCCOptionECBMode,
                       vkey,
                       kCCKeySize3DES,
                       nil,
                       vplainText,
                       plainTextBufferSize,
                       (void *)bufferPtr,
                       bufferPtrSize,
                       &movedBytes);
    if (ccStatus!=kCCSuccess) {
        free(bufferPtr);
        return nil;
    }
    //if (ccStatus == kCCSuccess) NSLog(@"SUCCESS");
    /*else if (ccStatus == kCC ParamError) return @"PARAM ERROR";
     else if (ccStatus == kCCBufferTooSmall) return @"BUFFER TOO SMALL";
     else if (ccStatus == kCCMemoryFailure) return @"MEMORY FAILURE";
     else if (ccStatus == kCCAlignmentError) return @"ALIGNMENT";
     else if (ccStatus == kCCDecodeError) return @"DECODE ERROR";
     else if (ccStatus == kCCUnimplemented) return @"UNIMPLEMENTED"; */
    
    NSData *data = [NSData dataWithBytes:(const void *)bufferPtr length:(NSUInteger)movedBytes];
    free(bufferPtr);
    return data;
}

+ (NSData *)AESDecryptWithData:(NSData*)data forKey:(NSString *)key algorithm:(size_t)algorithm size:(size_t)bsize blockSize:(size_t)blockSize{
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[bsize+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [data length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + blockSize;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesDecrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCDecrypt, algorithm, kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, bsize,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesDecrypted);
	
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesDecrypted];
	}
	
	free(buffer); //free the buffer;
	return nil;
}

+ (NSData *)AESEncryptWithData:(NSData*)data forKey:(NSString *)key algorithm:(size_t)algorithm size:(size_t)bsize blockSize:(size_t)blockSize{
	// 'key' should be 32 bytes for AES256, will be null-padded otherwise
	char keyPtr[bsize+1]; // room for terminator (unused)
	bzero(keyPtr, sizeof(keyPtr)); // fill with zeroes (for padding)
	
	// fetch key data
	[key getCString:keyPtr maxLength:sizeof(keyPtr) encoding:NSUTF8StringEncoding];
	
	NSUInteger dataLength = [data length];
	
	//See the doc: For block ciphers, the output size will always be less than or
	//equal to the input size plus the size of one block.
	//That's why we need to add the size of one block here
	size_t bufferSize = dataLength + blockSize;
	void *buffer = malloc(bufferSize);
	
	size_t numBytesEncrypted = 0;
	CCCryptorStatus cryptStatus = CCCrypt(kCCEncrypt, algorithm, kCCOptionPKCS7Padding | kCCOptionECBMode,
                                          keyPtr, bsize,
                                          NULL /* initialization vector (optional) */,
                                          [data bytes], dataLength, /* input */
                                          buffer, bufferSize, /* output */
                                          &numBytesEncrypted);
	if (cryptStatus == kCCSuccess) {
		//the returned NSData takes ownership of the buffer and will free it on deallocation
		return [NSData dataWithBytesNoCopy:buffer length:numBytesEncrypted];
	}
    
	free(buffer); //free the buffer;
	return nil;
}


@end
