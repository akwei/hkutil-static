//
//  HKAttrLabel.m
//  hkutil-static
//
//  Created by akwei on 14-3-17.
//  Copyright (c) 2014年 huoku. All rights reserved.
//

#import "HKAttrLabel.h"
#import <CoreText/CoreText.h>

@interface HKAttrLabel ()
@end

@implementation HKAttrLabel{
    CTFramesetterRef _framesetter;
    CTFrameRef _frame;
}

-(void)updateToFit:(BOOL)fit{
    [self clear];
    _framesetter = CTFramesetterCreateWithAttributedString((CFAttributedStringRef)self.attrText);
    CGSize size = CTFramesetterSuggestFrameSizeWithConstraints(_framesetter, CFRangeMake(0,0), NULL, CGSizeMake(self.frame.size.width, MAXFLOAT), NULL);
    if (fit) {
        self.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, size.width, size.height);
    }
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathAddRect(path, NULL,self.bounds);
    _frame = CTFramesetterCreateFrame(_framesetter,CFRangeMake(0, 0),path, NULL);
    CGPathRelease(path);
    [self setNeedsDisplay];
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (self.attrText) {
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextTranslateCTM(context, 0, self.bounds.size.height);
        CGContextScaleCTM(context, 1.0, -1.0);
        CGContextSetTextMatrix(context, CGAffineTransformIdentity);
        CTFrameDraw(_frame, context);
        [self clear];
        UIGraphicsPushContext(context);
    }
    else{
        [super drawRect:rect];
    }
}


-(void)clear{
    if (_frame) {
        CFRelease(_frame);
        _frame = NULL;
    }
    if (_framesetter) {
        CFRelease(_framesetter);
        _framesetter = NULL;
    }
}

@end
