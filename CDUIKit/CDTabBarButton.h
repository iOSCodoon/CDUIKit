//
//  CDTabBarButton.h
//  CDTabBarController
//
//  Created by Jinxiao on 8/30/15.
//  Copyright (c) 2015 codoon. All rights reserved.
//

@class CDTabBarItem;

@interface CDTabBarButton : UIButton

@property (readonly, nonatomic) CDTabBarItem *item;
@property (readwrite, nonatomic, assign) BOOL showsTitle;
@property (readwrite, nonatomic, assign) CGFloat imageHeight;
@property (readwrite, nonatomic, assign) CGFloat titleHeight;
@property (readwrite, nonatomic, assign) CGPoint titleOffset;

- (id)initWithItem:(CDTabBarItem *)item;

- (void)configureButton;

@property (readwrite, nonatomic, strong) UIView *badgeView;

@end
