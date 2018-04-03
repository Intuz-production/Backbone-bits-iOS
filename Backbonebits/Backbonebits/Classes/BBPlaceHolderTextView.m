/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBPlaceHolderTextView.h"

@implementation BBPlaceHolderTextView

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (instancetype)initWithFrame:(CGRect)frame {
    if (self = [super initWithFrame:frame]) {
        [self setupTextView];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    if (self = [super initWithCoder:aDecoder]) {
        [self setupTextView];
    }
    return self;
}

- (void) setupTextView {
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textViewTextDidChangeNotification:) name:UITextViewTextDidChangeNotification object:nil];
    [self.textContainer setLineFragmentPadding:0];
    _placeHolderLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.textContainerInset.left, self.textContainerInset.top, 0, 0)];
    [_placeHolderLabel setFont:self.font];
    [self addSubview:_placeHolderLabel];
}

- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = placeholder;
    [_placeHolderLabel setText:placeholder];
    [_placeHolderLabel sizeToFit];
}

- (void)setFont:(UIFont *)font {
    [super setFont:font];
    [_placeHolderLabel setFont:font];
    [_placeHolderLabel sizeToFit];
}

- (void)setTextColor:(UIColor *)textColor {
    [super setTextColor:textColor];
    [_placeHolderLabel setTextColor:[textColor colorWithAlphaComponent:0.4]];
}

- (void)setTextContainerInset:(UIEdgeInsets)textContainerInset {
    [super setTextContainerInset:textContainerInset];
    CGRect placeHolderLabelFrame = [_placeHolderLabel frame];
    placeHolderLabelFrame.origin.x = textContainerInset.left;
    placeHolderLabelFrame.origin.y = textContainerInset.top;
    [_placeHolderLabel setFrame:placeHolderLabelFrame];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextViewTextDidChangeNotification object:nil];
}

- (void)textViewTextDidChangeNotification:(NSNotification *)notification {
    [_placeHolderLabel setHidden:[self.text length] > 0 ? YES : NO];
}

@end
