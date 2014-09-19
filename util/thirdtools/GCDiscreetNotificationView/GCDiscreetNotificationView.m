//
//  GCDiscreetNotificationView.m
//  Mtl mobile
//
//  Created by Guillaume Campagna on 09-12-27.
//  Copyright 2009 LittleKiwi. All rights reserved.
//

#import "GCDiscreetNotificationView.h"

const CGFloat GCDiscreetNotificationViewBorderSize = 25;
const CGFloat GCDiscreetNotificationViewPadding = 5;
const CGFloat GCDiscreetNotificationViewHeight = 30;

NSString* const GCShowAnimation = @"show";
NSString* const GCHideAnimation = @"hide";
NSString* const GCChangeProprety = @"changeProprety";

NSString* const GCDiscreetNotificationViewTextKey = @"text";
NSString* const GCDiscreetNotificationViewActivityKey = @"activity";

@interface GCDiscreetNotificationView ()

@property (nonatomic, readonly) CGPoint showingCenter;
@property (nonatomic, readonly) CGPoint hidingCenter;

@property (nonatomic, assign) BOOL animating;
@property (nonatomic, retain) NSDictionary* animationDict;

- (void) show:(BOOL)animated name:(NSString *)name;
- (void) hide:(BOOL)animated name:(NSString *)name;
- (void) showOrHide:(BOOL) hide animated:(BOOL) animated name:(NSString*) name;
- (void) animationDidStop:(NSString *)animationID finished:(BOOL) finished context:(void *) context;

- (void) placeOnGrid;
- (void) changePropretyAnimatedWithKeys:(NSArray*) keys values:(NSArray*) values;

@end

@implementation GCDiscreetNotificationView

@synthesize activityIndicator, presentationMode, label;
@synthesize animating, animationDict;

#pragma mark -
#pragma mark Init and dealloc

- (id)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        presentationMode = -1;
    }
    return self;
}

- (id) initWithText:(NSString *)text inView:(UIView *)aView {
    return [self initWithText:text showActivity:NO inView:aView];
}

- (id)initWithText:(NSString*) text showActivity:(BOOL) activity inView:(UIView*) aView {
    return [self initWithText:text showActivity:activity inPresentationMode:GCDiscreetNotificationViewPresentationModeTop inView:aView];
}

- (id) initWithText:(NSString *)text showActivity:(BOOL)activity 
 inPresentationMode:(GCDiscreetNotificationViewPresentationMode)aPresentationMode inView:(UIView *)aView {
    if ((self = [self initWithFrame:CGRectZero])) {
        self.view = aView;
        self.addX = 0;
        self.textLabel = text;
        self.showActivity = activity;
        self.presentationMode = aPresentationMode;
        
        self.center = self.hidingCenter;
        [self setNeedsLayout];

        self.opaque = NO;
        self.backgroundColor = [UIColor clearColor];
        
        self.animating = NO;
        
        self.cBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        self.cBtn.backgroundColor = [UIColor clearColor];
        self.cBtn.autoresizingMask = UIViewAutoresizingFlexibleHeight
                                    |UIViewAutoresizingFlexibleWidth
                                    |UIViewAutoresizingFlexibleBottomMargin
                                    |UIViewAutoresizingFlexibleLeftMargin
                                    |UIViewAutoresizingFlexibleRightMargin
                                    |UIViewAutoresizingFlexibleTopMargin;
        [self.cBtn addTarget:self action:@selector(onTapCBtn:) forControlEvents:UIControlEventTouchUpInside];
        self.cBtn.frame = CGRectZero;
        self.cBtn.backgroundColor = [UIColor clearColor];
        [self addSubview:self.cBtn];
    }
    return self;
}

-(void)onTapCBtn:(id)sender{
    if (self.onClickBtnBlock) {
        self.onClickBtnBlock();
    }
}

#pragma mark -
#pragma mark Drawing and layout

- (void) layoutSubviews {
    BOOL withActivity = self.activityIndicator != nil;
    CGFloat baseWidth = (2 * GCDiscreetNotificationViewBorderSize) + (withActivity * GCDiscreetNotificationViewPadding);
    
    CGFloat maxLabelWidth = self.view.frame.size.width - self.activityIndicator.frame.size.width * withActivity - baseWidth;
    CGSize maxLabelSize = CGSizeMake(maxLabelWidth, GCDiscreetNotificationViewHeight);
    CGFloat textSizeWidth = (self.textLabel != nil) ? [self.textLabel boundingRectWithSize:maxLabelSize options:NSStringDrawingTruncatesLastVisibleLine|NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.label.font} context:nil].size.width : 0;
    
    CGFloat activityIndicatorWidth = (self.activityIndicator != nil) ? self.activityIndicator.frame.size.width : 0;
    CGRect bounds = CGRectMake(0, 0, baseWidth + textSizeWidth + activityIndicatorWidth, GCDiscreetNotificationViewHeight);
    if (!CGRectEqualToRect(self.bounds, bounds)) { //The bounds have changed...
        self.bounds = bounds;
        self.cBtn.frame = self.bounds;
        [self setNeedsDisplay];
    }
    
    if (self.activityIndicator == nil) self.label.frame = CGRectMake(GCDiscreetNotificationViewBorderSize, 0, textSizeWidth, GCDiscreetNotificationViewHeight);
    else {
        self.activityIndicator.frame = CGRectMake(GCDiscreetNotificationViewBorderSize, GCDiscreetNotificationViewPadding, self.activityIndicator.frame.size.width, self.activityIndicator.frame.size.height);
        self.label.frame = CGRectMake(GCDiscreetNotificationViewBorderSize + GCDiscreetNotificationViewPadding + self.activityIndicator.frame.size.width, 0, textSizeWidth, GCDiscreetNotificationViewHeight);
    }
    
    [self placeOnGrid];
}


- (void) drawRect:(CGRect)rect {
    CGRect myFrame = self.bounds;

    CGFloat maxY = 0;
    CGFloat minY = 0;
    
    if (self.presentationMode == GCDiscreetNotificationViewPresentationModeTop) {
        maxY =  CGRectGetMinY(myFrame) - 1;
        minY = CGRectGetMaxY(myFrame);
    }
    else if (self.presentationMode == GCDiscreetNotificationViewPresentationModeBottom) {
        maxY =  CGRectGetMaxY(myFrame) + 1;
        minY = CGRectGetMinY(myFrame);
    }
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    CGMutablePathRef path = CGPathCreateMutable();
    
    CGFloat minX = CGRectGetMinX(myFrame);
    CGFloat maxX = CGRectGetMaxX(myFrame);
    
    CGPathMoveToPoint(path, NULL, CGRectGetMinX(myFrame), maxY);
    CGPathAddCurveToPoint(path, NULL, minX + GCDiscreetNotificationViewBorderSize, maxY, minX, minY, minX + GCDiscreetNotificationViewBorderSize, minY);
    CGPathAddLineToPoint(path, NULL, maxX - GCDiscreetNotificationViewBorderSize, minY);
    CGPathAddCurveToPoint(path, NULL, maxX, minY, maxX - GCDiscreetNotificationViewBorderSize, maxY, maxX, maxY);
    CGPathCloseSubpath(path);
    
    CGContextSetFillColorWithColor(context, [UIColor orangeColor].CGColor);
    CGContextSetStrokeColorWithColor(context, [UIColor orangeColor].CGColor);
    
    CGContextAddPath(context, path);
    CGContextStrokePath(context);
    
    CGContextAddPath(context, path);
    CGContextFillPath(context);
    
    CGPathRelease(path);
}

#pragma mark -
#pragma mark Show/Hide 

- (void)showAnimated {
    [self show:YES];
}

- (void)hideAnimated {
    [self hide:YES];
}

- (void) hideAnimatedAfter:(NSTimeInterval) timeInterval {
   [self performSelector:@selector(hideAnimated) withObject:nil afterDelay:timeInterval]; 
}

- (void)showAndDismissAutomaticallyAnimated {
    [self showAndDismissAfter:1.0];
}

- (void)showAndDismissAfter:(NSTimeInterval)timeInterval {
    [self showAnimated];
    [self hideAnimatedAfter:timeInterval];
}

- (void) show:(BOOL)animated {
    [self show:animated name:GCShowAnimation];
}

- (void) hide:(BOOL)animated {
    [self hide:animated name:GCHideAnimation];
}

- (void) show:(BOOL)animated name:(NSString*) name {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAnimated) object:nil];

    [self showOrHide:NO animated:animated name:name];
}

- (void) hide:(BOOL)animated name:(NSString*) name {
    [self showOrHide:YES animated:animated name:name];
}

- (void) showOrHide:(BOOL)hide animated:(BOOL)animated name:(NSString *)name {
    if ((hide && self.isShowing) || (!hide && !self.isShowing)) {
        if (animated) {
            self.animating = YES;
            [UIView beginAnimations:name context:nil];
            [UIView setAnimationDelegate:self];
            [UIView setAnimationBeginsFromCurrentState:YES];
            [UIView setAnimationDidStopSelector:@selector(animationDidStop:finished:context:)];
        }
        
        if (hide) self.center = self.hidingCenter;
        else {
            [self.superview bringSubviewToFront:self];
            [self.activityIndicator startAnimating];
            self.center = self.showingCenter;
            self.label.hidden = NO;
        }
        
        [self placeOnGrid];
        
        if (animated) [UIView commitAnimations]; 
    }
}

#pragma mark -
#pragma mark Animations

- (void) animationDidStop:(NSString *)animationID finished:(BOOL) finished context:(void *) context {
    BOOL show = YES;
    if (animationID == GCHideAnimation) {
        show = NO;
        [self.activityIndicator stopAnimating];
        self.label.hidden = YES;
    }
    else if (animationID == GCChangeProprety) {
        NSString* showName = GCShowAnimation;
        
        for (NSString* key in [self.animationDict allKeys]) {
            if (key == GCDiscreetNotificationViewActivityKey) {
                self.showActivity = [[self.animationDict objectForKey:key] boolValue];
            }
            else if (key == GCDiscreetNotificationViewTextKey) {
                self.textLabel = [self.animationDict objectForKey:key];
            }
        }
        
        self.animationDict = nil;
        
        [self show:YES name:showName];
    }    
    else if (animationID == GCShowAnimation) {
        if (self.animationDict != nil) [self hide:YES name:GCChangeProprety];
    }
//    [self.view bringSubviewToFront:self];
    self.animating = NO;
    if (show) {
        if (self.onCompleteShowAnimationBlock) {
            self.onCompleteShowAnimationBlock();
        }
    }
    else{
        if (self.onCompleteHideAnimationBlock) {
            self.onCompleteHideAnimationBlock();
        }
    }
}


#pragma mark -
#pragma mark Getter and setters

- (NSString *) textLabel {
    return self.label.text;
}

- (void) setTextLabel:(NSString *) aText {
    self.label.text = aText;
    [self setNeedsLayout];
}

- (UILabel *)label {
    if (label == nil) {
        label = [[UILabel alloc] init];
        label.font = [UIFont boldSystemFontOfSize:17];
        label.textColor = [UIColor whiteColor];
        label.shadowColor = [UIColor orangeColor];
        label.shadowOffset = CGSizeMake(0, 1);
        label.baselineAdjustment = UIBaselineAdjustmentAlignCenters;
        label.backgroundColor = [UIColor orangeColor];
        
        [self addSubview:label];
    }
    return label;
}

- (BOOL) showActivity {
    return (self.activityIndicator != nil);
}

- (void) setShowActivity:(BOOL) activity {
    if (activity != self.showActivity) {
        if (activity) {
            activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            [self addSubview:activityIndicator];
        }
        else {
            [activityIndicator removeFromSuperview];
            activityIndicator = nil;
        }
        
        [self setNeedsLayout];
    }
}

- (void) setView:(UIView *) aView {
    if (self.view != aView) {
        [self removeFromSuperview];
        
        [aView addSubview:self];
        [self setNeedsLayout];
    }
}

- (UIView *)view {
    return self.superview;
}

- (void) setPresentationMode:(GCDiscreetNotificationViewPresentationMode) newPresentationMode {
    if (presentationMode != newPresentationMode) {        
        BOOL showing = self.isShowing;
        
        presentationMode = newPresentationMode;
        if (presentationMode == GCDiscreetNotificationViewPresentationModeTop) {
            self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleBottomMargin;
        }
        else if (presentationMode == GCDiscreetNotificationViewPresentationModeBottom) {
            self.autoresizingMask = UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleTopMargin;
        }
        
        self.center = showing ? self.showingCenter : self.hidingCenter;
        
        [self setNeedsDisplay];
        [self placeOnGrid];
    }
}

- (BOOL) isShowing {
    return (self.center.y == self.showingCenter.y);
}

- (CGPoint) showingCenter {
    CGFloat y = 0;
    if (self.presentationMode == GCDiscreetNotificationViewPresentationModeTop) y = 15;
    else if (self.presentationMode == GCDiscreetNotificationViewPresentationModeBottom) y = self.view.bounds.size.height - 15;
    return CGPointMake(self.view.bounds.size.width / 2 + self.addX, y);
}

- (CGPoint) hidingCenter {
    CGFloat y = 0;
    if (self.presentationMode == GCDiscreetNotificationViewPresentationModeTop) y = - 15;
    else if (self.presentationMode == GCDiscreetNotificationViewPresentationModeBottom) y = 15 + self.view.bounds.size.height;
    return CGPointMake(self.view.bounds.size.width / 2 + self.addX, y);
}

#pragma mark -
#pragma mark Animated Setters

- (void) setTextLabel:(NSString *)aText animated:(BOOL)animated {
    if (animated && (self.showing || self.animating)) {
        [self changePropretyAnimatedWithKeys:[NSArray arrayWithObject:GCDiscreetNotificationViewTextKey]
                                      values:[NSArray arrayWithObject:aText]];
    }
    else self.textLabel = aText;
}

- (void) setShowActivity:(BOOL)activity animated:(BOOL)animated {
    if (animated && (self.showing || self.animating)) {
        [self changePropretyAnimatedWithKeys:[NSArray arrayWithObject:GCDiscreetNotificationViewActivityKey]
                                      values:[NSArray arrayWithObject:[NSNumber numberWithBool:activity]]];
    }
    else self.showActivity = activity;
}

- (void) setTextLabel:(NSString *)aText andSetShowActivity:(BOOL)activity animated:(BOOL)animated {
    if (animated && (self.showing || self.animating)) {
        [self changePropretyAnimatedWithKeys:[NSArray arrayWithObjects:GCDiscreetNotificationViewTextKey, GCDiscreetNotificationViewActivityKey, nil]
                                      values:[NSArray arrayWithObjects:aText, [NSNumber numberWithBool:activity], nil]];
    }
    else {
        self.textLabel = aText;
        self.showActivity = activity;
    }
}

#pragma mark -
#pragma mark Helper Methods

- (void) placeOnGrid {
    CGRect frame = self.frame;
    
    frame.origin.x = roundf(frame.origin.x);
    frame.origin.y = roundf(frame.origin.y);
    
    self.frame = frame;
}

- (void) changePropretyAnimatedWithKeys:(NSArray*) keys values:(NSArray*) values {
    NSDictionary* newDict = [NSDictionary dictionaryWithObjects:values forKeys:keys];
    
    if (self.animationDict == nil) {
        self.animationDict = newDict;
    }
    else {
        NSMutableDictionary* mutableAnimationDict = [self.animationDict mutableCopy];
        [mutableAnimationDict addEntriesFromDictionary:newDict];
        self.animationDict = mutableAnimationDict;
    }
    
    if (!self.animating) [self hide:YES name:GCChangeProprety];
}

#pragma mark - UIView subclass

- (void)willMoveToSuperview:(UIView *)newSuperview {
    if (newSuperview == nil) {
        self.animationDict = nil;
        [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(hideAnimated) object:nil];
    }
}

@end