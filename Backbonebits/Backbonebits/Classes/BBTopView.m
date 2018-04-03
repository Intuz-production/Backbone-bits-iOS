//
//  BBTopView.m
//  Backbonebits
//
//  Created by Backbonebits
//
//

/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBTopView.h"
#import "BBContants.h"

@implementation BBTopView

+ (BBTopView *) getBBTopView {
    BBTopView * topView = [kBBStoryboard instantiateViewControllerWithIdentifier:@"BBTopView"];
    BOOL isStatusBarHidden = [[UIApplication sharedApplication] isStatusBarHidden];
    topView.view.frame = CGRectMake(0, 0, kBBScreenWidth, isStatusBarHidden? 64: 64);
    return topView;
}

- (void) viewDidLoad {
    [super viewDidLoad];
    
    [self loadLayout];
}

- (void)loadLayout {
    [self.view setAutoresizingMask:UIViewAutoresizingFlexibleWidth];
    [self.view setBackgroundColor:kBBRGBCOLOR(25, 25, 25)];
    
    _btnLeft.backgroundColor = [UIColor clearColor];
    [_btnLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnLeft setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnLeft.layer setCornerRadius:3];
    [_btnLeft setHidden:YES];
    
    [_lblTitle setTextAlignment:NSTextAlignmentCenter];
    [_lblTitle setTextColor:[UIColor whiteColor]];
    [_lblTitle setBackgroundColor:[UIColor clearColor]];
    
    _btnRight.backgroundColor = [UIColor clearColor];
    [_btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [_btnRight setTitleColor:[UIColor whiteColor] forState:UIControlStateHighlighted];
    [_btnRight.layer setCornerRadius:3];
    [_btnRight setHidden:YES];
}

@end

@implementation UIButton (BBTopBarButton)

- (void) setTitle:(NSString *)title theme:(BBTopBarButtonTheme)theme target:(id)tagret selector:(SEL)selector forControlEvents:(UIControlEvents)event {
    switch (theme) {
        case BBTopBarButtonThemeNormal:
            [self setNormalButtonThemeTitle:title];
            break;
        case BBTopBarButtonThemeActive:
            [self setActiveButtonThemeTitle:title];
            break;
        case BBTopBarButtonThemeBack:
            [self setBackButtonThemeTitle:title];
            break;
        default:
            break;
    }
    [self removeTarget:tagret action:NULL forControlEvents:event];
    [self addTarget:tagret action:selector forControlEvents:event];
    
    [self setHidden:NO];
}

- (void) setActiveButtonThemeTitle:(NSString *)title {
    [self setBackgroundColor:kBBRGBCOLOR(151, 186, 84)];
    [self setImage:nil forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateNormal];
    [self setButtonActiveFrame:YES];
}

- (void) setBackButtonThemeTitle:(NSString *)title {
    [self setBackgroundColor:[UIColor clearColor]];
    [self setImage:[UIImage imageNamed:@"bb_Back_arrow_icon"] forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateNormal];
    [self setButtonActiveFrame:NO];
}

- (void) setNormalButtonThemeTitle:(NSString *)title {
    [self setBackgroundColor:[UIColor clearColor]];
    [self setImage:nil forState:UIControlStateNormal];
    [self setTitle:title forState:UIControlStateNormal];
    [self setButtonActiveFrame:NO];
}

- (void) setButtonActiveFrame:(BOOL)isYes {
    CGRect rect = self.frame;
    rect.origin.y = isYes?25:20;
    rect.size.height = isYes?34:44;
    rect.size.width = isYes?60:rect.size.width;
    [self setFrame:rect];
}

@end
