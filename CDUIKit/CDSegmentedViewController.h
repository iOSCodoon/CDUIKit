//
//  CDSegmentedViewController.h
//  CodoonSport
//
//  Created by Jinxiao on 3/21/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CDSegmentedViewControllerAppearance.h"

typedef NS_ENUM(NSUInteger, CDSegmentedViewControllerSegmentStyle) {
    CDSegmentedViewControllerSegmentStyleRegular = 0,
    CDSegmentedViewControllerSegmentStyleCompact
};

@interface CDSegmentedViewController : UIViewController

@property (readonly) NSInteger selectedIndex;

@property (readonly) UIViewController *selectedViewController;

@property (readonly) UIScrollView *scrollView;

- (void)scrollIndexToVisible:(NSInteger)index animated:(BOOL)animated;

- (void)didSetupViewController:(UIViewController *)viewController atIndex:(NSInteger)index;
- (void)didSelectViewController:(UIViewController *)viewController atIndex:(NSInteger)index;

@property (readonly) NSArray <UIViewController *> *viewControllers;


- (NSArray <UIViewController *> *)preferredViewControllers;
- (NSArray <NSString *> *)preferredTitles;
- (NSUInteger)preferredSelectedIndex;

- (UIButton *)preferredSegmentedButtonAtIndex:(NSInteger)index;

- (UIColor *)preferredSegmentedBackgroundColor;
- (UIColor *)preferredSegmentedTitleColor;
- (UIColor *)preferredSegmentedTitleHighlightedColor;
- (UIFont *)preferredSegmentedTitleFont;

- (BOOL)prefersIndicatorHidden;
- (UIColor *)preferredIndicatorColor;

- (BOOL)prefersSplitterHidden;
- (UIColor *)preferredSplitterColor;

- (void)reloadContents;

+ (CDSegmentedViewControllerAppearance *)appearance;

- (CDSegmentedViewControllerSegmentStyle)preferredSegmentStyle;

@end

@interface UIViewController (CDSegmentedViewController)

@property (readonly) CDSegmentedViewController *segmentedViewController;

@end
