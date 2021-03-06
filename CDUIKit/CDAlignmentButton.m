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

    CGSize titleSize = CGSizeZero;

    if ([self attributedTitleForState:self.state]) {
        titleSize = [[self attributedTitleForState:self.state] boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine context:NULL].size;
    } else {
        titleSize = [[self titleForState:self.state] boundingRectWithSize:self.bounds.size options:NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingTruncatesLastVisibleLine attributes:@{NSFontAttributeName: self.titleLabel.font} context:NULL].size;
    }
    
    CGFloat titleWidth = titleSize.width;
    CGFloat titleHeight = titleSize.height;

    CGSize imageSize = [self imageForState:self.state].size;
    CGFloat imageWidth = imageSize.width;
    CGFloat imageHeight = imageSize.height;

    CGFloat totalHeight = (imageHeight + titleHeight + _spacing);

    switch(_style) {
        case CDAlignmentButtonStyleImageTop: {
            self.imageEdgeInsets = (UIEdgeInsets) {
                .top    = -(totalHeight - imageHeight),
                .left   = 0,
                .bottom = 0,
                .right  = -titleWidth
            };

            self.titleEdgeInsets  = (UIEdgeInsets) {
                .top    = 0,
                .left   = -imageWidth,
                .bottom = -(totalHeight - titleHeight),
                .right  = 0
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
