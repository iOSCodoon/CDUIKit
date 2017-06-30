//
//  CDSegmentedViewControllerAppearance.m
//  CodoonSport
//
//  Created by Jinxiao on 06/04/2017.
//  Copyright © 2017 Codoon. All rights reserved.
//

#import "CDSegmentedViewControllerAppearance.h"

static CDSegmentedViewControllerAppearance *regularAppearance;
static CDSegmentedViewControllerAppearance *compactAppearance;

@implementation CDSegmentedViewControllerAppearance

+ (instancetype)appearanceForStyle:(CDSegmentedViewControllerSegmentStyle)style {
    switch(style) {
        case CDSegmentedViewControllerSegmentStyleCompact: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                compactAppearance = self.new;
            });
            return compactAppearance;
        }
        case CDSegmentedViewControllerSegmentStyleRegular: {
            static dispatch_once_t once;
            dispatch_once(&once, ^{
                regularAppearance = self.new;
            });
            return regularAppearance;
        }
    }

}

@end
