/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>
#import "BBPlaceHolderTextView.h"

#define kAutoResizingMaskAll UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth

@class BBMessageInputView;

@protocol BBMessageInputViewDelegate <NSObject>

/**
 * Called when user tap on send button
 */
- (void)messageInputView:(BBMessageInputView *)inputView didSendMessage:(NSString *)message;

/**
 * Called when user tap on attach media button
 */
- (void)messageInputViewDidSelectMediaButton:(BBMessageInputView *)inputView;

@end

@interface BBMessageInputView : UIView

@property (weak, nonatomic) UITableView *tableView;

#pragma mark - Properties
@property (strong, nonatomic) UIImageView *textBgImageView;
@property (strong, nonatomic) BBPlaceHolderTextView *textView;
@property (strong, nonatomic) UIButton *sendButton;
@property (strong, nonatomic) UIButton *mediaButton;

@property (strong, nonatomic) UIView *separatorView;

@property (nonatomic, readonly) BOOL viewIsDragging;

/**
 * After setting above properties make sure that you called
 * -adjustInputView method for apply changes
 */
@property (nonatomic) CGFloat textInitialHeight;
@property (nonatomic) CGFloat textMaxHeight;
@property (nonatomic) CGFloat textTopMargin;
@property (nonatomic) CGFloat textBottomMargin;
@property (nonatomic) CGFloat textleftMargin;
@property (nonatomic) CGFloat textRightMargin;
//--

@property (weak, nonatomic) id<BBMessageInputViewDelegate> delegate;

#pragma mark - Methods
- (void)adjustInputView;
- (void)adjustPosition;

@end
