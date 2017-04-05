//
//  CDTabBarBadge.h
//  CodoonSport
//
//  Created by Jinxiao on 9/8/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, CDTabBarBadgeType) {
    CDTabBarBadgeTypeDot,
    CDTabBarBadgeTypeString,
    CDTabBarBadgeTypeIcon,
};

@interface CDTabBarBadge : NSObject

+ (instancetype)dotBadge;
+ (instancetype)stringBadgeWithString:(NSString *)string;
+ (instancetype)iconBadgeWithIcon:(UIImage *)icon;

@property (readonly) id value;

@property (readonly) CDTabBarBadgeType type;

@end
