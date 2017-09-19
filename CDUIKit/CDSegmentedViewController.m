//
//  CDSegmentedViewController.m
//  CodoonSport
//
//  Created by Jinxiao on 3/21/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import "CDSegmentedViewController.h"

#include <objc/runtime.h>

#import "CDSegmentedButton.h"
#import "CDSegmentedViewControllerAppearance.h"

static char *UIViewControllerSegmentedViewControllerKey = "UIViewControllerSegmentedViewControllerKey";

@interface CDSegmentedViewController () <UIScrollViewDelegate>
@property (readwrite, nonatomic, strong) UIView *contentView;
@property (readwrite, nonatomic, strong) UIScrollView *segmentedView;
@property (readwrite, nonatomic, strong) UIView *indicatorView;
@property (readwrite, nonatomic, strong) CALayer *separatorLayer;
@property (readwrite, nonatomic, strong) UIScrollView *scrollView;
@property (readwrite, nonatomic, strong) NSArray <CDSegmentedButton *> *buttons;
@property (readwrite, nonatomic, strong) NSArray <UIViewController *> *viewControllers;
@property (readwrite, nonatomic, strong) NSArray <NSString *> *titles;

@property (readwrite, nonatomic, assign) NSInteger previousIndex;
@property (readwrite, nonatomic, assign) NSInteger nextIndex;

@property (readwrite, nonatomic, strong) NSMutableArray <NSNumber *> *statuses;
@end

@implementation CDSegmentedViewController

@synthesize viewControllers = _viewControllers;
@synthesize titles = _titles;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    _selectedIndex = NSNotFound;
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    
    _segmentedView = [[UIScrollView alloc] init];
    _segmentedView.showsHorizontalScrollIndicator = NO;
    _segmentedView.showsVerticalScrollIndicator = NO;
    _segmentedView.backgroundColor = [self preferredSegmentedBackgroundColor];
    [_contentView addSubview:_segmentedView];
    
    _indicatorView = [[UIView alloc] init];
    _indicatorView.backgroundColor = [self preferredIndicatorColor];
    _indicatorView.hidden = [self prefersIndicatorHidden];
    [_segmentedView addSubview:_indicatorView];
    
    _separatorLayer = [CALayer layer];
    _separatorLayer.backgroundColor = [self preferredSeparatorColor].CGColor;
    _separatorLayer.hidden = [self prefersSeparatorHidden];
    [_contentView.layer addSublayer:_separatorLayer];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    [_contentView addSubview:_scrollView];
    
    if(self.navigationController.interactivePopGestureRecognizer != nil) {
        [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
    
    [self reloadContents];
}

- (UIViewController *)selectedViewController {
    return [self.viewControllers objectAtIndex:_selectedIndex];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutContents];
}

- (void)cleanContents {
    [_viewControllers makeObjectsPerformSelector:@selector(removeFromParentViewController)];
    
    [_buttons makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [_scrollView.subviews makeObjectsPerformSelector:@selector(removeFromSuperview)];
    
    _buttons = nil;
    _viewControllers = nil;
    _titles = nil;
}

- (void)reloadContents {
    [self cleanContents];
    
    NSArray <UIViewController *> *viewControllers = [self preferredViewControllers];
    NSArray <NSString *> *titles = [self preferredTitles];
    
    if(titles.count == 0 || viewControllers.count == 0) {
        return;
    }
    
    if(titles.count != viewControllers.count) {
        return;
    }
    
    _statuses = [[NSMutableArray alloc] initWithCapacity:titles.count];
    for(NSInteger index = 0; index < titles.count; index++) {
        [_statuses addObject:@(NO)];
    }
    
    _titles = titles;
    [self setViewControllers:viewControllers];
    
    NSMutableArray *buttons = [NSMutableArray array];
    
    for(NSInteger index = 0; index < _titles.count; index++) {
        CDSegmentedButton *button = [self preferredSegmentedButtonAtIndex:index];
        
        __weak typeof(self) weakSelf = self;
        [button setActionBlock:^(UIControl *control) {
            [weakSelf segmentedButton:(CDSegmentedButton *)control atIndexDidPressed:index];
        } forControlEvents:UIControlEventTouchUpInside];
        
        [buttons addObject:button];
        
        [_segmentedView insertSubview:button belowSubview:_indicatorView];
    }
    
    _buttons = buttons;
    
    [self layoutContents];
    
    [self scrollIndexToVisible:[self preferredSelectedIndex] animated:NO];
}

- (void)layoutContents {
    UIEdgeInsets insets = [self preferredEdgeInsets];
    
    _contentView.frame = CGRectMake(insets.left, insets.top, self.view.width - insets.left - insets.right, self.view.height - insets.top - insets.bottom);
    
    CGFloat separatorHeight = [self preferredSeparatorHeight];
    _separatorLayer.frame = CGRectMake(0, _segmentedView.height - separatorHeight, _contentView.width, separatorHeight);
    
    if(_buttons.count <= 1) {
        _segmentedView.height = 0;
        _segmentedView.hidden = YES;
    } else {
        _segmentedView.frame = CGRectMake(0, 0, _contentView.width, 45);
        _segmentedView.hidden = NO;
        
        if([self preferredSegmentStyle] == CDSegmentedViewControllerSegmentStyleRegular) {
            CGFloat segmentedWidth = _segmentedView.width/_buttons.count;
            for(NSInteger index = 0; index < _buttons.count; index++) {
                CDSegmentedButton *button = _buttons[index];
                [button sizeToFit];
                button.frame = CGRectMake(index*segmentedWidth, 0, segmentedWidth, _segmentedView.height);
            }
        } else {
            CGFloat offset = 5;
            for(NSInteger index = 0; index < _buttons.count; index++) {
                CDSegmentedButton *button = _buttons[index];
                [button sizeToFit];
                button.frame = CGRectMake(offset, 0, button.bounds.size.width + 34, _segmentedView.height);
                
                offset += button.bounds.size.width;
            }
            offset += 5;
            _segmentedView.contentSize = CGSizeMake(offset, _segmentedView.height);
        }
        
        CDSegmentedButton *selectedButton = _buttons[_selectedIndex];
        
        if([self preferredSegmentStyle] == CDSegmentedViewControllerSegmentStyleRegular) {
            _indicatorView.frame = CGRectMake(selectedButton.left, _segmentedView.height - 2, selectedButton.width, 2);
        } else {
            _indicatorView.frame = CGRectMake(selectedButton.left + 17, _segmentedView.height - 2, selectedButton.width - 34, 2);
        }
    }
    
    _scrollView.frame = CGRectMake(0, _segmentedView.bottom, _contentView.width, _contentView.height - _segmentedView.bottom);
    
    _scrollView.contentSize = CGSizeMake(_contentView.width*_viewControllers.count, _scrollView.contentSize.height);
    
    for(NSInteger index = 0; index < _viewControllers.count; index++) {
        if(_statuses[index].boolValue) {
            _viewControllers[index].view.frame = CGRectMake(index*_scrollView.width, 0, _scrollView.width, _scrollView.height);
        }
    }
}

- (void)setViewControllers:(NSArray<UIViewController *> *)viewControllers {
    _viewControllers = viewControllers;
    
    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CDWeakableReference *reference = [[CDWeakableReference alloc] initWithObject:self];
        objc_setAssociatedObject(obj, &UIViewControllerSegmentedViewControllerKey, reference, OBJC_ASSOCIATION_RETAIN);
    }];
}

- (void)scrollIndexToVisible:(NSInteger)index animated:(BOOL)animated {
    [self viewControllerAtIndex:index willAppearAnimated:NO];
    
    [_scrollView setContentOffset:CGPointMake(index*_scrollView.width, 0) animated:animated];
    
    if(!animated) {
        [self didEndScrolling];
    }
}

- (void)segmentedButton:(CDSegmentedButton *)segmentedButton atIndexDidPressed:(NSInteger)index {
    [_scrollView setContentOffset:CGPointMake(index*_scrollView.width, 0) animated:YES];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index willAppearAnimated:(BOOL)animated {
    UIViewController *viewController = [_viewControllers objectAtIndex:index];
    if(!_statuses[index].boolValue) {
        viewController.view.frame = CGRectMake(_scrollView.width*index, 0, _scrollView.width, _scrollView.height);
        _statuses[index] = @(YES);
    }
    
    [_scrollView addSubview:viewController.view];
    
    [self addChildViewController:viewController];
    [viewController didMoveToParentViewController:self];
    
    return viewController;
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index willDisappearAnimated:(BOOL)animated {
    UIViewController *viewController = [_viewControllers objectAtIndex:index];
    
    [viewController.view removeFromSuperview];
    
    [viewController willMoveToParentViewController:nil];
    [viewController removeFromParentViewController];
    
    return viewController;
}

#pragma - UIScrollView Delegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    NSInteger previousIndex = (NSInteger)(scrollView.contentOffset.x + 1)/scrollView.width;
    NSInteger nextIndex = (NSInteger)(scrollView.width + scrollView.contentOffset.x - 1)/scrollView.width;
    
    if(_previousIndex != previousIndex) {
        if(previousIndex < _previousIndex) {
            [self viewControllerAtIndex:previousIndex willAppearAnimated:NO];
        } else {
            [self viewControllerAtIndex:_previousIndex willDisappearAnimated:NO];
        }
        
        _previousIndex = previousIndex;
    }
    
    if(_nextIndex != nextIndex) {
        if(nextIndex > _nextIndex) {
            [self viewControllerAtIndex:nextIndex willAppearAnimated:NO];
        } else {
            [self viewControllerAtIndex:_nextIndex willDisappearAnimated:NO];
        }
        
        _nextIndex = nextIndex;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self didEndScrolling];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if(!decelerate) {
        [self didEndScrolling];
    }
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self didEndScrolling];
}

- (void)didEndScrolling {
    NSInteger currentIndex = (NSInteger)(_scrollView.width/2 + _scrollView.contentOffset.x)/_scrollView.width;
    
    if(_selectedIndex != currentIndex) {
        _selectedIndex = currentIndex;
        
        [self didSelectViewController:[_viewControllers objectAtIndex:currentIndex] atIndex:currentIndex];
        
        [_buttons enumerateObjectsUsingBlock:^(CDSegmentedButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            obj.selected = idx == currentIndex;
        }];
        
        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|(7 << 16) animations:^{
            CDSegmentedButton *button = _buttons[currentIndex];
            _indicatorView.centerX = button.centerX;
        } completion:nil];
        
        CDSegmentedButton *selectedButton = _buttons[_selectedIndex];
        [_segmentedView scrollRectToVisible:selectedButton.frame animated:YES];
    }
}

@end


@implementation CDSegmentedViewController (Overridable)

#pragma mark - Overwritable

- (void)didSetupViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    
}

- (void)didSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    
}

- (CDSegmentedButton *)preferredSegmentedButtonAtIndex:(NSInteger)index {
    CDSegmentedButton *button = [CDSegmentedButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    button.backgroundColor = [UIColor clearColor];
    button.adjustsImageWhenHighlighted = NO;
    [button setTitle:[_titles objectAtIndex:index] forState:UIControlStateNormal];
    [button setTitleColor:[self preferredSegmentedTitleColor] forState:UIControlStateNormal];
    [button setTitleColor:[self preferredSegmentedTitleHighlightedColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setTitleColor:[self preferredSegmentedTitleHighlightedColor] forState:UIControlStateSelected];
    [button setFont:[self preferredSegmentedTitleFont] forState:UIControlStateNormal];
    [button setFont:[self preferredSegmentedTitleHighlightedFont] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setFont:[self preferredSegmentedTitleHighlightedFont] forState:UIControlStateSelected];
    
    return button;
}

- (NSArray <NSString *> *)preferredTitles {
    return nil;
}

- (NSUInteger)preferredSelectedIndex
{
    return 0;
}

- (NSArray <UIViewController *> *)preferredViewControllers {
    return nil;
}

- (UIColor *)preferredSegmentedBackgroundColor {
    return [self preferredAppearance].segmentedBackgroundColor;
}

- (UIColor *)preferredSegmentedTitleColor {
    return [self preferredAppearance].segmentedTitleColor;
}

- (UIColor *)preferredSegmentedTitleHighlightedColor {
    return [self preferredAppearance].segmentedTitleHighlightedColor;
}

- (UIFont *)preferredSegmentedTitleFont {
    return [self preferredAppearance].segmentedTitleFont;
}

- (UIFont *)preferredSegmentedTitleHighlightedFont {
    return [self preferredAppearance].segmentedTitleHighlightedFont;
}

- (BOOL)prefersIndicatorHidden {
    return NO;
}

- (UIColor *)preferredIndicatorColor {
    return [self preferredAppearance].indicatorColor;
}

- (BOOL)prefersSeparatorHidden {
    return YES;
}

- (UIColor *)preferredSeparatorColor {
    return [self preferredAppearance].separatorColor;
}

- (CGFloat)preferredSeparatorHeight {
    return [self preferredAppearance].separatorHeight;
}

- (CDSegmentedViewControllerSegmentStyle)preferredSegmentStyle {
    return CDSegmentedViewControllerSegmentStyleRegular;
}

- (UIEdgeInsets)preferredEdgeInsets {
    return UIEdgeInsetsZero;
}

- (CDSegmentedViewControllerAppearance *)preferredAppearance {
    return [CDSegmentedViewControllerAppearance appearanceForStyle:[self preferredSegmentStyle]];
}

@end

@implementation UIViewController (CDSegmentedViewController)

- (CDSegmentedViewController *)segmentedViewController {
    CDWeakableReference *reference = objc_getAssociatedObject(self, &UIViewControllerSegmentedViewControllerKey);
    if(reference == nil) {
        return nil;
    }
    
    if([reference.object isKindOfClass:[CDSegmentedViewController class]]) {
        return reference.object;
    }
    
    return nil;
}

@end

