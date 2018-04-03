//
//  BBPopupViewController.h
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

#import <UIKit/UIKit.h>

@class BBPopupBackgroundView;

typedef NS_ENUM(NSInteger, BBPopupViewAnimation) {
    BBPopupViewAnimationFade = 0,
    BBPopupViewAnimationSlideBottomTop = 1,
    BBPopupViewAnimationSlideBottomBottom,
    BBPopupViewAnimationSlideTopTop,
    BBPopupViewAnimationSlideTopBottom,
    BBPopupViewAnimationSlideLeftLeft,
    BBPopupViewAnimationSlideLeftRight,
    BBPopupViewAnimationSlideRightLeft,
    BBPopupViewAnimationSlideRightRight,
};

@interface BBPopupViewController: NSObject

@property (nonatomic, retain) UIViewController *BB_popupViewController;
@property (nonatomic, retain) BBPopupBackgroundView *BB_popupBackgroundView;

+ (instancetype) sharedInstance:(UIViewController *) viewController;

- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(BBPopupViewAnimation)animationType;
- (void)presentPopupViewController:(UIViewController*)popupViewController animationType:(BBPopupViewAnimation)animationType backgroundTouch:(BOOL)enable dismissed:(void(^)(void))dismissed;

- (void)dismissPopupViewControllerWithanimationType:(BBPopupViewAnimation)animationType;

@end



@interface BBPopupBackgroundView : UIView

@end
