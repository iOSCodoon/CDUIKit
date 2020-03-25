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
#import "CDSegmentedView.h"
#import "CDSegmentedViewControllerAppearance.h"

static char *UIViewControllerSegmentedViewControllerKey = "UIViewControllerSegmentedViewControllerKey";

@interface CDSegmentedViewController () <UIScrollViewDelegate, CDSegmentedViewDelegate>
@property (readwrite, nonatomic, strong) UIView *contentView;
@property (readwrite, nonatomic, strong) CDSegmentedView *segmentedView;
@property (readwrite, nonatomic, strong) UIScrollView *scrollView;
@property (readwrite, nonatomic, strong) NSArray <UIViewController *> *viewControllers;
@property (readwrite, nonatomic, strong) NSArray <NSString *> *titles;

@property (readwrite, nonatomic, assign) NSInteger previousIndex;
@property (readwrite, nonatomic, assign) NSInteger nextIndex;
@end

@implementation CDSegmentedViewController

@synthesize viewControllers = _viewControllers;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;

    _selectedIndex = NSNotFound;
    
    _contentView = [[UIView alloc] init];
    _contentView.backgroundColor = [UIColor clearColor];
    [self.view addSubview:_contentView];
    
    _scrollView = [[UIScrollView alloc] init];
    _scrollView.backgroundColor = [UIColor clearColor];
    _scrollView.delegate = self;
    _scrollView.showsHorizontalScrollIndicator = NO;
    _scrollView.showsVerticalScrollIndicator = NO;
    _scrollView.pagingEnabled = YES;
    _scrollView.bounces = NO;
    _scrollView.scrollsToTop = NO;
    [_contentView addSubview:_scrollView];
    
    if (self.navigationController.interactivePopGestureRecognizer != nil) {
        [_scrollView.panGestureRecognizer requireGestureRecognizerToFail:self.navigationController.interactivePopGestureRecognizer];
    }
    
    if (@available(iOS 11.0, *)) {
        _scrollView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    }
    
    [self reloadContents];
}

- (UIViewController *)selectedViewController {
    return [self.viewControllers objectAtIndex:_selectedIndex];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    
    [self layoutContentsWithSelectedIndex:_selectedIndex];
}

- (void)cleanContents {
    _titles = nil;
    
    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        [obj removeFromParentViewController];
        [obj.view removeFromSuperview];
    }];
    _viewControllers = nil;
    
    [_segmentedView removeFromSuperview];
}

- (void)reloadContents {
    [self cleanContents];
    
    _viewControllers = [self preferredViewControllers];
    if (_viewControllers.count == 0) {
        return;
    }
    
    [_viewControllers enumerateObjectsUsingBlock:^(UIViewController * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        CDWeakableReference *reference = [[CDWeakableReference alloc] initWithObject:self];
        objc_setAssociatedObject(obj, &UIViewControllerSegmentedViewControllerKey, reference, OBJC_ASSOCIATION_RETAIN);
    }];
    
    if ((_viewControllers.count == 1 && [self prefersHidesSegmentedViewForSinglePage]) || [self prefersSegmentedViewHidden]) {
        [_segmentedView removeFromSuperview];
        _segmentedView = nil;
    } else {
        _segmentedView = [[CDSegmentedView alloc] init];
        _segmentedView.backgroundColor = [self preferredSegmentedBackgroundColor];
        _segmentedView.segmentedStyle = [self preferredSegmentStyle];
        _segmentedView.edgeInsets = [self preferredSegmentedViewEdgeInsets];
        _segmentedView.indicatorColor = [self preferredIndicatorColor];
        _segmentedView.hidesIndicator = [self prefersIndicatorHidden];
        _segmentedView.separatorColor = [self preferredSeparatorColor];
        _segmentedView.hidesSeparator = [self prefersSeparatorHidden];
        _segmentedView.delegate = self;
        [_contentView addSubview:_segmentedView];
        
        _titles = [self preferredTitles];

        NSMutableArray *buttons = [NSMutableArray array];
        [_titles enumerateObjectsUsingBlock:^(NSString * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            CDSegmentedButton *button = [self preferredSegmentedButtonAtIndex:idx];
            [buttons addObject:button];
        }];
        _segmentedView.buttons = buttons;
    }
    
    NSInteger preferredSelectedIndex = [self preferredSelectedIndex];
    [self layoutContentsWithSelectedIndex:preferredSelectedIndex];
    [self viewControllerAtIndex:preferredSelectedIndex willAppearAnimated:NO];
    [self scrollIndexToVisible:preferredSelectedIndex animated:NO];
}

- (void)layoutContentsWithSelectedIndex:(NSInteger)selectedIndex {
    UIEdgeInsets insets = [self preferredEdgeInsets];
    
    _contentView.frame = CGRectMake(insets.left, insets.top, self.view.width - insets.left - insets.right, self.view.height - insets.top - insets.bottom);
    
    if (_segmentedView != nil) {
        CGSize segmentedViewSize = [self preferredSegmentedViewSize];
        segmentedViewSize.width = MIN(segmentedViewSize.width, _contentView.width);
        segmentedViewSize.height = MIN(segmentedViewSize.height, _contentView.height);
        _segmentedView.frame = CGRectMake((_contentView.width - segmentedViewSize.width)/2, 0, segmentedViewSize.width, segmentedViewSize.height);
        _segmentedView.selectedIndex = selectedIndex;
        
        [_segmentedView setNeedsLayout];
    }

    _scrollView.frame = CGRectMake(0, _segmentedView.bottom, _contentView.width, _contentView.height - _segmentedView.bottom);
    
    _scrollView.contentSize = CGSizeMake(_contentView.width*_viewControllers.count, _scrollView.contentSize.height);
    
    for (NSInteger index = 0; index < _viewControllers.count; index++) {
        if (_viewControllers[index].segmentedInitialized) {
            _viewControllers[index].view.frame = CGRectMake(index*_scrollView.width, 0, _scrollView.width, _scrollView.height);
        }
    }
    
    [self didLayoutContents];
}

- (void)scrollIndexToVisible:(NSInteger)index animated:(BOOL)animated {
    [_scrollView setContentOffset:CGPointMake(index*_scrollView.width, 0) animated:animated];
    
    if(!animated) {
        [self didEndScrolling];
    }
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index willAppearAnimated:(BOOL)animated {
    UIViewController *viewController = [_viewControllers objectAtIndex:index];
    if(!viewController.segmentedInitialized) {
        viewController.view.frame = CGRectMake(_scrollView.width*index, 0, _scrollView.width, _scrollView.height);
        
        [self didLoadViewController:viewController atIndex:index];
        
        viewController.segmentedInitialized = YES;
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
    }
    
    _segmentedView.selectedIndex = currentIndex;
}

#pragma mark - CDSegmentedViewDelegate

- (void)segmentedView:(CDSegmentedView *)segmentedView didSelectIndex:(NSInteger)index {
    [_scrollView setContentOffset:CGPointMake(index*_scrollView.width, 0) animated:YES];
}

- (void)segmentedView:(CDSegmentedView *)segmentedView willLayoutIndicatorView:(UIView *)indicatorView withTargetFrame:(inout CGRect *)targetFrame {
    [self willLayoutIndicatorView:indicatorView withTargetFrame:targetFrame];
}

@end


@implementation CDSegmentedViewController (Overridable)

- (CDSegmentedViewControllerAppearance *)preferredAppearance {
    return [CDSegmentedViewControllerAppearance appearanceForStyle:[self preferredSegmentStyle]];
}

#pragma mark - Overwritable

- (void)didSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    
}

- (void)didLoadViewController:(UIViewController *)viewController atIndex:(NSInteger)index {
    
}

- (void)didLayoutContents {
    
}

- (NSArray <NSString *> *)preferredTitles {
    return nil;
}

- (NSArray <UIViewController *> *)preferredViewControllers {
    return nil;
}

- (NSUInteger)preferredSelectedIndex {
    return 0;
}

- (UIEdgeInsets)preferredEdgeInsets {
    return UIEdgeInsetsZero;
}

#pragma mark - Segmented View

- (CDSegmentedButton *)preferredSegmentedButtonAtIndex:(NSInteger)index {
    CDSegmentedButton *button = [CDSegmentedButton buttonWithType:UIButtonTypeCustom];
    button.exclusiveTouch = YES;
    button.backgroundColor = [UIColor clearColor];
    button.adjustsImageWhenHighlighted = NO;
    [button setTitle:_titles[index] forState:UIControlStateNormal];
    [button setTitleColor:[self preferredSegmentedTitleColor] forState:UIControlStateNormal];
    [button setTitleColor:[self preferredSegmentedTitleHighlightedColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setTitleColor:[self preferredSegmentedTitleHighlightedColor] forState:UIControlStateSelected];
    [button setFont:[self preferredSegmentedTitleFont] forState:UIControlStateNormal];
    [button setFont:[self preferredSegmentedTitleHighlightedFont] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setFont:[self preferredSegmentedTitleHighlightedFont] forState:UIControlStateSelected];
    return button;
}

- (BOOL)prefersSegmentedViewHidden {
    return NO;
}

- (BOOL)prefersHidesSegmentedViewForSinglePage {
    return YES;
}

- (CGSize)preferredSegmentedViewSize {
    return CGSizeMake(CGFLOAT_MAX, 45);
}

- (UIEdgeInsets)preferredSegmentedViewEdgeInsets {
    return UIEdgeInsetsZero;
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

- (CDSegmentedViewControllerSegmentStyle)preferredSegmentStyle {
    return CDSegmentedViewControllerSegmentStyleRegular;
}

#pragma mark - Indicator

- (BOOL)prefersIndicatorHidden {
    return NO;
}

- (UIColor *)preferredIndicatorColor {
    return [self preferredAppearance].indicatorColor;
}

- (void)willLayoutIndicatorView:(UIView *)indicatorView withTargetFrame:(inout CGRect *)targetFrame {
    
}

#pragma mark - Separator

- (BOOL)prefersSeparatorHidden {
    return YES;
}

- (UIColor *)preferredSeparatorColor {
    return [self preferredAppearance].separatorColor;
}

- (CGFloat)preferredSeparatorHeight {
    return [self preferredAppearance].separatorHeight;
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

- (BOOL)segmentedInitialized {
    return [objc_getAssociatedObject(self, "segmentedInitialized") boolValue];
}

- (void)setSegmentedInitialized:(BOOL)segmentedInitialized {
    objc_setAssociatedObject(self, "segmentedInitialized", @(segmentedInitialized), OBJC_ASSOCIATION_RETAIN);
}

@end

