/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBLoadingView.h"

@implementation BBLoadingView


+ (BBLoadingView *)sharedInstance {
    static BBLoadingView *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[BBLoadingView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    });
    return sharedInstance;
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self setAutoresizesSubviews:YES];
        [self setBackgroundColor:[[UIColor blackColor] colorWithAlphaComponent:0.5f]];
        UIActivityIndicatorView *activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
        [activityIndicator setCenter:CGPointMake(frame.size.width/2, frame.size.height/2)];
        [activityIndicator setAutoresizingMask:UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin];
        [self addSubview:activityIndicator];
        [activityIndicator startAnimating];
    }
    return self;
}

+ (void)show {
    BBLoadingView *loadingView = [self sharedInstance];
    if([loadingView superview]) {
        [loadingView removeFromSuperview];
    }

    [[self sharedInstance] setFrame:[[UIScreen mainScreen] bounds]];
    [[self sharedInstance] setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
    
    UIWindow *window = [kBBUtility getWindowObject];
    [loadingView setCenter:window.center];
    [window addSubview:loadingView];
    [loadingView setAlpha:0.0];
    [UIView animateWithDuration:0.3 animations:^{
        [loadingView setAlpha:1.0];
    }];
}

+ (void)dismiss {
    BBLoadingView *loadingView = [self sharedInstance];
    [loadingView setAlpha:1.0];
    [UIView animateWithDuration:0.3 animations:^{
        [loadingView setAlpha:0.0];
    } completion:^(BOOL finished) {
        [loadingView removeFromSuperview];
    }];;
}

@end
