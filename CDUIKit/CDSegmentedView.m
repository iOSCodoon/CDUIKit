//
//  CDSegmentedView.m
//  AFNetworking
//
//  Created by Jinxiao on 2019/3/20.
//

#import "CDSegmentedView.h"

#import "CDSegmentedButton.h"

@interface CDSegmentedView ()
@property (readwrite, nonatomic, strong) UIScrollView *scrollView;
@property (readwrite, nonatomic, strong) UIView *indicatorView;
@property (readwrite, nonatomic, strong) CALayer *separatorLayer;
@end

@implementation CDSegmentedView

- (instancetype)init {
    self = [super init];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.bounces = NO;
    _scrollView.scrollsToTop = NO;
    _scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:_scrollView];
    
    _indicatorView = [[UIView alloc] init];
    [_scrollView addSubview:_indicatorView];
    
    _separatorLayer = [CALayer layer];
    [self.layer addSublayer:_separatorLayer];
    
    return self;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    _indicatorView.backgroundColor = _indicatorColor;
}

- (void)setHidesIndicator:(BOOL)hidesIndicator {
    _hidesIndicator = hidesIndicator;
    _indicatorView.hidden = _hidesIndicator;
}

- (void)setIndicatorHeight:(CGFloat)indicatorHeight {
    _indicatorHeight = indicatorHeight;
    [self setNeedsLayout];
}

- (void)setIndicatorMarginBottom:(CGFloat)indicatorMarginBottom {
    _indicatorMarginBottom = indicatorMarginBottom;
    [self setNeedsLayout];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    _separatorLayer.backgroundColor = _separatorColor.CGColor;
}

- (void)setHidesSeparator:(BOOL)hidesSeparator {
    _hidesSeparator = hidesSeparator;
    _separatorLayer.hidden = _hidesSeparator;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    _scrollView.frame = self.bounds;
    
    if(_segmentedStyle == CDSegmentedViewControllerSegmentStyleRegular) {
        CGFloat segmentedWidth = self.bounds.size.width/_buttons.count;
        for(NSInteger index = 0; index < _buttons.count; index++) {
            CDSegmentedButton *button = _buttons[index];
            [button sizeToFit];
            button.frame = CGRectMake(index*segmentedWidth + (segmentedWidth - button.bounds.size.width - 34)/2, 0, button.bounds.size.width + 34, _scrollView.bounds.size.height);
        }
        _scrollView.contentSize = CGSizeMake(_scrollView.bounds.size.width, _scrollView.bounds.size.height);
    } else {
        CGFloat offset = 5;
        for(NSInteger index = 0; index < _buttons.count; index++) {
            CDSegmentedButton *button = _buttons[index];
            [button sizeToFit];
            button.frame = CGRectMake(offset, 0, button.bounds.size.width + 34, _scrollView.bounds.size.height);
            
            offset += button.bounds.size.width;
        }
        offset += 5;
        _scrollView.contentSize = CGSizeMake(offset, _scrollView.bounds.size.height);
    }
    
    _separatorLayer.frame = CGRectMake(0, self.bounds.size.height, self.bounds.size.width, _separatorHeight);
    
    CDSegmentedButton *selectedButton = _buttons[_selectedIndex];
    _indicatorView.frame = CGRectMake(selectedButton.frame.origin.x + 17, self.bounds.size.height - _indicatorHeight - _indicatorMarginBottom, selectedButton.bounds.size.width - 34, _indicatorHeight);
}

- (void)segmentedButtonDidPressed:(CDSegmentedButton *)button {
    [_delegate segmentedView:self didSelectIndex:[_buttons indexOfObject:button]];
}

- (void)setButtons:(NSArray<CDSegmentedButton *> *)buttons {
    [_buttons enumerateObjectsUsingBlock:^(CDSegmentedButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromSuperview];
    }];
    
    _buttons = buttons;
    
    [_buttons enumerateObjectsUsingBlock:^(CDSegmentedButton * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj addTarget:self action:@selector(segmentedButtonDidPressed:) forControlEvents:UIControlEventTouchUpInside];
        [self.scrollView addSubview:obj];
    }];
    
    [self setNeedsLayout];
}

- (void)setSelectedIndex:(NSInteger)selectedIndex {
    _selectedIndex = selectedIndex;
    
    [_buttons enumerateObjectsUsingBlock:^(CDSegmentedButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.selected = idx == selectedIndex;
    }];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|(7 << 16) animations:^{
        CDSegmentedButton *button = self.buttons[selectedIndex];
        self.indicatorView.width = button.width - 34;
        self.indicatorView.centerX = button.centerX;
    } completion:nil];
    
    CDSegmentedButton *selectedButton = _buttons[_selectedIndex];
    [_scrollView scrollRectToVisible:selectedButton.frame animated:YES];
}

@end
