//
//  CDTabBar.m
//  CDTabBarController
//
//  Created by Jinxiao on 8/30/15.
//  Copyright (c) 2015 codoon. All rights reserved.
//

#import "CDTabBar.h"
#import "CDTabBarItem.h"
#import "CDTabBarOverlay.h"

@interface CDTabBar ()

@property (readwrite, nonatomic, strong) CDTabBarOverlay *tabBarOverlay;

@end

@implementation CDTabBar

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
	if(self)
	{
        [self setupTabBarOverlay];
	}
	
	return self;
}

- (void)setupTabBarOverlay
{
    if(!self.tabBarOverlay)
    {
        self.tabBarOverlay = [[CDTabBarOverlay alloc] initWithFrame:self.bounds];
        self.tabBarOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        [self addSubview:self.tabBarOverlay];
    }
}

- (void)setSelectedItem:(CDTabBarItem *)selectedItem
{
	[super setSelectedItem:selectedItem];
	
	[self.tabBarOverlay setSelectedItem:selectedItem];
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    [self setupTabBarOverlay];
    
	[super setItems:items animated:animated];
	[self.tabBarOverlay setItems:items animated:animated];
	
	[self bringSubviewToFront:self.tabBarOverlay];
}

@end
