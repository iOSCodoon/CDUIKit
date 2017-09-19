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

- (void)scrollIndexToVisible:(NSInteger)index animated:(BOOL)animated;

@property (readonly) NSArray <UIViewController *> *viewControllers;

- (void)reloadContents;

@end

@interface CDSegmentedViewController (Overridable)

- (void)didSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index;

- (NSArray <UIViewController *> *)preferredViewControllers;
- (NSArray <NSString *> *)preferredTitles;
- (NSUInteger)preferredSelectedIndex;

- (CDSegmentedButton *)preferredSegmentedButtonAtIndex:(NSInteger)index;

- (UIColor *)preferredSegmentedBackgroundColor;
- (UIColor *)preferredSegmentedTitleColor;
- (UIColor *)preferredSegmentedTitleHighlightedColor;
- (UIFont *)preferredSegmentedTitleFont;
- (UIFont *)preferredSegmentedTitleHighlightedFont;

- (BOOL)prefersIndicatorHidden;
- (UIColor *)preferredIndicatorColor;

- (BOOL)prefersSeparatorHidden;
- (UIColor *)preferredSeparatorColor;
- (CGFloat)preferredSeparatorHeight;

- (CDSegmentedViewControllerSegmentStyle)preferredSegmentStyle;

- (UIEdgeInsets)preferredEdgeInsets;

@end


@interface UIViewController (CDSegmentedViewController)

@property (readonly) CDSegmentedViewController *segmentedViewController;

@end
