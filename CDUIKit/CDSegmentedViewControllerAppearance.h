//
//  CDSegmentedViewControllerAppearance.h
//  CodoonSport
//
//  Created by Jinxiao on 06/04/2017.
//  Copyright © 2017 Codoon. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface CDSegmentedViewControllerAppearance : NSObject

+ (instancetype)sharedInstance;

@property (readwrite, nonatomic, strong) UIColor *segmentedBackgroundColor;

@property (readwrite, nonatomic, strong) UIColor *indicatorColor;
@property (readwrite, nonatomic, assign) CGFloat indicatorWidth;

@property (readwrite, nonatomic, strong) UIColor *splitterColor;

@property (readwrite, nonatomic, strong) UIFont *segmentedTitleFont;
@property (readwrite, nonatomic, strong) UIColor *segmentedTitleColor;
@property (readwrite, nonatomic, strong) UIColor *segmentedTitleHighlightedColor;

@end
