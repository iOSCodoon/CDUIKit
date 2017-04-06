//
//  CDTabBarControllerAppearance.h
//  CodoonSport
//
//  Created by Jinxiao on 06/04/2017.
//  Copyright © 2017 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDTabBarControllerAppearance : NSObject

+ (instancetype)sharedInstance;

@property (readwrite, nonatomic, strong) UIColor *badgeColor;

@end
