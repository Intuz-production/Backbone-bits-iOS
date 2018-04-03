
/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */

#import "BBDrawableView.h"

static NSString *const kBBPath = @"Path";
static NSString *const kBBStrokeColor = @"Color";

static const CGFloat kPointMinDistance = 5.0f;
static const CGFloat kPointMinDistanceSquared = kPointMinDistance * kPointMinDistance;

@interface BBDrawableView ()
{
    NSDictionary *currentDict;
    CGMutablePathRef _currentPath;
}

@property (nonatomic,assign) CGPoint currentPoint;
@property (nonatomic,assign) CGPoint previousPoint;
@property (nonatomic,assign) CGPoint previousPreviousPoint;

#pragma mark Private Help function
CGPoint midPoint(CGPoint p1, CGPoint p2);

@end

@implementation BBDrawableView

#pragma mark private Help function

CGPoint midPoint(CGPoint p1, CGPoint p2) {
    return CGPointMake((p1.x + p2.x) * 0.5, (p1.y + p2.y) * 0.5);
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _currentPath = CGPathCreateMutable();
        _arrPaths = [[NSMutableArray alloc] init];
        _lineWidth = 5.0;
        [self setBackgroundColor:[UIColor clearColor]];
        [self setUserInteractionEnabled:YES];
        [self setMultipleTouchEnabled:NO];
    }
    return self;
}

- (void)drawRect:(CGRect)rect {
    for (NSDictionary *dict in _arrPaths) {
        CGMutablePathRef path = (__bridge CGMutablePathRef)([dict objectForKey:kBBPath]);
        CGContextRef context = UIGraphicsGetCurrentContext();
        CGContextAddPath(context, path);
        CGContextSetLineCap(context, kCGLineCapRound);
        CGContextSetLineWidth(context, _lineWidth);
        UIColor *color = [dict objectForKey:kBBStrokeColor];
        CGContextSetStrokeColorWithColor(context, color.CGColor);
        CGContextStrokePath(context);
    }
    
    
}

#pragma mark - Touch 

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!_isDrawingEnabled) {
        return;
    }
    _isDrawing = TRUE;
    UITouch *touch = [touches anyObject];

    // initializes our point records to current location
    self.previousPoint = [touch previousLocationInView:self];
    self.previousPreviousPoint = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];

    if(_drawingStarted) {
        _drawingStarted();
    }
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!_isDrawingEnabled) {
        return;
    }
    _isDrawing = TRUE;
    
    UITouch *touch = [touches anyObject];
    
    CGPoint point = [touch locationInView:self];
    
    // if the finger has moved less than the min dist ...
    CGFloat dx = point.x - self.currentPoint.x;
    CGFloat dy = point.y - self.currentPoint.y;
    
    if ((dx * dx + dy * dy) < kPointMinDistanceSquared) {
        // ... then ignore this movement
        return;
    }
    
    // update points: previousPrevious -> mid1 -> previous -> mid2 -> current
    self.previousPreviousPoint = self.previousPoint;
    self.previousPoint = [touch previousLocationInView:self];
    self.currentPoint = [touch locationInView:self];
    
    CGPoint mid1 = midPoint(self.previousPoint, self.previousPreviousPoint);
    CGPoint mid2 = midPoint(self.currentPoint, self.previousPoint);
    
    // to represent the finger movement, create a new path segment,
    // a quadratic bezier path from mid1 to mid2, using previous as a control point
    CGMutablePathRef subpath = CGPathCreateMutable();
    CGPathMoveToPoint(subpath, NULL, mid1.x, mid1.y);
    CGPathAddQuadCurveToPoint(subpath, NULL,
                              self.previousPoint.x, self.previousPoint.y,
                              mid2.x, mid2.y);
    
    // compute the rect containing the new segment plus padding for drawn line
    CGRect bounds = CGPathGetBoundingBox(subpath);
    CGRect drawBox = CGRectInset(bounds, -2.0 * _lineWidth, -2.0 * _lineWidth);
    
    // append the quad curve to the accumulated path so far.
    CGPathAddPath(_currentPath, NULL, subpath);
    CGPathRelease(subpath);
    
    currentDict = @{kBBPath : (__bridge id)_currentPath,
                    kBBStrokeColor : [_strokeColor copy]};

    __block BOOL isContainsPath = FALSE;
    [_arrPaths enumerateObjectsUsingBlock:^(NSDictionary *dict, NSUInteger idx, BOOL *stop) {
        if(_currentPath == (__bridge CGMutablePathRef)([dict objectForKey:kBBPath])) {
            isContainsPath = TRUE;
            *stop = YES;
        }
    }];
    if(!isContainsPath) {
        [_arrPaths addObject:currentDict];
    }
    
    [self setNeedsDisplayInRect:drawBox];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    if(!_isDrawingEnabled) {
        return;
    }
    _isDrawing = FALSE;
    if(_drawingEnded) {
        _drawingEnded(currentDict);
    }
    
    CGMutablePathRef oldPath = _currentPath;
    CFRelease(oldPath);
    _currentPath = CGPathCreateMutable();
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [self touchesEnded:touches withEvent:event];
}

- (void)clearDrawing {
    [_arrPaths removeAllObjects];
    [self setNeedsDisplay];
}

- (void)undoDrawing {
    [_arrPaths removeLastObject];
    [self setNeedsDisplay];
}


@end
