
/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import <UIKit/UIKit.h>

@interface BBDrawableView : UIView
{
    
}
@property (nonatomic, retain) NSMutableArray *arrPaths;
@property (nonatomic, copy) void (^drawingStarted)(void);
@property (nonatomic, copy) void (^drawingEnded)(NSDictionary *dict);
@property (nonatomic) BOOL isDrawingEnabled;
@property (nonatomic) BOOL isDrawing;
@property (nonatomic, retain) UIColor *strokeColor;
@property (nonatomic) NSInteger lineWidth;

- (void)clearDrawing;
- (void)undoDrawing;

@end
