//
//  CDTabBarOverlay.h
//  CDTabBarController
//
//  Created by Jinxiao on 8/30/15.
//  Copyright (c) 2015 codoon. All rights reserved.
//

#import "CDTabBarButton.h"

@class CDTabBarOverlay;
@class CDTabBarItem;

@protocol CDTabBarOverlayDelegate <NSObject>

- (BOOL)tabBarOverlay:(CDTabBarOverlay *)tabBarOverlay shouldSelectTabAtIndex:(NSUInteger)index;
- (void)tabBarOverlay:(CDTabBarOverlay *)tabBarOverlay didSelectTabAtIndex:(NSUInteger)index;

@end

@interface CDTabBarOverlay : UIView

@property (readwrite, nonatomic, weak) id <CDTabBarOverlayDelegate> delegate;
@property (readwrite, nonatomic, strong) CDTabBarItem *selectedItem;
@property (readwrite, nonatomic, assign) NSInteger selectedIndex;
@property (readwrite, nonatomic, strong) NSArray *items;
@property (readonly, nonatomic) NSMutableArray *buttons;
@property (readonly, nonatomic) UIImageView *backgroundImageView;
@property (readonly, nonatomic) UIImageView *sliderImageView;

@property (readwrite, nonatomic, assign) BOOL animatesSlider;
@property (readwrite, nonatomic, assign) UIControlEvents selectionControlEvent;
@property (readwrite, nonatomic, assign) BOOL showsTouchWhenHighlighted;
@property (readwrite, nonatomic, assign) BOOL showsTitle;

@property (readwrite, nonatomic, assign) CGFloat tabImageHeight;
@property (readwrite, nonatomic, assign) CGFloat tabTitleHeight;
@property (readwrite, nonatomic, assign) CGPoint tabTitleOffset;

- (void)setItems:(NSArray *)items animated:(BOOL)animated;

@end
