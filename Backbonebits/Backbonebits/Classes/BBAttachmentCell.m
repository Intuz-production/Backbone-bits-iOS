//
//  BBAttachmentCell.m
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

#import "BBAttachmentCell.h"

@implementation BBAttachmentCell

- (instancetype)initWithFrame:(CGRect)frame {
    if(self = [super initWithFrame:frame]) {
        [self setClipsToBounds:NO];
        [self addSubview:({
            _imgViewAttachment = [[UIImageView alloc] initWithFrame:self.bounds];
            [_imgViewAttachment setAutoresizingMask:UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight];
            [_imgViewAttachment setContentMode:UIViewContentModeScaleAspectFill];
            [_imgViewAttachment setClipsToBounds:YES];
            _imgViewAttachment;
        })];
        
        [self addSubview:({
            _btnDelete = [UIButton buttonWithType:UIButtonTypeCustom];
            CGFloat size = 22;
            [_btnDelete setFrame:CGRectMake(_imgViewAttachment.frame.size.width + _imgViewAttachment.frame.origin.x - 17, _imgViewAttachment.frame.origin.y - 5, size, size)];
            [_btnDelete setAutoresizingMask:UIViewAutoresizingFlexibleLeftMargin];
            [_btnDelete setImage:[UIImage imageNamed:@"bb_close"] forState:UIControlStateNormal];
            _btnDelete;
        })];
        
        [self addSubview:({
            _loadingView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
            _loadingView.center = CGPointMake(frame.size.width/2, frame.size.height/2);
            _loadingView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
            [_loadingView setHidesWhenStopped:YES];
            [_loadingView stopAnimating];
            _loadingView;
        })];
    }
    return self;
}

@end
