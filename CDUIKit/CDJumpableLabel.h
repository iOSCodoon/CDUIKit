//
//  CDJumpableLabel.h
//  CodoonSport
//
//  Created by Jinxiao on 11/9/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface CDJumpableLabel : UILabel

- (void)jumpFrom:(double)from to:(double)to duration:(double)duration;
- (void)cancelJump;

@property (readwrite, nonatomic, strong) NSString * (^formatterBlock) (double value);

@property (readwrite, nonatomic, assign) double value;


@end
