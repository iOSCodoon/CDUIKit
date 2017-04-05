//
//  CDTabBarItem.h
//  CDTabBarController
//
//  Created by Jinxiao on 8/30/15.
//  Copyright (c) 2015 codoon. All rights reserved.
//

#import "CDTabBarBadge.h"

@class CDTabBarButton;

@interface CDTabBarItem : UITabBarItem

@property (readwrite, nonatomic, strong) UIImage *iconImage;
@property (readwrite, nonatomic, strong) UIImage *iconHighlightedImage;
@property (readwrite, nonatomic, strong) UIImage *iconSelectedImage;
@property (readwrite, nonatomic, strong) UIColor *titleColor;
@property (readwrite, nonatomic, strong) UIColor *titleHighlightedColor;
@property (readwrite, nonatomic, strong) UIColor *titleSelectedColor;

@property (readwrite, nonatomic, strong) CDTabBarBadge *badge;

+ (NSSet *)keyPaths;

@property (readwrite, nonatomic, weak) CDTabBarButton *button;

@property (readwrite, nonatomic, strong) void (^configuration) (CDTabBarButton *button, NSInteger index);

@end
