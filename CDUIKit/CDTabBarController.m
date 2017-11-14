//
//  CDTabBarController.m
//  CDTabBarController
//
//  Created by Jinxiao on 8/30/15.
//  Copyright (c) 2015 codoon. All rights reserved.
//

#import "CDTabBarController.h"

#define kDefaultTabBarHeight		49.f
#define kTabBarBottomMargin         ([UIScreen mainScreen].bounds.size.height == 812 ? 34 : 0)

@interface CDTabBarController () <CDTabBarOverlayDelegate>

@property (readwrite, nonatomic, strong) CDTabBarOverlay *tabBarOverlay;
@property (readwrite, nonatomic, assign) NSUInteger lastSelectedIndex;
@property (readwrite, nonatomic, assign) BOOL programmaticIndexChange;

@end

@implementation CDTabBarController

- (void)viewDidLoad
{
    [super viewDidLoad];
	
	if(self.tabBarHeight <= 0)
	{
		self.tabBarHeight = kDefaultTabBarHeight + kTabBarBottomMargin;
	}
	
	self.tabBar.frame = CGRectMake(0, self.view.frame.size.height - self.tabBarHeight, self.view.frame.size.width,  self.tabBarHeight);
	
    [self setupTabBarOverlay];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];

    if ([UIScreen mainScreen].bounds.size.height == 812 || [UIScreen mainScreen].bounds.size.width == 812) {
        self.tabBar.frame = CGRectMake(0, self.view.frame.size.height - self.tabBarHeight, self.view.frame.size.width,  self.tabBarHeight);
    }
}

- (void)viewWillAppear:(BOOL)animated
{
	[super viewWillAppear:animated];
	
	[self.tabBar bringSubviewToFront:self.tabBarOverlay];
}

- (void)setupTabBarOverlay
{
    if(!self.tabBarOverlay)
    {
        self.tabBarOverlay = [[CDTabBarOverlay alloc] init];
    }
    
    self.tabBarOverlay.delegate = self;
    self.tabBarOverlay.frame = self.tabBar.bounds;
	
	if(![self.tabBar.subviews containsObject:self.tabBarOverlay])
	{
		[self.tabBar addSubview:self.tabBarOverlay];
		self.tabBarOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
	}
}

- (void)setViewControllers:(NSArray *)viewControllers animated:(BOOL)animated
{
	[super setViewControllers:viewControllers animated:animated];
	
	for(UIView *view in self.view.subviews)
	{
		if(![view isKindOfClass:[UITabBar class]])
		{
			view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - self.tabBarHeight);
			break;
		}
	}
	
    NSInteger selectedIndex = [self selectedIndex];
    if(selectedIndex < 0 || selectedIndex >= [[self.tabBarOverlay items] count])
    {
        selectedIndex = 0;
    }
    
	[self.tabBarOverlay setItems:[self.tabBar items]];
	[self.tabBarOverlay setSelectedIndex:selectedIndex];
	
	[self.tabBar bringSubviewToFront:self.tabBarOverlay];
}

- (void)commitItemChanges
{
    [self.tabBarOverlay setItems:[self.tabBar items]];
    
    [self.tabBar bringSubviewToFront:self.tabBarOverlay];
}

- (void)setSelectedIndex:(NSUInteger)selectedIndex
{
	self.lastSelectedIndex = self.selectedIndex;
	self.programmaticIndexChange = YES;
	
	[super setSelectedIndex:selectedIndex];
	
	[self.tabBarOverlay setSelectedIndex:selectedIndex];
}

- (BOOL)tabBarOverlay:(CDTabBarOverlay *)tabBarOverlay shouldSelectTabAtIndex:(NSUInteger)index
{
    if(self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:shouldSelectViewController:)])
    {
        id viewController = [self.viewControllers objectAtIndex:index];
        return [self.delegate tabBarController:self shouldSelectViewController:viewController];
    }
    return YES;
}

- (void)tabBarOverlay:(CDTabBarOverlay *)tabBarOverlay didSelectTabAtIndex:(NSUInteger)index
{
	if(index < [self.viewControllers count])
	{
		id viewController = [self.viewControllers objectAtIndex:index];
		
		if(self.selectedIndex == index)
		{
			self.lastSelectedIndex = self.selectedIndex;
			
			if([viewController isKindOfClass:[UINavigationController class]])
			{
				[viewController popToRootViewControllerAnimated:YES];
			}
		}
		else
		{
			self.selectedIndex = index;			
		}
		
		self.programmaticIndexChange = NO;
		
		if(self.delegate && [self.delegate respondsToSelector:@selector(tabBarController:didSelectViewController:)])
		{
			[self.delegate tabBarController:self didSelectViewController:viewController];
		}
	}
}

+ (CDTabBarControllerAppearance *)appearance {
    return [CDTabBarControllerAppearance sharedInstance];
}

@end
