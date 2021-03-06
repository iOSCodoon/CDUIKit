//
//  CDTabBarController.h
//  CDTabBarController
//
//  Created by Jinxiao on 8/30/15.
//  Copyright (c) 2015 codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

#import "CDTabBarOverlay.h"
#import "CDTabBar.h"
#import "CDTabBarItem.h"

#import "CDTabBarControllerAppearance.h"

@class CDTabBarController;

@interface CDTabBarController : UITabBarController

@property (readonly, nonatomic) CDTabBarOverlay *tabBarOverlay;
@property (readwrite, nonatomic, assign) CGFloat tabBarHeight;
@property (readonly, nonatomic) NSUInteger lastSelectedIndex;
@property (readonly, nonatomic) BOOL programmaticIndexChange;

- (void)commitItemChanges;

+ (CDTabBarControllerAppearance *)appearance;

@end
