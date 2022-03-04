//
//  CDSegmentedView.m
//  CodoonSport
//
//  Created by Jinxiao on 2019/3/20.
//

#import "CDSegmentedView.h"

#import "CDSegmentedButton.h"

@interface CDSegmentedView ()
@property (readwrite, nonatomic, strong) UIScrollView *scrollView;
@property (readwrite, nonatomic, strong) UIView *indicatorView;
@property (readwrite, nonatomic, strong) UIImageView *indicatorImageView;
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
    
    _indicatorImageView = [UIImageView new];
    _indicatorImageView.contentMode = UIViewContentModeScaleAspectFit;
    [_scrollView addSubview:_indicatorImageView];
    
    _separatorLayer = [CALayer layer];
    [self.layer addSublayer:_separatorLayer];
    
    return self;
}

- (void)setIndicatorStyle:(CDSegmentedViewControllerIndicatorStyle)indicatorStyle {
    _indicatorStyle = indicatorStyle;
    [self configIndicator];
}

- (void)setIndicatorImage:(UIImage *)indicatorImage {
    _indicatorImage = indicatorImage;
    _indicatorImageView.image = _indicatorImage;
}

- (void)setIndicatorColor:(UIColor *)indicatorColor {
    _indicatorColor = indicatorColor;
    _indicatorView.backgroundColor = _indicatorColor;
}

- (void)setHidesIndicator:(BOOL)hidesIndicator {
    _hidesIndicator = hidesIndicator;
    [self configIndicator];
}

- (void)setSeparatorColor:(UIColor *)separatorColor {
    _separatorColor = separatorColor;
    _separatorLayer.backgroundColor = _separatorColor.CGColor;
}

- (void)setHidesSeparator:(BOOL)hidesSeparator {
    _hidesSeparator = hidesSeparator;
    _separatorLayer.hidden = _hidesSeparator;
}

- (void)setEdgeInsets:(UIEdgeInsets)edgeInsets {
    _edgeInsets = edgeInsets;
    _scrollView.contentInset = edgeInsets;
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
        CGFloat offset = 0;
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
    
    [self layoutIndicatorView];
}

- (void)layoutIndicatorView {
    CDSegmentedButton *selectedButton = _buttons[_selectedIndex];
    CGRect indicatorFrame = selectedButton.frame;
    
    switch (_indicatorStyle) {
        case CDSegmentedViewControllerIndicatorStyleLine: {
            if ([_delegate respondsToSelector:@selector(segmentedView:willLayoutIndicatorView:withTargetFrame:)]) {
                [_delegate segmentedView:self willLayoutIndicatorView:_indicatorView withTargetFrame:&indicatorFrame];
            } else {
                indicatorFrame = CGRectMake(selectedButton.frame.origin.x + 17, self.bounds.size.height - 2, selectedButton.bounds.size.width - 34, 2);
            }
            _indicatorView.frame = indicatorFrame;
            break;
        }
        case CDSegmentedViewControllerIndicatorStyleImage: {
            if ([_delegate respondsToSelector:@selector(segmentedView:willLayoutIndicatorView:withTargetFrame:)]) {
                [_delegate segmentedView:self willLayoutIndicatorView:_indicatorImageView withTargetFrame:&indicatorFrame];
            } else {
                indicatorFrame = CGRectMake(CGRectGetMidX(selectedButton.frame) - 7.5, CGRectGetMaxY(self.bounds) - 9, 15, 5);
            }
            _indicatorImageView.frame = indicatorFrame;
            break;;
        }
        default:
            break;
    }
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
    NSInteger previousIndex = _selectedIndex;
    _selectedIndex = selectedIndex;
    
    [_buttons enumerateObjectsUsingBlock:^(CDSegmentedButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.selected = idx == selectedIndex;
    }];
    
    [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|(7 << 16) animations:^{
        [self layoutIndicatorView];
    } completion:nil];
    
    CGRect visibleFrame = _buttons[_selectedIndex].frame;
    if (previousIndex < selectedIndex) {
        CGRect tailFrame = _buttons[MIN(_buttons.count - 1, _selectedIndex + 2)].frame;
        visibleFrame = CGRectMake(CGRectGetMinX(visibleFrame), 0, MIN(CGRectGetMaxX(tailFrame) - CGRectGetMinX(visibleFrame), _scrollView.width - _edgeInsets.right - _edgeInsets.left), _scrollView.contentSize.height);
    } else if (previousIndex > selectedIndex) {
        CGRect leadFrame = _buttons[MAX(0, _selectedIndex - 2)].frame;
        visibleFrame = CGRectMake(CGRectGetMinX(leadFrame), 0, MIN(CGRectGetMaxX(visibleFrame) - CGRectGetMinX(leadFrame), _scrollView.width - _edgeInsets.right - _edgeInsets.left), _scrollView.contentSize.height);
    }
    [_scrollView scrollRectToVisible:visibleFrame animated:YES];
}

- (void)configIndicator {
    switch (_indicatorStyle) {
        case CDSegmentedViewControllerIndicatorStyleLine: {
            _indicatorImageView.hidden = YES;
            _indicatorView.hidden = _hidesIndicator;
            break;
        }
        case CDSegmentedViewControllerIndicatorStyleImage: {
            _indicatorImageView.hidden = _hidesIndicator;
            _indicatorView.hidden = YES;
            break;;
        }
            
        default:
            break;
    }
}

@end
