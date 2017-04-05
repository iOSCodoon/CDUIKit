//
//  CDVerticalLine.m
//  CodoonSport
//
//  Created by Jinxiao on 2/16/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import "CDVerticalLine.h"

@interface CDVerticalLine ()
@property (readwrite, nonatomic, strong) CALayer *line;
@end

@implementation CDVerticalLine

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    _color = kLineColor;
    
    _line = [self addLeftBorderWithColor:kLineColor andWidth:kLineWidth];
    [self.layer addSublayer:_line];
}

- (void)setColor:(UIColor *)color
{
    _color = color;
    
    [self setNeedsLayout];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.backgroundColor = [UIColor clearColor];
    
    _line.backgroundColor = _color.CGColor;
    
    _line.frame = CGRectMake((self.width - kLineWidth)/2, 0, kLineWidth, self.height);
}

@end
