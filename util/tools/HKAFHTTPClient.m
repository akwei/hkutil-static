//
//  HKAFHTTPClient.m
//  hkutil2
//
//  Created by akwei on 13-5-28.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKAFHTTPClient.h"
#import "AFHTTPClient.h"
#import "AFHTTPRequestOperation.h"

@interface HKAFHTTPClient ()
@property(nonatomic,strong) NSMutableDictionary *dataParams;//请求的上传数据的key_value值
@property(nonatomic,strong) NSMutableArray *postTextArr;//post body
@property(nonatomic,strong) NSMutableDictionary* headers;
@property(nonatomic,strong) AFHTTPClient* client;
@property(nonatomic,assign) NSHTTPCookieStorage* cookieStorage;

@end

@implementation HKAFHTTPClient{
    BOOL _done;
    NSCondition* condition;
    dispatch_queue_t _asyncQueue;
}

-(id)init{
    self = [super init];
    if (self) {
        self.params = [[NSMutableDictionary alloc] init];
        self.headers = [[NSMutableDictionary alloc] init];
        self.dataParams = [[NSMutableDictionary alloc] init];
        self.cookieStorage = [NSHTTPCookieStorage sharedHTTPCookieStorage];
        [self.cookieStorage setCookieAcceptPolicy:NSHTTPCookieAcceptPolicyAlways];
        self.forText = YES;
        condition = [[NSCondition alloc] init];
        NSString* qname = [[NSString alloc] initWithFormat:@"HKAFHTTPClient._asyncQueue.name.%@",[self description]];
        _asyncQueue = dispatch_queue_create([qname UTF8String], DISPATCH_QUEUE_CONCURRENT);
    }
    return self;
}

-(void)dealloc{
#if __IPHONE_OS_VERSION_MAX_ALLOWED < __IPHONE_6_0
    dispatch_release(_asyncQueue);
#endif
}

-(void)executeMethod:(NSString*)method{
    [condition lock];
    self.client = [AFHTTPClient clientWithBaseURL:[NSURL URLWithString:self.baseUrl]];
    self.client.stringEncoding = NSUTF8StringEncoding;
    self.client.parameterEncoding = AFFormURLParameterEncoding;
    NSDictionary* headersFromCookies = [NSHTTPCookie requestHeaderFieldsWithCookies:self.cookieStorage.cookies];
    [self.headers addEntriesFromDictionary:headersFromCookies];
    for (NSString* key in self.headers) {
        NSString* value = [self.headers valueForKey:key];
        [self.client setDefaultHeader:key value:value];
    }
    NSMutableURLRequest* request = [self createRequest:method];
    __weak HKAFHTTPClient* me = self;
    AFHTTPRequestOperation *operation = [self.client HTTPRequestOperationWithRequest:request success:^(AFHTTPRequestOperation *operation, id responseObject) {
        [me onFinish:operation :nil];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [me onFinish:operation :error];
    }];
    operation.successCallbackQueue = _asyncQueue;
    operation.failureCallbackQueue = _asyncQueue;
    [self.client enqueueHTTPRequestOperation:operation];
#if DEBUG_HKAFHTTPClient
    NSLog(@"url:%@",[[NSURL URLWithString:self.subUrl relativeToURL:[NSURL URLWithString:self.baseUrl]] absoluteString]);
    NSLog(@"http request %@",[request description]);
    NSLog(@"request data :\n");
    [self.params enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSLog(@"%@=%@",key,obj);
    }];
#endif
    while (!_done) {
        [condition wait];
    }
    [condition unlock];
}

-(NSMutableURLRequest*)createRequest:(NSString*)method{
    NSDictionary* uparams = nil;
    if ([self.params count] > 0) {
        uparams = self.params;
    }
    NSMutableURLRequest *request = nil;
    HKAFHTTPClient* me = self;
    if ([self.dataParams count] > 0) {
        request = [self.client multipartFormRequestWithMethod:method path:self.subUrl parameters:uparams constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
            for (NSString* key in me.dataParams) {
                id obj = [me.dataParams valueForKey:key];
                [formData appendPartWithFileData:obj name:key fileName:key mimeType:@"data/file"];
            }
        }];
    }
    else{
        request = [self.client requestWithMethod:method path:self.subUrl parameters:uparams];
    }
    request.timeoutInterval = self.timeout;
    return request;
}

-(void)doGet{
    [self executeMethod:@"GET"];
}

-(void)doPost{
    [self executeMethod:@"POST"];
}

-(void)onFinish:(AFHTTPRequestOperation *)operation :(NSError *)error{
    [condition lock];
    self.responseStatusCode = operation.response.statusCode;
    self.responseStatusText = [NSHTTPURLResponse localizedStringForStatusCode:self.responseStatusCode];
    self.responseData = operation.responseData;
    if (self.cookieStorage.cookies) {
        self.responseCookies = self.cookieStorage.cookies;
    }
    if (self.forText && self.responseData) {
        self.responseString = [[NSString alloc] initWithData:self.responseData encoding:NSUTF8StringEncoding];
    }
#if DEBUG_HKAFHTTPClient
    NSLog(@"responseStatusCode:%d",self.responseStatusCode);
    NSLog(@"responseStatusText:%@",self.responseStatusText);
    if (self.forText) {
        NSLog(@"responseString:%@",self.responseString);
    }
    if (error) {
        NSLog(@"http error:%@",[error description]);
    }
#endif
    _done = YES;
    [condition signal];
    [condition unlock];
    self.client = nil;
}


-(void)doFireTimer:(id)obj{
    NSLog(@"doFireTimer:%@",[obj description]);
}

void myRunLoopObserver(CFRunLoopObserverRef observer, CFRunLoopActivity activity, void *info){
    if (activity == kCFRunLoopEntry) {
        NSLog(@"activity = kCFRunLoopEntry");
    }
    else if (activity == kCFRunLoopBeforeTimers){
        NSLog(@"activity = kCFRunLoopBeforeTimers");
    }
    else if (activity == kCFRunLoopBeforeSources){
        NSLog(@"activity = kCFRunLoopBeforeSources");
    }
    else if (activity == kCFRunLoopBeforeWaiting){
        NSLog(@"activity = kCFRunLoopBeforeWaiting");
    }
    else if (activity == kCFRunLoopAfterWaiting){
        NSLog(@"activity = kCFRunLoopAfterWaiting");
    }
    else if (activity == kCFRunLoopExit){
        NSLog(@"activity = kCFRunLoopExit");
    }
    else if (activity == kCFRunLoopAllActivities){
        NSLog(@"activity = kCFRunLoopAllActivities");
    }
}

#pragma mark - addKeyValue method
-(void)addParam:(id)value forKey:(NSString *)key{
    if (!value) {
        return;
    }
	[self.params setObject:value forKey:key];
}

-(void)addString:(NSString *)value forKey:(NSString *)key{
    [self addParam:value forKey:key];
}

-(void)addInteger:(NSInteger)value forKey:(NSString *)key{
    NSNumber* n=[[NSNumber alloc] initWithInteger:value];
    [self addString:[n stringValue] forKey:key];
}

-(void)addUnsignedInteger:(NSUInteger)value forKey:(NSString *)key{
    NSNumber* n=[[NSNumber alloc] initWithUnsignedInteger:value];
    [self addString:[n stringValue] forKey:key];
}

-(void)addBOOL:(BOOL)value forKey:(NSString *)key{
    if (value) {
        [self addString:@"true" forKey:key];
    }
    else{
        [self addString:@"false" forKey:key];
    }
}

-(void)addFloat:(float)value forKey:(NSString *)key{
    NSNumber* n=[[NSNumber alloc] initWithFloat:value];
    [self addString:[n stringValue] forKey:key];
}

-(void)addDouble:(double)value forKey:(NSString *)key{
    NSNumber* n=[[NSNumber alloc] initWithDouble:value];
    [self addString:[n stringValue] forKey:key];
}

-(void)addDoubleForDate:(NSDate *)value forKey:(NSString *)key{
    double t=[value timeIntervalSince1970];
    NSInteger int_t=(NSInteger)t;
    [self addInteger:int_t forKey:key];
}

-(void)addLong:(long)value forKey:(NSString *)key{
    NSNumber* n=[[NSNumber alloc] initWithLong:value];
    [self addString:[n stringValue] forKey:key];
}

-(void)addUnsignedLong:(unsigned long)value forKey:(NSString *)key{
    NSNumber* n=[[NSNumber alloc] initWithUnsignedLong:value];
    [self addString:[n stringValue] forKey:key];
}

-(void)addLongLong:(long long)value forKey:(NSString *)key{
    NSNumber* n=[[NSNumber alloc] initWithLongLong:value];
    [self addString:[n stringValue] forKey:key];
}

-(void)addUnsignedLongLong:(unsigned long long)value forKey:(NSString *)key{
    NSNumber* n=[[NSNumber alloc] initWithUnsignedLongLong:value];
    [self addString:[n stringValue] forKey:key];
}

-(void)addData:(NSData *)value forKey:(NSString *)key{
	[self.dataParams setObject:value forKey:key];
}

-(void)addPostText:(NSString *)text{
    [self.postTextArr addObject:text];
}

#pragma mark - header method

-(void)addHeaderString:(NSString *)value forKey:(NSString *)key{
    [self.headers setValue:value forKey:key];
}

-(void)addHeaderInteger:(NSInteger)value forKey:(NSString *)key{
    NSNumber* n = [[NSNumber alloc] initWithInteger:value];
    [self addHeaderString:[n stringValue] forKey:key];
}

-(void)addHeaderUnsignedInteger:(NSUInteger)value forKey:(NSString *)key{
    NSNumber* n = [[NSNumber alloc] initWithUnsignedInteger:value];
    [self addHeaderString:[n stringValue] forKey:key];
}

-(void)addHeaderLong:(long)value forKey:(NSString *)key{
    NSNumber* n = [[NSNumber alloc] initWithLong:value];
    [self addHeaderString:[n stringValue] forKey:key];
}

-(void)addHeaderUnsignedLong:(unsigned long)value forKey:(NSString *)key{
    NSNumber* n = [[NSNumber alloc] initWithUnsignedLong:value];
    [self addHeaderString:[n stringValue] forKey:key];
}

-(void)addHeaderLongLong:(long long)value forKey:(NSString *)key{
    NSNumber* n = [[NSNumber alloc] initWithLongLong:value];
    [self addHeaderString:[n stringValue] forKey:key];
}

-(void)addHeaderUnsignedLongLong:(unsigned long long)value forKey:(NSString *)key{
    NSNumber* n = [[NSNumber alloc] initWithUnsignedLongLong:value];
    [self addHeaderString:[n stringValue] forKey:key];
}

-(void)addHeaderDouble:(double)value forKey:(NSString *)key{
    NSNumber* n = [[NSNumber alloc] initWithDouble:value];
    [self addHeaderString:[n stringValue] forKey:key];
}

-(void)addHeaderFloat:(float)value forKey:(NSString *)key{
    NSNumber* n = [[NSNumber alloc] initWithFloat:value];
    [self addHeaderString:[n stringValue] forKey:key];
}

#pragma mark - cookie method

-(void)addCookie:(NSHTTPCookie *)cookie{
    [self.cookieStorage setCookie:cookie];
}

#pragma mark - common method

- (NSString*)encodeURL:(NSString *)string
{
    NSString *encodedString = (NSString *)CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(
                                                                                                    NULL,
                                                                                                    (__bridge CFStringRef)string,
                                                                                                    NULL,
                                                                                                    //                                                                                  (CFStringRef)@"!*'();:@&=+$,/?%#[]",
                                                                                                    (CFStringRef)@":/?#[]@!$ &'()*+,;=\"<>%{}|\\^~`",
                                                                                                    kCFStringEncodingUTF8 ));
    return encodedString;
}

#pragma mark - override

-(NSString *)description{
    return [self.client description];
}

@end
