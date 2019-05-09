//
// CDPopoverView.h
// CodoonSport
//
// Created by Jinxiao on 12/10/14.
// Copyright (c) 2014 codoon.com. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, CDPopoverViewAnimationOptions) {
    CDPopoverViewAnimationOptionDownward = 1 << 0,
    CDPopoverViewAnimationOptionUpward = 1 << 1,
    CDPopoverViewAnimationOptionRightward = 1 << 2,
    CDPopoverViewAnimationOptionLeftward = 1 << 3,
    CDPopoverViewAnimationOptionFadeInOut = 1 << 4,
};

typedef NS_ENUM(NSUInteger, CDPopoverViewBackgroundStyle) {
    CDPopoverViewBackgroundStyleNone,
    CDPopoverViewBackgroundStyleDimmed,
    CDPopoverViewBackgroundStyleBlurLight,
    CDPopoverViewBackgroundStyleBlurDark
};

@interface CDPopoverView : UIView

- (instancetype)initWithContainerView:(UIView *)containerView contentView:(UIView *)contentView options:(CDPopoverViewAnimationOptions)options backgroundStyle:(CDPopoverViewBackgroundStyle)backgroundStyle;

- (void)displayAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)displayAnimated:(BOOL)animated duration:(double)duration completion:(void (^)(void))completion;

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)dismissAnimated:(BOOL)animated duration:(double)duration completion:(void (^)(void))completion;

- (void)toggleAnimated:(BOOL)animated completion:(void (^)(void))completion;
- (void)toggleAnimated:(BOOL)animated duration:(double)duration completion:(void (^)(void))completion;

@property (readonly) BOOL toggled;



/*
 举个例子
        /////////////////////
        ///////////////////B/
        ////-------------////
        ///|             |///
        ///|             |///
        ///|             |///
        ///|             |///
        ///|             |///
        ///|      A      |///
        ///|             |///
        ///|             |///
        ///|             |///
        ///|_____________|///
        /////////////////////
        /////////////////////

 - dismissible  为YES时，点击区域B可以消失
 - interactive  为YES时，点击区域A可以触发contentView上的交互操作
 - penetrable   为YES时，将会忽略区域A、B的交互操作，判定优先级低于interactive
 */
@property (readwrite, nonatomic, assign) BOOL dismissible;
@property (readwrite, nonatomic, assign) BOOL interactive;
@property (readwrite, nonatomic, assign) BOOL penetrable;

@property (readwrite, nonatomic, strong) void (^willDisplayBlock) (void);
@property (readwrite, nonatomic, strong) void (^didDisplayBlock) (void);
@property (readwrite, nonatomic, strong) void (^willDismissBlock) (void);
@property (readwrite, nonatomic, strong) void (^didDismissBlock) (void);

@property (readonly) UIView *contentView;

@end


@interface UIView (CDPopover)

@property (readonly) CDPopoverView *popoverView;

@end
