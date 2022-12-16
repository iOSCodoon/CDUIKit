//
//  CDSegmentedButton.m
//  CodoonSport
//
//  Created by Jinxiao on 30/06/2017.
//  Copyright © 2017 codoon. All rights reserved.
//

#import "CDSegmentedButton.h"

@interface CDSegmentedButton ()
@property (readwrite, nonatomic, strong) NSMutableDictionary *fonts;
@property (strong, nonatomic) UIFont *normalFont;
@property (strong, nonatomic) UIFont *highlightedFont;
@property (strong, nonatomic) UIFont *selectedFont;
@property (strong, nonatomic) UIFont *disabledFont;
@property (strong, nonatomic) UIView *redDotView;
@end

@implementation CDSegmentedButton

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        UIView *redDotView = [UIView new];
        self.redDotView = redDotView;
        redDotView.hidden = YES;
        redDotView.backgroundColor = [UIColor redColor];
        redDotView.layer.cornerRadius = 2.5;
        redDotView.clipsToBounds = YES;
        redDotView.translatesAutoresizingMaskIntoConstraints = NO;
        [self.titleLabel addSubview:redDotView];
        [redDotView.widthAnchor constraintEqualToConstant:5].active = YES;
        [redDotView.heightAnchor constraintEqualToConstant:5].active = YES;
        [redDotView.topAnchor constraintEqualToAnchor:self.titleLabel.topAnchor constant:0].active = YES;
        [redDotView.leftAnchor constraintEqualToAnchor:self.titleLabel.rightAnchor constant:5].active = YES;
    }
    return self;
}

- (void)setShowRedDot:(BOOL)showRedDot {
    _showRedDot = showRedDot;
    self.redDotView.hidden = !showRedDot;
}

- (NSMutableDictionary *)fonts {
    if (_fonts == nil) {
        _fonts = [[NSMutableDictionary alloc] init];
    }
    return _fonts;
}

- (void)setFont:(UIFont *)font forState:(NSUInteger)state {
    if (font == nil) {
        [self.fonts removeObjectForKey:@(state)];
    } else {
        [self.fonts setObject:font forKey:@(state)];
    }

    [self setNeedsLayout];
    [self layoutIfNeeded];
}

- (void)layoutSubviews {
    UIFont *font = [self.fonts objectForKey:@(self.state)];

    if (font == nil) {
        font = [self.fonts objectForKey:@(UIControlStateNormal)];
    }

    self.titleLabel.font = font;
    
    [super layoutSubviews];
}

@end
