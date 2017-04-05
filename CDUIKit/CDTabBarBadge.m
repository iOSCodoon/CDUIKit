//
//  CDTabBarBadge.m
//  CodoonSport
//
//  Created by Jinxiao on 9/8/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import "CDTabBarBadge.h"

@interface CDTabBarBadge ()
@property (readwrite, nonatomic, assign) CDTabBarBadgeType type;
@property (readwrite, nonatomic, strong) id value;
@end

@implementation CDTabBarBadge

+ (instancetype)dotBadge
{
    CDTabBarBadge *badge = [[CDTabBarBadge alloc] init];
    badge.type = CDTabBarBadgeTypeDot;
    return badge;
}

+ (instancetype)stringBadgeWithString:(NSString *)string
{
    if(![string isKindOfClass:[NSString class]])
    {
        return [self dotBadge];
    }
    
    CDTabBarBadge *badge = [[CDTabBarBadge alloc] init];
    badge.type = CDTabBarBadgeTypeString;
    badge.value = string;
    return badge;
}

+ (instancetype)iconBadgeWithIcon:(UIImage *)icon
{
    if(![icon isKindOfClass:[UIImage class]])
    {
        return [self dotBadge];
    }
    
    CDTabBarBadge *badge = [[CDTabBarBadge alloc] init];
    badge.type = CDTabBarBadgeTypeIcon;
    badge.value = icon;
    return badge;
}

@end
