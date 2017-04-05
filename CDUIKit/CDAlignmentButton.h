//
//  CDAlignmentButton.h
//  CodoonSport
//
//  Created by Jinxiao on 8/19/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CDAlignmentButtonStyle) {
    CDAlignmentButtonStyleImageTop = 0,
    CDAlignmentButtonStyleImageLeft = 1,
    CDAlignmentButtonStyleImageBottom = 2,
    CDAlignmentButtonStyleImageRight = 3
};

@interface CDAlignmentButton : UIButton

@property (readwrite, nonatomic, assign) IBInspectable CGFloat spacing;

@property (readwrite, nonatomic, assign) IBInspectable CDAlignmentButtonStyle style;

@end
