//
//  CDSegmentedViewController.m
//  CodoonSport
//
//  Created by Jinxiao on 3/21/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import "CDSegmentedViewController.h"

#include <objc/runtime.h>

static char *UIViewControllerSegmentedViewControllerKey = "UIViewControllerSegmentedViewControllerKey";

@interface CDSegmentedViewController () <UIScrollViewDelegate>
@property (readwrite, nonatomic, strong) UIView *contentView;
@property (readwrite, nonatomic, strong) UIScrollView *segmentedView;
@property (readwrite, nonatomic, strong) UIView *indicatorView;
@property (readwrite, nonatomic, strong) CALayer *splitterLayer;
@property (readwrite, nonatomic, strong) UIScrollView *scrollView;
@property (readwrite, nonatomic, strong) NSArray <UIButton *> *buttons;
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

    _splitterLayer = [CALayer layer];
    _splitterLayer.backgroundColor = [self preferredSplitterColor].CGColor;
    _splitterLayer.hidden = [self prefersSplitterHidden];
    [_segmentedView.layer addSublayer:_splitterLayer];
    
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
    return [self.viewControllers safeObjectAtIndex:_selectedIndex];
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
    _selectedIndex = [self preferredSelectedIndex];

    NSMutableArray *buttons = [NSMutableArray array];

    for(NSInteger index = 0; index < _titles.count; index++) {
        UIButton *button = [self preferredSegmentedButtonAtIndex:index];

        __weak typeof(self) weakSelf = self;
        [button setActionBlock:^(UIControl *control) {
            [weakSelf segmentedButton:(UIButton *)control atIndexDidPressed:index];
        } forControlEvents:UIControlEventTouchUpInside];

        [buttons addObject:button];

        [_segmentedView insertSubview:button belowSubview:_indicatorView];
    }

    _buttons = buttons;

    [self layoutContents];

    [self scrollIndexToVisible:_selectedIndex animated:NO];
}

- (void)layoutContents {
    UIEdgeInsets insets = [self preferredEdgeInsets];

    _contentView.frame = CGRectMake(insets.left, insets.top, self.view.width - insets.left - insets.right, self.view.height - insets.top - insets.bottom);

    if(_buttons.count <= 1) {
        _segmentedView.height = 0;
        _segmentedView.hidden = YES;
    } else {
        _segmentedView.frame = CGRectMake(0, 0, _contentView.width, 38);
        _segmentedView.hidden = NO;

        CGFloat lineWidth = 1.0/[UIScreen mainScreen].scale;
        _splitterLayer.frame = CGRectMake(0, _segmentedView.height - lineWidth, _segmentedView.width, lineWidth);

        if([self preferredSegmentStyle] == CDSegmentedViewControllerSegmentStyleRegular) {
            CGFloat segmentedWidth = _segmentedView.width/_buttons.count;
            for(NSInteger index = 0; index < _buttons.count; index++) {
                UIButton *button = _buttons[index];
                [button sizeToFit];

                button.frame = CGRectMake(index*segmentedWidth + (segmentedWidth - button.width)/2, 0, button.width, _segmentedView.height);
            }
        } else {
            CGFloat offset = 5;
            for(NSInteger index = 0; index < _buttons.count; index++) {
                UIButton *button = _buttons[index];
                [button sizeToFit];

                button.frame = CGRectMake(offset, 0, button.width, _segmentedView.height);
                offset += button.width;
            }
            offset += 5;
            _segmentedView.contentSize = CGSizeMake(offset, _segmentedView.height);
        }

        UIButton *selectedButton = _buttons[_selectedIndex];
        _indicatorView.frame = CGRectMake(selectedButton.left + 17, _segmentedView.height - 2, selectedButton.width - 34, 2);
    }

    _scrollView.frame = CGRectMake(0, _segmentedView.bottom, _contentView.width, _contentView.height - _segmentedView.bottom);

    _scrollView.contentSize = CGSizeMake(_contentView.width*_viewControllers.count, _scrollView.contentSize.height);

    for(NSInteger index = 0; index < _viewControllers.count; index++) {
        _viewControllers[index].view.frame = CGRectMake(index*_scrollView.width, 0, _scrollView.width, _scrollView.height);
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
    
    [self didSelectViewController:[_viewControllers objectAtIndex:index] atIndex:index];

    [_buttons enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
        obj.selected = idx == index;
    }];
}

- (void)segmentedButton:(UIButton *)segmentedButton atIndexDidPressed:(NSInteger)index {
    [_scrollView setContentOffset:CGPointMake(index*_scrollView.width, 0) animated:YES];
}

- (UIViewController *)viewControllerAtIndex:(NSInteger)index willAppearAnimated:(BOOL)animated {
    UIViewController *viewController = [_viewControllers objectAtIndex:index];
    if(!_statuses[index].boolValue) {
        viewController.view.frame = CGRectMake(_scrollView.width*index, 0, _scrollView.width, _scrollView.height);

        [self didSetupViewController:viewController atIndex:index];

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

        [_buttons enumerateObjectsUsingBlock:^(UIButton *_Nonnull obj, NSUInteger idx, BOOL *_Nonnull stop) {
            obj.selected = idx == currentIndex;
        }];

        [UIView animateWithDuration:0.25 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|(7 << 16) animations:^{
            UIButton *button = _buttons[currentIndex];
            _indicatorView.width = button.width - 34;
            _indicatorView.centerX = button.centerX;
        } completion:nil];

        UIButton *selectedButton = _buttons[_selectedIndex];
        [_segmentedView scrollRectToVisible:selectedButton.frame animated:YES];
    }
}

+ (CDSegmentedViewControllerAppearance *)appearance {
    return [CDSegmentedViewControllerAppearance sharedInstance];
}

@end


@implementation CDSegmentedViewController (Overridable)

#pragma mark - Overwritable

- (void)didSetupViewController:(UIViewController *)viewController atIndex:(NSInteger)index {

}

- (void)didSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index {

}

- (UIButton *)preferredSegmentedButtonAtIndex:(NSInteger)index {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.backgroundColor = [UIColor clearColor];
    button.adjustsImageWhenHighlighted = NO;
    button.titleLabel.font = [self preferredSegmentedTitleFont];
    button.contentEdgeInsets = UIEdgeInsetsMake(0, 17, 0, 17);
    [button setTitle:[_titles objectAtIndex:index] forState:UIControlStateNormal];
    [button setTitleColor:[self preferredSegmentedTitleColor] forState:UIControlStateNormal];
    [button setTitleColor:[self preferredSegmentedTitleHighlightedColor] forState:UIControlStateHighlighted|UIControlStateSelected];
    [button setTitleColor:[self preferredSegmentedTitleHighlightedColor] forState:UIControlStateSelected];

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
    return [CDSegmentedViewControllerAppearance sharedInstance].segmentedBackgroundColor;
}

- (UIColor *)preferredSegmentedTitleColor {
    return [CDSegmentedViewControllerAppearance sharedInstance].segmentedTitleColor;
}

- (UIColor *)preferredSegmentedTitleHighlightedColor {
    return [CDSegmentedViewControllerAppearance sharedInstance].segmentedTitleHighlightedColor;
}

- (UIFont *)preferredSegmentedTitleFont {
    return [CDSegmentedViewControllerAppearance sharedInstance].segmentedTitleFont;
}

- (BOOL)prefersIndicatorHidden {
    return NO;
}

- (UIColor *)preferredIndicatorColor {
    return [CDSegmentedViewControllerAppearance sharedInstance].indicatorColor;
}

- (BOOL)prefersSplitterHidden {
    return YES;
}

- (UIColor *)preferredSplitterColor {
    return [CDSegmentedViewControllerAppearance sharedInstance].splitterColor;
}

- (CDSegmentedViewControllerSegmentStyle)preferredSegmentStyle {
    return CDSegmentedViewControllerSegmentStyleRegular;
}

- (UIEdgeInsets)preferredEdgeInsets {
    return UIEdgeInsetsZero;
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
