/*
 
 The MIT License (MIT) 

 Copyright (c) 2018 Intuz
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.
 
 */


#import "BBAssistiveControl.h"
#import "BBContants.h"

@interface BBAssistiveControl ()
{
    CGFloat startAngle;
    CGFloat endAngle;
}

@end


@implementation BBAssistiveControl

#pragma mark - Add Circle

- (void)drawCircleInView:(UIImageView *)imageView
{
    UIBezierPath* bezierPath = [UIBezierPath bezierPath];
    
    // Create our arc, with the correct angles
    [bezierPath addArcWithCenter:CGPointMake(imageView.frame.size.width / 2, imageView.frame.size.height / 2)
                          radius:imageView.frame.size.width / 2
                      startAngle:startAngle
                        endAngle:(endAngle - startAngle) * (self.progress / totalSecounds) + startAngle
                       clockwise:YES];
    
    CAShapeLayer *snape = [CAShapeLayer layer];
    snape.path=bezierPath.CGPath;
    snape.fillColor = nil;
    snape.opacity = 2.0;
    snape.lineWidth = 2;
    snape.strokeColor = kBBRGBCOLOR(17,195,194).CGColor;
    [imageView.layer addSublayer:snape];
}

NSTimer *timer;
NSInteger totalSecounds;
- (void)startProgressWithSecounds:(NSInteger) secounds completion:(BBCompleteProgress) complete
{
    self.completeProgress = [complete copy];
    self.isRunningTimer = YES;
    totalSecounds = secounds;
    self.progress = 0;
    [self nextStep];
}

- (void) nextStep {
    if (self.isRunningTimer) {
        if (self.progress <= totalSecounds) {
            self.progress += 1;
            UIImageView *imageView = (UIImageView *)[_viewContent viewWithTag:1234];
            [self drawCircleInView:imageView];
            [imageView setNeedsDisplay];
            dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                [self nextStep];
            });
        }
        else {
            self.isRunningTimer = NO;
            self.progress = 0;
            if (self.completeProgress) {
                self.completeProgress();
            }
        }
    }
}

- (void)stopProgress {
    self.isRunningTimer = NO;
}

#pragma mark - Convenient Creators

const static NSTimeInterval kAnimDuration = 0.3f;

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _stickyEdge = YES;
        self.backgroundColor = [UIColor clearColor];
        
        // Determine our start and stop angles for the arc (in radians)
        startAngle = M_PI * 1.5;
        endAngle = startAngle + (M_PI * 2);
        
        UIImageView *imgView = [[UIImageView alloc] initWithFrame:self.bounds];
        [imgView setImage:[UIImage imageNamed:@"bb_stop_btn"]];
        [imgView setTag:1234];
        [_viewContent addSubview:imgView];
        _viewContent = imgView;
        self.isRunningTimer = NO;
        
        [self addSubview:_viewContent];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(orientationDidChange:) name:UIDeviceOrientationDidChangeNotification object:nil];
    }
    return self;
}

- (void) setImage:(UIImage *) image {
    [(UIImageView *)[_viewContent viewWithTag:1234] setImage:image];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIDeviceOrientationDidChangeNotification object:nil];
}

- (void)orientationDidChange:(NSNotification *)notification {
    [self adjustControlPositionForStickyEdgeWithCompletion:nil];
}


- (void)didMoveToSuperview {
    [self adjustControlPositionForStickyEdgeWithCompletion:nil];
}

- (void)setStickyEdge:(BOOL)stickyEdge {
    _stickyEdge = stickyEdge;
    [self adjustControlPositionForStickyEdgeWithCompletion:nil];
}

- (void)setViewContent:(UIView *)viewContent {
    [_viewContent removeFromSuperview];
    _viewContent = viewContent;
    _viewContent.userInteractionEnabled = NO;
    _collapsedViewLastPosition = viewContent.frame.origin;
    
    CGRect destFrame = _viewContent.frame;
    destFrame.origin = _collapsedViewLastPosition;
    
    self.frame = destFrame;
    _viewContent.center = CGPointMake(self.frame.size.width / 2, self.frame.size.height / 2);
    [self addSubview:_viewContent];
    [self adjustControlPositionForStickyEdgeWithCompletion:nil];

}

#pragma mark - Private

- (void)adjustControlPositionForStickyEdgeWithCompletion:(void (^)(BOOL frameChanged))completion {
    if (_stickyEdge && self.superview != nil) {
        CGPoint destPosition = [self calculateStickyEdgeDestinationPosition];
        
        if (CGPointEqualToPoint(self.frame.origin, destPosition) == NO) {
            [UIView animateWithDuration:kAnimDuration animations:^(){
                self.frame = CGRectMake(destPosition.x, destPosition.y, self.frame.size.width, self.frame.size.height);
            } completion:^(BOOL finished){
                if (completion) {
                    completion(YES);
                }
            }];
        }
        else if (completion) {
            completion(NO);
        }
    }
    else if (completion) {
        completion(NO);
    }
}

- (CGPoint)calculateStickyEdgeDestinationPosition {
    CGRect containerBounds = self.superview.bounds;
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(self.frame.origin.y, self.frame.origin.x, containerBounds.size.height - (self.frame.origin.y + self.frame.size.height), containerBounds.size.width - (self.frame.origin.x + self.frame.size.width));
    CGFloat edgeDistance = edgeInsets.top;
    CGPoint destPosition = CGPointMake(self.frame.origin.x, 0);
    
    if (edgeInsets.bottom < edgeDistance) {
        edgeDistance = edgeInsets.bottom;
        destPosition = CGPointMake(self.frame.origin.x, containerBounds.size.height - self.frame.size.height);
    }
    if (edgeInsets.left < edgeDistance) {
        edgeDistance = edgeInsets.left;
        destPosition = CGPointMake(0, self.frame.origin.y);
    }
    if (edgeInsets.right < edgeDistance) {
        destPosition = CGPointMake(containerBounds.size.width - self.frame.size.width, self.frame.origin.y);
    }
    
    if (destPosition.x < 0) {
        destPosition.x = 0;
    }
    else if (destPosition.x > containerBounds.size.width - self.frame.size.width) {
        destPosition.x = containerBounds.size.width - self.frame.size.width;
    }
    if (destPosition.y < 0) {
        destPosition.y = 0;
    }
    else if (destPosition.y > containerBounds.size.height - self.frame.size.height) {
        destPosition.y = containerBounds.size.height - self.frame.size.height;
    }
    
    return destPosition;
}

@end
