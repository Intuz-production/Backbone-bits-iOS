/*
 JNJProgressButton
 
 Copyright (c) 2013 Josh Johnson <jnjosh@jnjosh.com>
 
 Permission is hereby granted, free of charge, to any person obtaining a copy of
 this software and associated documentation files (the "Software"), to deal in
 the Software without restriction, including without limitation the rights to
 use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
 of the Software, and to permit persons to whom the Software is furnished to do
 so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in all
 copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
 SOFTWARE.
 */

#import "BBProgressButton.h"
#import <QuartzCore/QuartzCore.h>

static CGFloat const kBBProgressCircleDiameter = 20.0f;
static CGFloat const kBBProgressCircleShadowRadius = 5.0f;
static CGFloat const kBBProgressStopWidth = 5.0f;

typedef NS_ENUM(NSUInteger, BBProgressButtonState) {
    BBProgressButtonStateUnstarted,
    BBProgressButtonStateProgressing,
    BBProgressButtonStateFinished
};

@interface BBProgressButton ()

@property (nonatomic, assign) BBProgressButtonState state;

@property (nonatomic, strong) UIImageView *buttonImageView;
@property (nonatomic, strong) CAShapeLayer *progressCircleLayer;
@property (nonatomic, strong) CAShapeLayer *progressTrackLayer;

@end

@implementation BBProgressButton

#pragma mark - Life Cycle

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self commonInit];
    }
    return self;
}

- (void)commonInit
{
    self.needsProgress = YES;
    self.state = BBProgressButtonStateUnstarted;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(progressButtonWasTapped:)]];
    
    self.buttonImageView = [UIImageView new];
    [self addSubview:self.buttonImageView];
}

#pragma mark - Show Progress

- (void)startProgressWithSecounds:(NSInteger) secounds
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        NSInteger index = 0;
        while (index <= secounds*10) {
            [NSThread sleepForTimeInterval:.1];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.progress = (index / (secounds*10));
            });
            index++;
            
            if (!self.progressing) return;
        }
    });
}


#pragma mark - Properties

- (void)setProgress:(float)progress
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(progress))];
    _progress = progress;
    [self didChangeValueForKey:NSStringFromSelector(@selector(progress))];
    
    [self updateButtonForProgress:_progress];
}

- (CAShapeLayer *)progressTrackLayer
{
    if (!_progressTrackLayer) {
        CGRect trackRect = CGRectInset([self rectForProgressCircle], 1.0f, 1.0f);
        _progressTrackLayer = [self circleLayerWithRect:trackRect
                                            strokeColor:[self trackColor]
                                            shadowColor:nil];
        _progressTrackLayer.lineWidth = 3.0f;
    }
    return _progressTrackLayer;
}

- (void)setStartButtonImage:(UIImage *)startButtonImage
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(startButtonImage))];
    _startButtonImage = startButtonImage;
    [self didChangeValueForKey:NSStringFromSelector(@selector(startButtonImage))];

    if (self.state == BBProgressButtonStateUnstarted) {
        [self updateButtonImageForState:self.state];
    }
}

- (void)setEndButtonImage:(UIImage *)endButtonImage
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(endButtonImage))];
    _endButtonImage = endButtonImage;
    [self didChangeValueForKey:NSStringFromSelector(@selector(endButtonImage))];
    
    if (self.state == BBProgressButtonStateFinished) {
        [self updateButtonImageForState:self.state];
    }
}

- (void)setNeedsProgress:(BOOL)needsProgress
{
    [self willChangeValueForKey:NSStringFromSelector(@selector(needsProgress))];
    _needsProgress = needsProgress;
    [self didChangeValueForKey:NSStringFromSelector(@selector(needsProgress))];
    
    if (self.state != BBProgressButtonStateProgressing) {
        if (needsProgress) {
            self.state = BBProgressButtonStateUnstarted;
        } else {
            self.state = BBProgressButtonStateFinished;
        }
        
        [self updateButtonImageForState:self.state];
        [self setNeedsLayout];
    }
}

- (BOOL)isProgressing
{
    return self.state == BBProgressButtonStateProgressing;
}

#pragma mark - Layout

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.buttonImageView.center = (CGPoint) { CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds) };
}

#pragma mark - Accessibility

- (BOOL)isAccessibilityElement
{
    return YES;
}

- (UIAccessibilityTraits)accessibilityTraits
{
    return [super accessibilityTraits] | UIAccessibilityTraitButton;
}

#pragma mark - Progress

- (void)setProgress:(float)progress animated:(BOOL)animated
{
    // TODO(JNJ): Implement Animated (or non-animated)
    self.progress = progress;
}

- (void)updateButtonForProgress:(float)progress
{
    if (self.state != BBProgressButtonStateProgressing) return;
    
    if (0.0f < progress && progress <= 1.0f) {
        
        self.progressCircleLayer.strokeEnd = 1.0f;
        [self.progressCircleLayer removeAllAnimations];

        self.progressTrackLayer.strokeEnd = progress;

        if (progress == 1.0f) {
            [self startFinishedState];
        }
    }
}

- (void)addTrackIfNeeded
{
    if (!self.progressTrackLayer.superlayer) {
        [self.layer addSublayer:self.progressTrackLayer];
        [self.progressTrackLayer addSublayer:[self boxLayerInRect:[self rectForProgressCircle]
                                                        fillColor:[self trackColor]]];
    }
}

#pragma mark - Actions

- (void)progressButtonWasTapped:(UIGestureRecognizer *)gestureRecognizer
{
    if (self.state == BBProgressButtonStateUnstarted) {
        [self startProgress];
        
        if ([self.delegate respondsToSelector:@selector(progressButtonStartButtonTapped:)]) {
            [self.delegate progressButtonStartButtonTapped:self];
        }
        
        if (self.startButtonDidTapBlock) {
            self.startButtonDidTapBlock(self);
        }
    } else if (self.state == BBProgressButtonStateProgressing) {
        [self endProgressWithState:BBProgressButtonStateUnstarted];
        
        if ([self.delegate respondsToSelector:@selector(progressButtonDidCancelProgress:)]) {
            [self.delegate progressButtonDidCancelProgress:self];
        }
        
        if (self.progressDidCancelBlock) {
            self.progressDidCancelBlock(self);
        }
    } else if (self.state == BBProgressButtonStateFinished) {
        if ([self.delegate respondsToSelector:@selector(progressButtonEndButtonTapped:)]) {
            [self.delegate progressButtonEndButtonTapped:self];
        }
        
        if (self.endButtonDidTapBlock) {
            self.endButtonDidTapBlock(self);
        }
    }
}

- (void)startProgress
{
    self.state = BBProgressButtonStateProgressing;

    [UIView animateWithDuration:0.2 animations:^{
        self.buttonImageView.alpha = 0.0f;
        self.buttonImageView.transform = CGAffineTransformMakeScale(0.5f, 0.5f);
    }];
    
    [self startPreprogress];
}

- (void)endProgressWithState:(BBProgressButtonState)state
{
    self.state = state;
    
    [self.progressTrackLayer removeFromSuperlayer];
    self.progressTrackLayer = nil;
    
    CABasicAnimation *shrinkAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    shrinkAnimation.toValue = @0.0f;
    shrinkAnimation.duration = 0.25f;
    [self.progressCircleLayer addAnimation:shrinkAnimation forKey:@"shrinkProgress"];
    self.progressCircleLayer.transform = CATransform3DMakeScale(0, 0, 0);
    
    [UIView animateWithDuration:0.2 animations:^{
        self.buttonImageView.alpha = 1.0f;
        self.buttonImageView.transform = CGAffineTransformIdentity;
    } completion:^(BOOL finished) {
        [self.progressCircleLayer removeFromSuperlayer];
        self.progressCircleLayer = nil;
    }];
}

- (void)startPreprogress
{
    UIColor *strokeColor = [self trackColor];
    UIColor *glowColor = [self glowColorForTrackColor];
    CGRect circleRect = [self rectForProgressCircle];
    
    self.progressCircleLayer = [self circleLayerWithRect:circleRect
                                             strokeColor:strokeColor
                                             shadowColor:glowColor];
    self.progressCircleLayer.frame = self.bounds;
    self.progressCircleLayer.strokeEnd = 0.9;
    [self.layer addSublayer:self.progressCircleLayer];

    CAAnimationGroup *growAnimationGroup = [CAAnimationGroup animation];
    {
        CABasicAnimation *growAnimation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
        growAnimation.fromValue = @0.0f;
        CABasicAnimation *fadeAnimation = [CABasicAnimation animationWithKeyPath:@"fillColor"];
        fadeAnimation.fromValue = (__bridge id)(glowColor.CGColor);
        fadeAnimation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
        growAnimationGroup.animations = @[ growAnimation, fadeAnimation ];
    }
    growAnimationGroup.duration = 0.25f;
    growAnimationGroup.removedOnCompletion = YES;
    [self.progressCircleLayer addAnimation:growAnimationGroup forKey:@"scale"];
    
    CABasicAnimation *rotationAnimation = [CABasicAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAnimation.fromValue = @0.0f;
    rotationAnimation.toValue = @(M_PI * 2);
    rotationAnimation.repeatCount = CGFLOAT_MAX;
    rotationAnimation.duration = 1.0f;
    [self.progressCircleLayer addAnimation:rotationAnimation forKey:@"rotate"];
}

- (void)startFinishedState
{
    [self updateButtonImageForState:BBProgressButtonStateFinished];
    [self endProgressWithState:BBProgressButtonStateFinished];
}

#pragma mark - Helps

- (UIImage *)imageForState:(BBProgressButtonState)state
{
    UIImage *image = nil;
    
    if (state == BBProgressButtonStateUnstarted) {
        image = self.startButtonImage;
    } else if (state == BBProgressButtonStateFinished) {
        image = self.endButtonImage;
    }
    
    return image;
}

- (CGRect)rectForProgressCircle
{
    return (CGRect) {
        CGRectGetMidX(self.bounds) - kBBProgressCircleDiameter / 2.0f,
        CGRectGetMidY(self.bounds) - kBBProgressCircleDiameter / 2.0f,
        kBBProgressCircleDiameter,
        kBBProgressCircleDiameter
    };
}

- (UIBezierPath *)circlePathInRect:(CGRect)circleRect
{
    CGFloat radians = (90 * M_PI) / 180;
    CGFloat radius = CGRectGetWidth(circleRect) / 2.0f;
    CGPoint center = (CGPoint) { CGRectGetMidX(circleRect), CGRectGetMidY(circleRect) };
    UIBezierPath *path = [UIBezierPath bezierPath];
    [path moveToPoint:(CGPoint) { CGRectGetMidX(circleRect), CGRectGetMinY(circleRect) }];
    [path addArcWithCenter:center radius:radius startAngle:-(radians) endAngle:0 clockwise:YES];
    [path addArcWithCenter:center radius:radius startAngle:0 endAngle:radians clockwise:YES];
    [path addArcWithCenter:center radius:radius startAngle:radians endAngle:(radians * 2) clockwise:YES];
    [path addArcWithCenter:center radius:radius startAngle:(radians * 2) endAngle:-(radians) clockwise:YES];
    [path closePath];
    
    return path;
}

- (CAShapeLayer *)circleLayerWithRect:(CGRect)circleRect
                          strokeColor:(UIColor *)strokeColor
                          shadowColor:(UIColor *)shadowColor
{
    UIBezierPath *path = [self circlePathInRect:circleRect];
    CAShapeLayer *circleLayer = [CAShapeLayer new];
    circleLayer.masksToBounds = NO;
    circleLayer.path = path.CGPath;
    circleLayer.fillColor = [UIColor clearColor].CGColor;
    circleLayer.strokeColor = strokeColor.CGColor;
    circleLayer.lineWidth = 1.0f;
    
    if (shadowColor) {
        circleLayer.shadowPath = path.CGPath;
        circleLayer.shadowColor = shadowColor.CGColor;
        circleLayer.shadowOpacity = 0.15f;
        circleLayer.shadowRadius = kBBProgressCircleShadowRadius;
        circleLayer.shadowOffset = CGSizeZero;
    }
    
    circleLayer.shouldRasterize = YES;
    circleLayer.rasterizationScale = [[UIScreen mainScreen] scale];
    circleLayer.anchorPoint = (CGPoint) { 0.5f, 0.5f };
    return circleLayer;
}

- (CALayer *)boxLayerInRect:(CGRect)rect
                  fillColor:(UIColor *)fillColor
{
    CGFloat boxSize = kBBProgressStopWidth;
    
    UIBezierPath *path = [UIBezierPath bezierPathWithRect:(CGRect) { CGPointZero, { boxSize, boxSize } }];
    
    CAShapeLayer *boxLayer = [CAShapeLayer layer];
    boxLayer.fillColor = fillColor.CGColor;
    boxLayer.path = path.CGPath;
    boxLayer.position = (CGPoint) { CGRectGetMidX(rect) - boxSize / 2.0f, CGRectGetMidY(rect) - boxSize / 2.0f };
    
    return boxLayer;
}

- (UIColor *)trackColor
{
    return self.tintColor ?: [UIColor darkGrayColor];
}

- (UIColor *)glowColorForTrackColor
{
    UIColor *glowColor = nil;
    UIColor *tintColor = [self trackColor];

    CGFloat hue, saturation, brightness, alpha, white;
    if ([tintColor getHue:&hue saturation:&saturation brightness:&brightness alpha:&alpha]) {
        glowColor = [UIColor colorWithHue:hue
                               saturation:saturation * 0.7f
                               brightness:brightness
                                    alpha:0.8f];
    } else if ([tintColor getWhite:&white alpha:&alpha]) {
        glowColor = [UIColor colorWithWhite:white * 0.7f
                                      alpha:0.8f];
    }
    
    return glowColor;
}

- (void)setImageViewAlphaIfNeeded:(CGFloat)alpha
{
   if (self.state == BBProgressButtonStateFinished || self.state == BBProgressButtonStateUnstarted) {
        self.buttonImageView.alpha = alpha;
    }
}

- (void)updateButtonImageForState:(BBProgressButtonState)state
{
    CGAffineTransform transform = self.buttonImageView.transform;
    self.buttonImageView.transform = CGAffineTransformIdentity;
    self.buttonImageView.image = [self imageForState:state];
    self.buttonImageView.frame = (CGRect) { CGPointZero, self.buttonImageView.image.size };
    self.buttonImageView.transform = transform;
}

#pragma mark - Touch Handling

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    [self setImageViewAlphaIfNeeded:0.5f];
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesEnded:touches withEvent:event];
    [self setImageViewAlphaIfNeeded:1.0f];
}

- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    [super touchesCancelled:touches withEvent:event];
    [self setImageViewAlphaIfNeeded:1.0f];
}

@end
