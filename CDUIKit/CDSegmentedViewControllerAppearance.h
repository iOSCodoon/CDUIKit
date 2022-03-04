//
//  CDSegmentedViewControllerAppearance.h
//  CodoonSport
//
//  Created by Jinxiao on 06/04/2017.
//  Copyright © 2017 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CDSegmentedViewControllerSegmentStyle) {
    CDSegmentedViewControllerSegmentStyleRegular = 0,
    CDSegmentedViewControllerSegmentStyleCompact
};

typedef NS_ENUM(NSUInteger, CDSegmentedViewControllerIndicatorStyle) {
    CDSegmentedViewControllerIndicatorStyleLine = 0,
    CDSegmentedViewControllerIndicatorStyleImage
};



@interface CDSegmentedViewControllerAppearance : NSObject

+ (instancetype)appearanceForStyle:(CDSegmentedViewControllerSegmentStyle)style;

@property (readwrite, nonatomic, strong) UIColor *segmentedBackgroundColor;

@property (readwrite, nonatomic, assign) CDSegmentedViewControllerIndicatorStyle indicatorStyle;
@property (readwrite, nonatomic, strong) UIColor *indicatorColor;
@property (readwrite, nonatomic, strong) UIImage *indicatorImage;

@property (readwrite, nonatomic, strong) UIColor *separatorColor;
@property (readwrite, nonatomic, assign) CGFloat separatorHeight;

@property (readwrite, nonatomic, strong) UIFont *segmentedTitleFont;
@property (readwrite, nonatomic, strong) UIFont *segmentedTitleHighlightedFont;

@property (readwrite, nonatomic, strong) UIColor *segmentedTitleColor;
@property (readwrite, nonatomic, strong) UIColor *segmentedTitleHighlightedColor;

@property (readwrite, nonatomic, assign) CGFloat segmentedButtonSpacing;

@end
