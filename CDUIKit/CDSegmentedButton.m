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
@end

@implementation CDSegmentedButton

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
