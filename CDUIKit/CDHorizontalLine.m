//
//  CDHorizontalLine.m
//  CodoonSport
//
//  Created by Jinxiao on 2/16/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import "CDHorizontalLine.h"

@interface CDHorizontalLine ()
@property (readwrite, nonatomic, strong) CALayer *line;
@end

@implementation CDHorizontalLine

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    if(_color == nil)
    {
        _color = kLineColor;
    }
    
    _line = [self addBottomBorderWithColor:kLineColor andWidth:kLineWidth];
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
    
    _line.frame = CGRectMake(0, (self.height - kLineWidth)/2, self.width, kLineWidth);
}

@end
