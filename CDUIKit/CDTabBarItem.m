//
//  CDTabBarItem.m
//  CDTabBarController
//
//  Created by Jinxiao on 8/30/15.
//  Copyright (c) 2015 codoon. All rights reserved.
//

#import "CDTabBarItem.h"

@implementation CDTabBarItem

+ (NSSet *)keyPaths
{
	return [NSSet setWithObjects:@"title", @"iconImage", @"iconHighlightedImage", @"iconSelectedImage", @"titleColor", @"titleHighlightedColor", @"titleSelectedColor", @"badge", nil];
}

@end
