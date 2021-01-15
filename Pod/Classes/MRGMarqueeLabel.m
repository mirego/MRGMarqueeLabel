//
// Copyright (c) 2014-2020, Mirego
// All rights reserved.
//
// Redistribution and use in source and binary forms, with or without
// modification, are permitted provided that the following conditions are met:
//
// - Redistributions of source code must retain the above copyright notice,
//   this list of conditions and the following disclaimer.
// - Redistributions in binary form must reproduce the above copyright notice,
//   this list of conditions and the following disclaimer in the documentation
//   and/or other materials provided with the distribution.
// - Neither the name of the Mirego nor the names of its contributors may
//   be used to endorse or promote products derived from this software without
//   specific prior written permission.
//
// THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
// AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
// IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
// ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE
// LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
// CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
// SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
// INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
// CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
// ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
// POSSIBILITY OF SUCH DAMAGE.

#import "MRGMarqueeLabel.h"

@interface MRGMarqueeLabel ()

@property (nonatomic, readonly) UIView *contentView;
@property (nonatomic, readonly) UIView *labelsContainerView;
@property (nonatomic, readonly) UILabel *firstLabel;
@property (nonatomic, readonly) UILabel *secondLabel;
@property (nonatomic, readonly) CAGradientLayer *maskLayer;
@property (nonatomic) BOOL textFitsWidth;
@property (nonatomic) BOOL needsAnimationReset;
@end

@implementation MRGMarqueeLabel

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame text:nil];
}

- (instancetype)initWithFrame:(CGRect)frame text:(NSString *)text {
    self = [super initWithFrame:frame];
    if (self) {
        self.isAccessibilityElement = YES;
        self.accessibilityTraits = super.accessibilityTraits | UIAccessibilityTraitStaticText;
        
        _animationSpeed = 100.f;
        _animationTimingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseInEaseOut];
        _pause = 1.f;
        _gapWidth = 100.f;
        _repeatCount = INFINITY;
        
        [self addSubview:(_contentView = [UIView new])];
        
        [self.contentView addSubview:(_labelsContainerView = [UIView new])];
        
        [self.labelsContainerView addSubview:(_firstLabel = [UILabel new])];
        self.firstLabel.isAccessibilityElement = NO;
        self.firstLabel.backgroundColor = [UIColor clearColor];
        self.firstLabel.text = text;
        
        [self.labelsContainerView addSubview:(_secondLabel = [UILabel new])];
        self.secondLabel.isAccessibilityElement = NO;
        self.secondLabel.backgroundColor = [UIColor clearColor];
        
        _maskLayer = [CAGradientLayer layer];
        self.maskLayer.startPoint = CGPointMake(0.f, 0.5f);
        self.maskLayer.endPoint = CGPointMake(1.f, 0.5f);
        self.maskLayer.colors = [self leftSideVisibleColors];
        self.maskInset = 20.f;
    }
    
    return self;
}

- (CGSize)sizeThatFits:(CGSize)size {
    return [self.firstLabel sizeThatFits:size];
}

- (CGSize)intrinsicContentSize {
    return [self.firstLabel intrinsicContentSize];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    if (self.needsAnimationReset || !CGRectEqualToRect(self.contentView.bounds, self.bounds)) {
        self.needsAnimationReset = NO;
        
        self.contentView.frame = self.bounds;
        self.maskLayer.bounds = self.bounds;
        self.maskLayer.position = CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
        
        [self updateMaskGradientLocations];
        [self layoutLabels];
    }
}

- (void)setNeedsAnimationReset {
    self.needsAnimationReset = YES;
    [self setNeedsLayout];
}

#pragma mark - Getters and Setters

- (void)setAnimationSpeed:(CGFloat)animationSpeed {
    if (_animationSpeed != animationSpeed) {
        _animationSpeed = animationSpeed;
        
        [self updateMaskColors];
        [self setNeedsAnimationReset];
    }
}

- (void)setAnimationTimingFunction:(CAMediaTimingFunction *)animationTimingFunction {
    if (_animationTimingFunction != animationTimingFunction) {
        _animationTimingFunction = animationTimingFunction;
        
        [self setNeedsAnimationReset];
    }
}

- (void)setPause:(CGFloat)pause {
    if (_pause != pause) {
        _pause = pause;
        
        [self updateMaskColors];
        [self setNeedsAnimationReset];
    }
}

- (void)setMaskInset:(CGFloat)maskInset {
    if (_maskInset != maskInset) {
        _maskInset = maskInset;
        
        [self updateMaskGradientLocations];
        [self setNeedsAnimationReset];
    }
}

- (void)setGapWidth:(CGFloat)gapWidth {
    if (_gapWidth != gapWidth) {
        _gapWidth = gapWidth;
        
        [self setNeedsAnimationReset];
    }
}

- (void)setRepeatCount:(CGFloat)repeatCount {
    if (_repeatCount != repeatCount) {
        _repeatCount = repeatCount;
        
        [self setNeedsAnimationReset];
    }
}

- (NSString *)text {
    return self.firstLabel.text;
}

- (void)setText:(NSString *)text {
    if (![self.firstLabel.text isEqualToString:text]) {
        self.accessibilityLabel = text;
        self.firstLabel.text = text;
        self.secondLabel.text = text;
        
        [self setNeedsAnimationReset];
    }
}

- (UIColor *)textColor {
    return self.firstLabel.textColor;
}

- (void)setTextColor:(UIColor *)textColor {
    if (![self.firstLabel.textColor isEqual:textColor]) {
        self.firstLabel.textColor = textColor;
        self.secondLabel.textColor = textColor;
    }
}

- (UIFont *)font {
    return self.firstLabel.font;
}

- (void)setFont:(UIFont *)font {
    if (![self.firstLabel.font isEqual:font]) {
        self.firstLabel.font = font;
        self.secondLabel.font = font;
        
        [self setNeedsAnimationReset];
    }
}

- (void)setTextAlignment:(MRGMarqueeLabelTextAlignment)textAlignment {
    if (_textAlignment != textAlignment) {
        _textAlignment = textAlignment;
        
        [self updateMaskColors];
        [self setNeedsAnimationReset];
    }
}

#pragma mark - Private Methods

- (void)layoutLabels {
    [self.labelsContainerView.layer removeAllAnimations];
    [self.contentView.layer removeAllAnimations];
    
    CGSize labelSize = [self.firstLabel sizeThatFits:CGSizeZero];
    
    self.textFitsWidth = labelSize.width <= CGRectGetWidth(self.bounds);
    CGRect containerRect = CGRectZero;
    
    if (self.textFitsWidth) {
        containerRect.size = CGSizeMake(labelSize.width, CGRectGetHeight(self.bounds));
        if (self.textAlignment == MRGMarqueeLabelTextAlignmentCenter) {
            containerRect.origin.x = floorf((CGRectGetWidth(self.bounds) - CGRectGetWidth(containerRect)) * 0.5f);
        }
        
        self.contentView.layer.mask = nil;
        
    } else {
        containerRect.size.height = CGRectGetHeight(self.bounds);
        containerRect.size.width = (labelSize.width * 2.f) + self.gapWidth;
        containerRect.origin.x = (self.textAlignment == MRGMarqueeLabelTextAlignmentLeft ? 0.f : self.maskInset);
        
        self.contentView.layer.mask = self.maskLayer;
    }
    
    self.labelsContainerView.frame = containerRect;
    
    CGRect firstLabelFrame = self.firstLabel.frame;
    firstLabelFrame.size = CGSizeMake(labelSize.width, CGRectGetHeight(self.bounds));
    self.firstLabel.frame = firstLabelFrame;
    
    CGRect secondLabelFrame = self.secondLabel.frame;
    secondLabelFrame.size = CGSizeMake(labelSize.width, CGRectGetHeight(self.bounds));
    secondLabelFrame.origin.x = self.firstLabel.frame.size.width + self.gapWidth;
    self.secondLabel.frame = secondLabelFrame;
    self.secondLabel.hidden = self.textFitsWidth;
    
    [self updateMaskColors];
    [self handleAnimations];
}

- (void)handleAnimations {
    if (self.animationSpeed <= 0.f) {
        [self.labelsContainerView.layer removeAnimationForKey:@"marquee"];
        [self.maskLayer removeAnimationForKey:@"mask"];
        return;
    }
    
    CGFloat duration = CGRectGetWidth(self.firstLabel.bounds) / MAX(self.animationSpeed, 1.f);
    
    if (!self.textFitsWidth) {
        CGFloat toValue = -(self.firstLabel.frame.size.width + self.gapWidth);
        CABasicAnimation *scrollAnim = [CABasicAnimation animationWithKeyPath:@"transform.translation.x"];
        scrollAnim.fromValue = @(0.f);
        scrollAnim.toValue = @(toValue);
        scrollAnim.duration = duration;
        scrollAnim.fillMode = kCAFillModeBackwards;
        scrollAnim.timingFunction = self.pause > 0.f ? self.animationTimingFunction : [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionLinear];
        
        CAAnimationGroup *scrollAnimGroup = [CAAnimationGroup animation];
        scrollAnimGroup.beginTime = CACurrentMediaTime() + self.pause;
        scrollAnimGroup.duration = duration + self.pause;
        scrollAnimGroup.repeatCount = self.repeatCount;
        scrollAnimGroup.animations = @[scrollAnim];
        
        [self.labelsContainerView.layer addAnimation:scrollAnimGroup forKey:@"marquee"];
    }
    
    if (!self.textFitsWidth && self.textAlignment == MRGMarqueeLabelTextAlignmentLeft && self.pause > 0.f) {
        CAKeyframeAnimation *maskColors = [CAKeyframeAnimation animationWithKeyPath:@"colors"];
        maskColors.keyTimes = @[@0.f, @0.5, @1.f];
        maskColors.values = @[
            [self leftSideVisibleColors],
            [self leftSideMaskedColors],
            [self leftSideVisibleColors]
        ];
        maskColors.duration = duration;
        maskColors.fillMode = kCAFillModeBackwards;
        
        CAAnimationGroup *maskAnimGroup = [CAAnimationGroup animation];
        maskAnimGroup.beginTime = CACurrentMediaTime() + self.pause;
        maskAnimGroup.duration = duration + self.pause;
        maskAnimGroup.repeatCount = self.repeatCount;
        maskAnimGroup.animations = @[maskColors];
        
        [self.maskLayer addAnimation:maskAnimGroup forKey:@"mask"];
    }
}

- (NSArray *)leftSideMaskedColors {
    return @[
        (id)UIColor.clearColor.CGColor,
        (id)UIColor.whiteColor.CGColor,
        (id)UIColor.whiteColor.CGColor,
        (id)UIColor.clearColor.CGColor
    ];
}

- (NSArray *)leftSideVisibleColors {
    return @[
        (id)UIColor.whiteColor.CGColor,
        (id)UIColor.whiteColor.CGColor,
        (id)UIColor.whiteColor.CGColor,
        (id)UIColor.clearColor.CGColor
    ];
}

- (void)updateMaskGradientLocations {
    if (!CGRectEqualToRect(self.bounds, CGRectZero)) {
        CGFloat inset = self.maskInset / CGRectGetWidth(self.bounds);
        self.maskLayer.locations = @[@0.f, @(inset), @(1.f - inset), @1.f];
    }
}

- (void)updateMaskColors {
    NSArray *colors;
    if (!self.textFitsWidth && (self.animationSpeed != 0.f) &&
        (self.textAlignment == MRGMarqueeLabelTextAlignmentCenter || self.pause == 0.f)) {
        colors = [self leftSideMaskedColors];
    } else {
        colors = [self leftSideVisibleColors];
    }
    
    self.maskLayer.colors = colors;
}

@end
