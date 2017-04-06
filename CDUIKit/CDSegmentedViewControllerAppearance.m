//
//  CDSegmentedViewControllerAppearance.m
//  CodoonSport
//
//  Created by Jinxiao on 06/04/2017.
//  Copyright © 2017 Codoon. All rights reserved.
//

#import "CDSegmentedViewControllerAppearance.h"

@implementation CDSegmentedViewControllerAppearance

+ (instancetype)sharedInstance {
    static id instance = nil;
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        instance = self.new;
    });
    return instance;
}

@end
