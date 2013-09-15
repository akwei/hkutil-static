//
//  HKRSAUtil.m
//  hkutil2
//
//  Created by akwei on 13-5-1.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKRSAUtil.h"

@interface HKRSAUtil ()
@property(nonatomic,strong)NSData* publicKeyData;
@property(nonatomic,strong)NSData* privateKeyData;
@property(nonatomic,assign)BOOL isX509PublickKey;
@property(nonatomic,copy)NSString* publicKeyTag;
@property(nonatomic,copy)NSString* privateKeyTag;
@end

@implementation HKRSAUtil{
    SecKeyRef _publicSecKeyRef;
    SecKeyRef _privateSecKeyRef;
}

-(id)initWithPublickKeyData:(NSData *)publicKeyData
           isX509PublickKey:(BOOL)isX509PublickKey
             privateKeyData:(NSData *)privateKeyData
               publicKeyTag:(NSString *)publicKeyTag
              privateKeyTag:(NSString *)privateKeyTag{
    self = [super init];
    if (self) {
        self.publicKeyData = publicKeyData;
        self.privateKeyData = privateKeyData;
        self.isX509PublickKey = isX509PublickKey;
        self.publicKeyTag = publicKeyTag;
        self.privateKeyTag = privateKeyTag;
        [self reBuildKeyInfo];
    }
    return self;
}

-(void)dealloc{
    [self deleteKeys];
}

-(void)reBuildKeyInfo{
    if (self.publicKeyData) {
        NSData* tagData= [self.publicKeyTag dataUsingEncoding:NSUTF8StringEncoding];
        [self setPublicKey:self.publicKeyData tag:tagData];
        _publicSecKeyRef = [self keyRefWithTag:tagData];
    }
    if (self.privateKeyData) {
        NSData* tagData= [self.privateKeyTag dataUsingEncoding:NSUTF8StringEncoding];
        [self setPrivateKey:self.privateKeyData tag:tagData];
        _privateSecKeyRef = [self keyRefWithTag:tagData];
    }
}

- (SecKeyRef)keyRefWithTag:(NSData *)tagData
{
    NSMutableDictionary *queryKey = [self keyQueryDictionary:tagData];
    [queryKey setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnRef];
    
    SecKeyRef key = NULL;
    OSStatus err = SecItemCopyMatching((__bridge CFDictionaryRef)queryKey, (CFTypeRef *)&key);
    
    if (err != noErr)
    {
        NSLog(@"HKRSAUtil.keyRefWithTag err. status=%ld",err);        
        return nil;
    }
    return key;
}

- (void)setPrivateKey:(NSData *)keyData
                  tag:(NSData *)tagData
{
    [self removeKey:tagData];
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:tagData];
    [keyQueryDictionary setObject:keyData forKey:(__bridge id)kSecValueData];
    [keyQueryDictionary setObject:(__bridge id)kSecAttrKeyClassPrivate forKey:(__bridge id)kSecAttrKeyClass];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    CFTypeRef persistKey = nil;
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)keyQueryDictionary, &persistKey);
    
    if (persistKey != nil)
    {
        CFRelease(persistKey);
    }
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        NSLog(@"HKRSAUtil.setPrivateKey err. status=%ld",secStatus);
        return;
    }
    
    return;
}

- (void)setPublicKey:(NSData*)keyData
                 tag:(NSData *)tagData
{
    [self removeKey:tagData];
    NSData* data = [self strippedPublicKey:keyData isX509Key:YES];
    CFTypeRef persistKey = nil;
    
    NSMutableDictionary *keyQueryDictionary = [self keyQueryDictionary:tagData];
    [keyQueryDictionary setObject:data forKey:(__bridge id)kSecValueData];
    [keyQueryDictionary setObject:(__bridge id)kSecAttrKeyClassPublic forKey:(__bridge id)kSecAttrKeyClass];
    [keyQueryDictionary setObject:[NSNumber numberWithBool:YES] forKey:(__bridge id)kSecReturnPersistentRef];
    
    OSStatus secStatus = SecItemAdd((__bridge CFDictionaryRef)keyQueryDictionary, &persistKey);
    
    if (persistKey != nil)
    {
        CFRelease(persistKey);
    }
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        NSLog(@"HKRSAUtil.setPublicKey err. status=%ld",secStatus);
        return;
    }
    
    return;
}

- (void)removeKey:(NSData *)tagData
{
    NSDictionary *queryKey = [self keyQueryDictionary:tagData];
    OSStatus secStatus = SecItemDelete((__bridge CFDictionaryRef)queryKey);
    
    if ((secStatus != noErr) && (secStatus != errSecDuplicateItem))
    {
        //
    }
}

- (NSMutableDictionary *)keyQueryDictionary:(NSData *)tagData
{
    NSMutableDictionary *result = [[NSMutableDictionary alloc] init];
    [result setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
    [result setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
    [result setObject:tagData forKey:(__bridge id)kSecAttrApplicationTag];
    [result setObject:(__bridge id)kSecAttrAccessibleWhenUnlocked forKey:(__bridge id)kSecAttrAccessible];
    
    return result;
}

- (void)deleteKeys {
//	OSStatus sanityCheck = noErr;
	if (self.publicKeyTag) {
        NSMutableDictionary * queryPublicKey = [NSMutableDictionary dictionaryWithCapacity:0];
        // Set the public key query dictionary.
        [queryPublicKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
        [queryPublicKey setObject:self.publicKeyTag forKey:(__bridge id)kSecAttrApplicationTag];
        [queryPublicKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
        // Delete the public key.
        SecItemDelete((__bridge CFDictionaryRef)queryPublicKey);
    }
	if (self.privateKeyTag) {
        NSMutableDictionary * queryPrivateKey = [NSMutableDictionary dictionaryWithCapacity:0];
        // Set the private key query dictionary.
        [queryPrivateKey setObject:(__bridge id)kSecClassKey forKey:(__bridge id)kSecClass];
        [queryPrivateKey setObject:self.privateKeyTag forKey:(__bridge id)kSecAttrApplicationTag];
        [queryPrivateKey setObject:(__bridge id)kSecAttrKeyTypeRSA forKey:(__bridge id)kSecAttrKeyType];
        // Delete the private key.
        SecItemDelete((__bridge CFDictionaryRef)queryPrivateKey);
    }
	if (_publicSecKeyRef) CFRelease(_publicSecKeyRef);
	if (_privateSecKeyRef) CFRelease(_privateSecKeyRef);
}

-(NSData *)encryptData:(NSData *)data{
    SecKeyRef key = _publicSecKeyRef;
    OSStatus status = noErr;
    size_t dataLength = [data length];
    size_t cipherBufferSize = SecKeyGetBlockSize(key);
    uint8_t* cipherBuffer = malloc( cipherBufferSize * sizeof(uint8_t) );
    memset((void *)cipherBuffer, 0x0, cipherBufferSize);
    NSInteger blockSize = cipherBufferSize - 12;
    NSInteger blockCount = dataLength / blockSize;
    if (dataLength % blockSize !=0) {
        blockCount = blockCount + 1;
    }
    NSMutableData* mData = [[NSMutableData alloc] init];
    for (int i=0; i<blockCount; i++) {
        int bufferSize = MIN(blockSize,dataLength - i * blockSize);
        NSData* subBuffer = [data subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        status = SecKeyEncrypt(key,
                               kSecPaddingPKCS1,
                               (const uint8_t*)[subBuffer bytes],
                               [subBuffer length],
                               cipherBuffer,
                               &cipherBufferSize);
        if (status == errSecSuccess) {
            [mData appendBytes:cipherBuffer length:cipherBufferSize];
        }
        else{
            free(cipherBuffer);
            NSLog(@"rsa encrypt has error. status=%ld",status);
            return nil;
        }
    }
    free(cipherBuffer);
    return mData;
}

-(NSData *)decryptData:(NSData *)data{
    SecKeyRef key = _privateSecKeyRef;
    OSStatus status = noErr;
    size_t cipherBufferSize = [data length];
//    uint8_t* cipherBuffer = (uint8_t *)[data bytes];
    size_t plainBufferSize = SecKeyGetBlockSize(key) ;
    uint8_t* plainBuffer = malloc( plainBufferSize * sizeof(uint8_t) );
	memset((void *)plainBuffer, 0x0, plainBufferSize);
    
    // Ordinarily, you would split the data up into blocks
    // equal to plainBufferSize, with the last block being
    // shorter. For simplicity, this example assumes that
    // the data is short enough to fit.
    
    NSInteger blockSize = plainBufferSize;
    NSInteger blockCount = cipherBufferSize / blockSize;
    if (cipherBufferSize % blockSize !=0) {
        blockCount = blockCount + 1;
    }
    NSMutableData* mData = [[NSMutableData alloc] init];
    for (int i=0; i<blockCount; i++) {
        int bufferSize = MIN(blockSize,cipherBufferSize - i * blockSize);
        NSData* subBuffer = [data subdataWithRange:NSMakeRange(i * blockSize, bufferSize)];
        status = SecKeyDecrypt(key,
                               kSecPaddingPKCS1,
                               (const uint8_t*)[subBuffer bytes],
                               [subBuffer length],
                               plainBuffer,
                               &plainBufferSize);
        if (status == errSecSuccess) {
            [mData appendBytes:plainBuffer length:plainBufferSize];
        }
        else{
            free(plainBuffer);
            NSLog(@"rsa decrypt has error. status=%ld",status);
            return nil;
        }
    }
    free(plainBuffer);
    return mData;
}
- (NSData *)strippedPublicKey:(NSData *)keyData isX509Key:(BOOL)isX509Key
{
    NSData *strippedPublicKeyData = keyData;
    if (isX509Key)
    {
        unsigned char * bytes = (unsigned char *)[strippedPublicKeyData bytes];
        size_t bytesLen = [strippedPublicKeyData length];
        
        size_t i = 0;
        if (bytes[i++] != 0x30)
        {
            return nil;
        }
        
        if (bytes[i] > 0x80)
        {
            i += bytes[i] - 0x80 + 1;
        }
        else
        {
            i++;
        }
        
        if (i >= bytesLen)
        {
            return nil;
        }
        if (bytes[i] != 0x30)
        {
            return nil;
        }
        
        i += 15;
        
        if (i >= bytesLen - 2)
        {
            return nil;
        }
        if (bytes[i++] != 0x03)
        {
            return nil;
        }
        
        if (bytes[i] > 0x80)
        {
            i += bytes[i] - 0x80 + 1;
        }
        else
        {
            i++;
        }
        
        if (i >= bytesLen)
        {
            return nil;
        }
        if (bytes[i++] != 0x00)
        {
            return nil;
        }
        if (i >= bytesLen)
        {
            return nil;
        }
        strippedPublicKeyData = [NSData dataWithBytes:&bytes[i]
                                               length:bytesLen - i];
    }
    
    if (!strippedPublicKeyData)
    {
        return nil;
    }
    
    return strippedPublicKeyData;
}
@end
