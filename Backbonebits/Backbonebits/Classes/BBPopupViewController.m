//
//  BBPopupViewController.m
//  Backbonebits
//
//  Created by Backbonebits
//

/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBPopupViewController.h"
#import <QuartzCore/QuartzCore.h>
#import <objc/runtime.h>

#define kBBPopupModalAnimationDuration 0.35
#define kBBPopupViewController @"kBBPopupViewController"
#define kBBPopupBackgroundView @"kBBPopupBackgroundView"
#define kBBSourceViewTag 23941
#define kBBPopupViewTag 23942
#define kBBOverlayViewTag 23945

@interface BBPopupViewController ()

@property (nonatomic, strong) UIViewController * presentFrom;

@end

static NSString *BBPopupViewDismissedKey = @"BBPopupViewDismissed";

#pragma mark -
#pragma mark Public

@implementation BBPopupViewController

BBPopupViewController * bbPopupViewObject = nil;
+ (instancetype) sharedInstance:(UIViewController *) viewController
{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        bbPopupViewObject = [[BBPopupViewController alloc] init];
    });
    bbPopupViewObject.presentFrom = viewController;
    return bbPopupViewObject;
}

static void * const keypath = (void*)&keypath;

- (UIViewController*)BB_popupViewController {
    return objc_getAssociatedObject(self, kBBPopupViewController);
}

- (void)setBB_popupViewController:(UIViewController *)BB_popupViewController {
    objc_setAssociatedObject(self, kBBPopupViewController, BB_popupViewController, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (BBPopupBackgroundView*)BB_popupBackgroundView {
    return objc_getAssociatedObject(self, kBBPopupBackgroundView);
}

- (void)setBB_popupBackgroundView:(BBPopupBackgroundView *)BB_popupBackgroundView {
    objc_setAssociatedObject(self, kBBPopupBackgroundView, BB_popupBackgroundView, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(BBPopupViewAnimation)animationType backgroundTouch:(BOOL)enable dismissed:(void(^)(void))dismissed
{
    self.BB_popupViewController = popupViewController;
    [self presentPopupView:popupViewController.view animationType:animationType backgroundTouch:enable dismissed:dismissed];
}

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(BBPopupViewAnimation)animationType
{
    [self presentPopupViewController:popupViewController animationType:animationType backgroundTouch:YES dismissed:nil];
}

- (void)dismissPopupViewControllerWithanimationType:(BBPopupViewAnimation)animationType
{
    if (self.presentFrom) {
        UIView *sourceView = self.presentFrom.view;
        UIView *popupView = [sourceView viewWithTag:kBBPopupViewTag];
        UIView *overlayView = [sourceView viewWithTag:kBBOverlayViewTag];
        
        switch (animationType) {
            case BBPopupViewAnimationSlideBottomTop:
            case BBPopupViewAnimationSlideBottomBottom:
            case BBPopupViewAnimationSlideTopTop:
            case BBPopupViewAnimationSlideTopBottom:
            case BBPopupViewAnimationSlideLeftLeft:
            case BBPopupViewAnimationSlideLeftRight:
            case BBPopupViewAnimationSlideRightLeft:
            case BBPopupViewAnimationSlideRightRight:
                [self slideViewOut:popupView sourceView:sourceView overlayView:overlayView withAnimationType:animationType];
                break;
                
            default:
                [self fadeViewOut:popupView sourceView:sourceView overlayView:overlayView];
                break;
        }
    }
}

#pragma mark -
#pragma mark View Handling

- (void)presentPopupView:(UIView*)popupView animationType:(BBPopupViewAnimation)animationType
{
    [self presentPopupView:popupView animationType:animationType backgroundTouch:YES dismissed:nil];
}

- (void)presentPopupView:(UIView*)popupView animationType:(BBPopupViewAnimation)animationType backgroundTouch:(BOOL)enable dismissed:(void(^)(void))dismissed
{
    if (self.presentFrom) {
        UIView *sourceView = self.presentFrom.view;
        sourceView.tag = kBBSourceViewTag;
        popupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin |UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleRightMargin;
        popupView.tag = kBBPopupViewTag;
        
        // check if source view controller is not in destination
        if ([sourceView.subviews containsObject:popupView]) return;
        
        // customize popupView
        popupView.layer.masksToBounds = NO;
        popupView.layer.shouldRasterize = YES;
        popupView.layer.rasterizationScale = [[UIScreen mainScreen] scale];
        
        // Add semi overlay
        UIView *overlayView = [[UIView alloc] initWithFrame:sourceView.bounds];
        overlayView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        overlayView.tag = kBBOverlayViewTag;
        overlayView.backgroundColor = [UIColor clearColor];
        
        // BackgroundView
        self.BB_popupBackgroundView = [[BBPopupBackgroundView alloc] initWithFrame:sourceView.bounds];
        self.BB_popupBackgroundView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        self.BB_popupBackgroundView.backgroundColor = [UIColor clearColor];
        self.BB_popupBackgroundView.alpha = 0.0f;
        [overlayView addSubview:self.BB_popupBackgroundView];
        
        // Make the Background Clickable
        UIButton * dismissButton = [UIButton buttonWithType:UIButtonTypeCustom];
        dismissButton.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        dismissButton.backgroundColor = [UIColor clearColor];
        dismissButton.frame = sourceView.bounds;
        [overlayView addSubview:dismissButton];
        
        popupView.alpha = 0.0f;
        [overlayView addSubview:popupView];
        [sourceView addSubview:overlayView];
        
        
        [dismissButton addTarget:self action:@selector(dismissPopupViewControllerWithanimation:) forControlEvents:UIControlEventTouchUpInside];
        switch (animationType) {
            case BBPopupViewAnimationSlideBottomTop:
            case BBPopupViewAnimationSlideBottomBottom:
            case BBPopupViewAnimationSlideTopTop:
            case BBPopupViewAnimationSlideTopBottom:
            case BBPopupViewAnimationSlideLeftLeft:
            case BBPopupViewAnimationSlideLeftRight:
            case BBPopupViewAnimationSlideRightLeft:
            case BBPopupViewAnimationSlideRightRight:
                dismissButton.tag = animationType;
                [self slideViewIn:popupView sourceView:sourceView overlayView:overlayView withAnimationType:animationType];
                break;
            default:
                dismissButton.tag = BBPopupViewAnimationFade;
                [self fadeViewIn:popupView sourceView:sourceView overlayView:overlayView];
                break;
        }
        dismissButton.enabled = enable;
        [self setDismissedCallback:dismissed];
    }
}

- (void)dismissPopupViewControllerWithanimation:(id)sender
{
    if ([sender isKindOfClass:[UIButton class]]) {
        UIButton* dismissButton = sender;
        switch (dismissButton.tag) {
            case BBPopupViewAnimationSlideBottomTop:
            case BBPopupViewAnimationSlideBottomBottom:
            case BBPopupViewAnimationSlideTopTop:
            case BBPopupViewAnimationSlideTopBottom:
            case BBPopupViewAnimationSlideLeftLeft:
            case BBPopupViewAnimationSlideLeftRight:
            case BBPopupViewAnimationSlideRightLeft:
            case BBPopupViewAnimationSlideRightRight:
                [self dismissPopupViewControllerWithanimationType:dismissButton.tag];
                break;
            default:
                [self dismissPopupViewControllerWithanimationType:BBPopupViewAnimationFade];
                break;
        }
    } else {
        [self dismissPopupViewControllerWithanimationType:BBPopupViewAnimationFade];
    }
}

#pragma mark -
#pragma mark Animations

#pragma mark --- Slide

- (void)slideViewIn:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView withAnimationType:(BBPopupViewAnimation)animationType
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupStartRect;
    switch (animationType) {
        case BBPopupViewAnimationSlideBottomTop:
        case BBPopupViewAnimationSlideBottomBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                        sourceSize.height,
                                        popupSize.width,
                                        popupSize.height);
            
            break;
        case BBPopupViewAnimationSlideLeftLeft:
        case BBPopupViewAnimationSlideLeftRight:
            popupStartRect = CGRectMake(-sourceSize.width,
                                        (sourceSize.height - popupSize.height) / 2,
                                        popupSize.width,
                                        popupSize.height);
            break;
            
        case BBPopupViewAnimationSlideTopTop:
        case BBPopupViewAnimationSlideTopBottom:
            popupStartRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                        -popupSize.height,
                                        popupSize.width,
                                        popupSize.height);
            break;
            
        default:
            popupStartRect = CGRectMake(sourceSize.width,
                                        (sourceSize.height - popupSize.height) / 2,
                                        popupSize.width,
                                        popupSize.height);
            break;
    }
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width,
                                     popupSize.height);
    
    // Set starting properties
    popupView.frame = popupStartRect;
    popupView.alpha = 1.0f;
    [UIView animateWithDuration:kBBPopupModalAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseOut animations:^{
        [self.BB_popupViewController viewWillAppear:NO];
        self.BB_popupBackgroundView.alpha = 1.0f;
        popupView.frame = popupEndRect;
    } completion:^(BOOL finished) {
        [self.BB_popupViewController viewDidAppear:NO];
    }];
}

- (void)slideViewOut:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView withAnimationType:(BBPopupViewAnimation)animationType
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect;
    switch (animationType) {
        case BBPopupViewAnimationSlideBottomTop:
        case BBPopupViewAnimationSlideTopTop:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                      -popupSize.height,
                                      popupSize.width,
                                      popupSize.height);
            break;
        case BBPopupViewAnimationSlideBottomBottom:
        case BBPopupViewAnimationSlideTopBottom:
            popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                      sourceSize.height,
                                      popupSize.width,
                                      popupSize.height);
            break;
        case BBPopupViewAnimationSlideLeftRight:
        case BBPopupViewAnimationSlideRightRight:
            popupEndRect = CGRectMake(sourceSize.width,
                                      popupView.frame.origin.y,
                                      popupSize.width,
                                      popupSize.height);
            break;
        default:
            popupEndRect = CGRectMake(-popupSize.width,
                                      popupView.frame.origin.y,
                                      popupSize.width,
                                      popupSize.height);
            break;
    }
    
    [UIView animateWithDuration:kBBPopupModalAnimationDuration delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{
        [self.BB_popupViewController viewWillDisappear:NO];
        popupView.frame = popupEndRect;
        self.BB_popupBackgroundView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self.BB_popupViewController viewDidDisappear:NO];
        self.BB_popupViewController = nil;
        
        id dismissed = [self dismissedCallback];
        if (dismissed != nil)
        {
            ((void(^)(void))dismissed)();
            [self setDismissedCallback:nil];
        }
    }];
}

#pragma mark --- Fade

- (void)fadeViewIn:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView
{
    // Generating Start and Stop Positions
    CGSize sourceSize = sourceView.bounds.size;
    CGSize popupSize = popupView.bounds.size;
    CGRect popupEndRect = CGRectMake((sourceSize.width - popupSize.width) / 2,
                                     (sourceSize.height - popupSize.height) / 2,
                                     popupSize.width,
                                     popupSize.height);
    
    // Set starting properties
    popupView.frame = popupEndRect;
    popupView.alpha = 0.0f;
    
    [UIView animateWithDuration:kBBPopupModalAnimationDuration animations:^{
        [self.BB_popupViewController viewWillAppear:NO];
        self.BB_popupBackgroundView.alpha = 0.5f;
        popupView.alpha = 1.0f;
    } completion:^(BOOL finished) {
        [self.BB_popupViewController viewDidAppear:NO];
    }];
}

- (void)fadeViewOut:(UIView*)popupView sourceView:(UIView*)sourceView overlayView:(UIView*)overlayView
{
    [UIView animateWithDuration:kBBPopupModalAnimationDuration animations:^{
        [self.BB_popupViewController viewWillDisappear:NO];
        self.BB_popupBackgroundView.alpha = 0.0f;
        popupView.alpha = 0.0f;
    } completion:^(BOOL finished) {
        [popupView removeFromSuperview];
        [overlayView removeFromSuperview];
        [self.BB_popupViewController viewDidDisappear:NO];
        self.BB_popupViewController = nil;
        
        id dismissed = [self dismissedCallback];
        if (dismissed != nil)
        {
            ((void(^)(void))dismissed)();
            [self setDismissedCallback:nil];
        }
    }];
}

#pragma mark -
#pragma mark Category Accessors

#pragma mark --- Dismissed

- (void)setDismissedCallback:(void(^)(void))dismissed
{
    objc_setAssociatedObject(self, &BBPopupViewDismissedKey, dismissed, OBJC_ASSOCIATION_RETAIN);
    objc_setAssociatedObject(self.BB_popupViewController, &BBPopupViewDismissedKey, dismissed, OBJC_ASSOCIATION_RETAIN);
    
}

- (void(^)(void))dismissedCallback
{
    return objc_getAssociatedObject(self, &BBPopupViewDismissedKey);
}

@end



@implementation BBPopupBackgroundView

- (void)drawRect:(CGRect)rect
{

}

@end
