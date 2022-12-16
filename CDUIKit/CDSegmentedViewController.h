//
//  CDSegmentedViewController.h
//  CodoonSport
//
//  Created by Jinxiao on 3/21/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDSegmentedButton;

#import "CDSegmentedViewControllerAppearance.h"

@interface CDSegmentedViewController : UIViewController

@property (readonly) NSInteger selectedIndex;

@property (readonly) UIViewController *selectedViewController;

@property (readonly) UIScrollView *scrollView;
@property (readonly) UIView *segmentedView;

- (void)scrollIndexToVisible:(NSInteger)index animated:(BOOL)animated;

@property (readonly) NSArray <UIViewController *> *viewControllers;

- (void)reloadContents;

- (void)hideRedDot:(NSInteger)index;

@end

@interface CDSegmentedViewController (Overridable)

- (void)didLoadViewController:(UIViewController *)viewController atIndex:(NSInteger)index;
- (void)didSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index;

- (void)didLayoutContents;

- (UIEdgeInsets)preferredEdgeInsets;

- (NSArray <NSNumber *> *)preferredRedDots;
- (NSArray <NSString *> *)preferredTitles;
- (NSArray <UIViewController *> *)preferredViewControllers;

- (NSUInteger)preferredSelectedIndex;


#pragma mark - Segmented View

- (CDSegmentedButton *)preferredSegmentedButtonAtIndex:(NSInteger)index;

- (BOOL)prefersSegmentedViewHidden;
- (BOOL)prefersHidesSegmentedViewForSinglePage;

- (UIEdgeInsets)preferredSegmentedViewEdgeInsets;
- (CGSize)preferredSegmentedViewSize;

- (UIColor *)preferredSegmentedBackgroundColor;
- (UIColor *)preferredSegmentedTitleColor;
- (UIColor *)preferredSegmentedTitleHighlightedColor;
- (UIFont *)preferredSegmentedTitleFont;
- (UIFont *)preferredSegmentedTitleHighlightedFont;

- (CDSegmentedViewControllerSegmentStyle)preferredSegmentStyle;

#pragma mark - Indicator

- (CDSegmentedViewControllerIndicatorStyle)prefersIndicatorStyle;
- (BOOL)prefersIndicatorHidden;
- (UIColor *)preferredIndicatorColor;
- (UIImage *)preferredIndicatorImage;
- (void)willLayoutIndicatorView:(UIView *)indicatorView withTargetFrame:(inout CGRect *)targetFrame;


#pragma mark - Separator

- (BOOL)prefersSeparatorHidden;
- (UIColor *)preferredSeparatorColor;
- (CGFloat)preferredSeparatorHeight;


@end


@interface UIViewController (CDSegmentedViewController)

@property (readonly) CDSegmentedViewController *segmentedViewController;

@property (readwrite, nonatomic, assign) BOOL segmentedInitialized;

@end

