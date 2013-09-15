//
//  HKURLImageView.m
//  hkutil2
//
//  Created by akwei on 13-4-22.
//  Copyright (c) 2013年 huoku. All rights reserved.
//

#import "HKURLImageView.h"
#import "HKDownloader.h"
#import "HKCache.h"
#import "HKThreadUtil.h"

static HKDownloaderMgr* _shareDownloaderMgr;
static NSTimeInterval _globalTimeout;
static HKCache* _cache = nil;
@implementation HKURLImageView{
    //    NSData* _imageData;
    UIImage* _oimage;
    NSString* _imageUrl;
    UIActivityIndicatorView* _indicatorView;
}

+(void)setGlobalTimeout:(NSTimeInterval)t{
    _globalTimeout = t;
}

+(NSTimeInterval)getGlobalTimeout{
    return _globalTimeout;
}

+(void)setCache:(HKCache *)cache{
    if (cache == _cache) {
        return;
    }
    _cache = cache;
}

+(void)initialize{
    _globalTimeout = 30;
}

-(id)init{
    self = [super init];
    if (self) {
        self.loadingStyle = UIActivityIndicatorViewStyleGray;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self = [super initWithCoder:aDecoder];
    if (self) {
        self.loadingStyle = UIActivityIndicatorViewStyleGray;
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame{
    self = [super initWithFrame:frame];
    if (self) {
        self.loadingStyle = UIActivityIndicatorViewStyleGray;
    }
    return self;
}

-(void)loadFromUrl:(NSString *)url onErrorBlock:(void (^)(NSError *error))onErrorBlock{
    if (!url || [url length] == 0) {
        return;
    }
    if (self.isCanShowLoading) {
        if (!_indicatorView) {
            _indicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:self.loadingStyle];
            CGPoint center = self.center;
            center = [self convertPoint:center fromView:self.superview];
            _indicatorView.center = center;
        }
        [_indicatorView startAnimating];
        [self addSubview:_indicatorView];
    }
    if (_imageUrl && [_imageUrl isEqualToString:url] && _oimage) {
        [self showImage];
        return;
    }
    [self clear];
    _imageUrl = [url copy];
    //    _imageData = nil;
    _oimage = nil;
    __weak HKURLImageView* me = self;
    [[HKThreadUtil shareInstance] asyncBlock:^{
        HKCacheData* cd = [_cache objectForKey:_imageUrl];
        if (cd) {
            if ([_imageUrl isEqualToString:url]) {
                //                _imageData = cd.data;
                _oimage = cd.object;
                [me showImage];
            }
        }
        else{
            HKCallbackHandler * handler = [[HKCallbackHandler alloc] init];
            [handler setOnFinishBlock:^(NSString *url, NSData *data,NSInteger statusCode) {
                if (statusCode == 200) {
                    UIImage* image = [me buildImage:data];
                    [_cache setObject:image forKey:url];
                    if ([_imageUrl isEqualToString:url]) {
                        //                        _imageData = pd;
                        _oimage = image;
                        [me showImage];
                    }
                }
                else{
                    if (onErrorBlock) {
                        NSError* error = [[NSError alloc] initWithDomain:@"statusCode" code:statusCode userInfo:nil];
                        onErrorBlock(error);
                    }
                }
            }];
            [handler setOnErrorBlock:^(NSString *url, NSError *error,NSInteger statusCode) {
                if (onErrorBlock) {
                    onErrorBlock(error);
                }
            }];
            NSTimeInterval t = _globalTimeout;
            if (self.timeout > 0) {
                t = self.timeout;
            }
            static dispatch_once_t onceToken;
            dispatch_once(&onceToken, ^{
                _shareDownloaderMgr = [[HKDownloaderMgr alloc] init];
            });
            [_shareDownloaderMgr downloadWithUrl:_imageUrl callbackHandler:handler timeout:t];
        }
    }];
}

-(void)showImage{
    __weak HKURLImageView* me = self;
    [[HKThreadUtil shareInstance] asyncBlockToMainThread:^{
        if (_indicatorView.superview == self) {
            [_indicatorView removeFromSuperview];
        }
        //        me.image = [[UIImage alloc] initWithData:_imageData];
        me.image = _oimage;
    }];
}

-(UIImage*)scaleImageWithImage:(UIImage*)image width:(NSInteger)width height:(NSInteger)height
{
    CGSize size;
	size.width = width;
	size.height = height;
    UIGraphicsBeginImageContext(size);
    [image drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return scaledImage;
}

-(NSData*)toImageData:(NSData*)data{
    UIImage* image = [[UIImage alloc] initWithData:data];
    CGFloat maxWidth = self.frame.size.width;
    CGFloat maxHeight = self.frame.size.height;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    if (width > maxWidth){
        CGFloat h = (height * maxWidth)/width;
        image = [self scaleImageWithImage:image width:maxWidth height:h];
        return UIImageJPEGRepresentation(image, 1);
    }
    else if (height > maxHeight){
        CGFloat w = maxWidth * width / height;
        image = [self scaleImageWithImage:image width:w height:maxHeight];
        return UIImageJPEGRepresentation(image, 1);
    }
    return data;
}

-(UIImage*)buildImage:(NSData*)data{
    UIImage* image = [[UIImage alloc] initWithData:data];
    CGFloat maxWidth = self.frame.size.width;
    CGFloat maxHeight = self.frame.size.height;
    CGFloat width = image.size.width;
    CGFloat height = image.size.height;
    if (width > maxWidth){
        CGFloat h = (height * maxWidth)/width;
        image = [self scaleImageWithImage:image width:maxWidth height:h];
    }
    else if (height > maxHeight){
        CGFloat w = maxWidth * width / height;
        image = [self scaleImageWithImage:image width:w height:maxHeight];
    }
    return image;
}

-(void)clear{
    self.image = nil;
}

@end
