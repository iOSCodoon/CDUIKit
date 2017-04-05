//
//  CDAlignmentButton.m
//  CodoonSport
//
//  Created by Jinxiao on 8/19/16.
//  Copyright © 2016 Codoon. All rights reserved.
//

#import "CDAlignmentButton.h"

@implementation CDAlignmentButton

- (void)layoutSubviews {
    [super layoutSubviews];

    CGFloat titleWidth = CGRectGetWidth(self.titleLabel.bounds);
    CGFloat titleHeight = CGRectGetHeight(self.titleLabel.bounds);

    CGFloat imageWidth = CGRectGetWidth(self.imageView.bounds);
    CGFloat imageHeight = CGRectGetHeight(self.imageView.bounds);

    switch(_style) {
        case CDAlignmentButtonStyleImageTop: {
            self.titleEdgeInsets = (UIEdgeInsets) {
                .top = (imageHeight + _spacing)/2,
                .left = -imageWidth/2,
                .bottom = -(imageHeight + _spacing)/2,
                .right = imageWidth/2
            };

            self.imageEdgeInsets = (UIEdgeInsets) {
                .top = -(titleHeight + _spacing)/2,
                .left = titleWidth/2,
                .bottom = (titleHeight + _spacing)/2,
                .right = -titleWidth/2
            };

            break;
        }

        case CDAlignmentButtonStyleImageLeft: {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, _spacing/2, 0, -_spacing/2);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, -_spacing/2, 0, _spacing/2);

            break;
        }

        case CDAlignmentButtonStyleImageBottom: {

            self.titleEdgeInsets = (UIEdgeInsets) {
                .top    = -(imageHeight + _spacing)/2,
                .left   = -titleWidth/2,
                .bottom = (imageHeight + _spacing)/2,
                .right  = titleWidth/2
            };

            self.imageEdgeInsets = (UIEdgeInsets) {
                .top    = (titleHeight + _spacing)/2,
                .left   = imageWidth/2,
                .bottom = -(titleHeight + _spacing)/2,
                .right  = -imageWidth/2,
            };

            break;
        }

        case CDAlignmentButtonStyleImageRight: {
            self.titleEdgeInsets = UIEdgeInsetsMake(0, -(imageWidth + _spacing/2), 0, imageWidth + _spacing/2);
            self.imageEdgeInsets = UIEdgeInsetsMake(0, titleWidth + _spacing/2, 0, -(titleWidth + _spacing/2));

            break;
        }

        default:
            break;
    }
}

@end
