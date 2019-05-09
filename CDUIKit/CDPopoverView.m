//
// CDPopoverView.m
// CodoonSport
//
// Created by Jinxiao on 12/10/14.
// Copyright (c) 2014 codoon.com. All rights reserved.
//

#import "CDPopoverView.h"

#import <objc/runtime.h>

static UIViewAnimationOptions curve = (7 << 16);
static char *UIViewPopoverViewKey = "UIViewPopoverViewKey";

@interface CDPopoverView ()
@property (readwrite, nonatomic, assign) BOOL animating;
@property (readwrite, nonatomic, assign) BOOL toggled;
@property (readwrite, nonatomic, assign) CDPopoverViewAnimationOptions options;
@property (readwrite, nonatomic, assign) CDPopoverViewBackgroundStyle backgroundStyle;
@property (readwrite, nonatomic, assign) CGRect targetRect;
@property (readwrite, nonatomic, assign) CGRect sourceRect;
@property (readwrite, nonatomic, weak) UIView *containerView;
@property (readwrite, nonatomic, strong) UIView *contentView;
@property (readwrite, nonatomic, strong) UIView *backgroundView;
@property (readwrite, nonatomic, strong) UIControl *backControl;
@end

@implementation CDPopoverView

@synthesize toggled = _toggled;

- (instancetype)initWithContainerView:(UIView *)containerView contentView:(UIView *)contentView options:(CDPopoverViewAnimationOptions)options backgroundStyle:(CDPopoverViewBackgroundStyle)backgroundStyle {
    self = [super initWithFrame:containerView.bounds];

    if(self != nil) {
        self.layer.allowsGroupOpacity = NO;

        CDWeakableReference *reference = [[CDWeakableReference alloc] initWithObject:self];
        objc_setAssociatedObject(contentView, &UIViewPopoverViewKey, reference, OBJC_ASSOCIATION_RETAIN);
        
        _options = options;
        _backgroundStyle = backgroundStyle;

        _containerView = containerView;

        switch(backgroundStyle) {
            case CDPopoverViewBackgroundStyleDimmed: {
                _backgroundView = [[UIView alloc] init];
                _backgroundView.frame = self.bounds;
                _backgroundView.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.5];
                _backgroundView.alpha = 0;
                [self addSubview:_backgroundView];
                break;
            }

            case CDPopoverViewBackgroundStyleBlurLight: {
                _backgroundView = [[UIVisualEffectView alloc] init];
                ((UIVisualEffectView *)_backgroundView).effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
                _backgroundView.alpha = 0;
                _backgroundView.frame = self.bounds;
                [self addSubview:_backgroundView];

                break;
            }

            case CDPopoverViewBackgroundStyleBlurDark: {
                _backgroundView = [[UIVisualEffectView alloc] init];
                ((UIVisualEffectView *)_backgroundView).effect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
                _backgroundView.alpha = 0;
                _backgroundView.frame = self.bounds;
                [self addSubview:_backgroundView];

                break;
            }

            default: break;
        }

        _backControl = [[UIControl alloc] init];
        _backControl.frame = self.bounds;
        _backControl.backgroundColor = [UIColor clearColor];
        [_backControl addTarget:self action:@selector(backControlDidTouched) forControlEvents:UIControlEventTouchDown];
        [self addSubview:_backControl];

        _contentView = contentView;
        [self addSubview:_contentView];

        _targetRect = _contentView.frame;

        if(_options&CDPopoverViewAnimationOptionDownward) {
            _contentView.bottom = 0.f;
        } else if(_options&CDPopoverViewAnimationOptionUpward) {
            _contentView.top = self.height;
        } else if(_options&CDPopoverViewAnimationOptionLeftward) {
            _contentView.left = self.width;
        } else if(_options&CDPopoverViewAnimationOptionRightward) {
            _contentView.right = 0.f;
        }

        _sourceRect = _contentView.frame;

        self.interactive = YES;
        self.dismissible = YES;
        self.penetrable = NO;
    }

    return self;
}

- (UIView *)hitTest:(CGPoint)point withEvent:(UIEvent *)event {
    CGPoint pointInContent = [self convertPoint:point toView:_contentView];

    if(CGRectContainsPoint(_contentView.bounds, pointInContent)) {
        if(_interactive) {
            return [super hitTest:point withEvent:event];
        } else if(!_penetrable) {
            return [super hitTest:point withEvent:event];
        } else {
            return nil;
        }
    } else {
        if(!_penetrable) {
            return [super hitTest:point withEvent:event];
        } else {
            return nil;
        }
    }
}

- (void)setDismissible:(BOOL)dismissible {
    _dismissible = dismissible;
    _backControl.hidden = !dismissible;
}

- (void)backControlDidTouched {
    [self dismissAnimated:YES completion:nil];
}

- (void)toggleAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self toggleAnimated:animated duration:animated ? 0.25 : 0 completion:completion];
}

- (void)toggleAnimated:(BOOL)animated duration:(double)duration completion:(void (^)(void))completion {
    if(_toggled) {
        [self dismissAnimated:animated duration:duration completion:completion];
    } else {
        [self displayAnimated:animated duration:duration completion:completion];
    }
}

- (void)displayAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self displayAnimated:animated duration:animated ? 0.25 : 0 completion:completion]
}

- (void)displayAnimated:(BOOL)animated duration:(double)duration completion:(void (^)(void))completion {
    if(_animating) {
        return;
    }

    _animating = YES;

    if(_options&CDPopoverViewAnimationOptionFadeInOut) {
        _contentView.alpha = 0;
    }

    _contentView.frame = _sourceRect;

    [_containerView addSubview:self];

    if(_willDisplayBlock != nil) {
        _willDisplayBlock();
    }

    if (animated) {
        [UIView animateWithDuration:animated ? 0.25 : 0 delay:0 options:UIViewAnimationOptionBeginFromCurrentState|curve animations:^{
            if(_options&CDPopoverViewAnimationOptionFadeInOut) {
                _contentView.alpha = 1;
            }
            
            _contentView.frame = _targetRect;
            _backgroundView.alpha = 1;
        } completion:^(BOOL finished) {
            _toggled = YES;
            _animating = NO;
            
            if(completion) {
                completion();
            }
            
            if(_didDisplayBlock != nil) {
                _didDisplayBlock();
            }
        }];
    } else {
        if(_options&CDPopoverViewAnimationOptionFadeInOut) {
            _contentView.alpha = 1;
        }
        
        _contentView.frame = _targetRect;
        _backgroundView.alpha = 1;
        
        _toggled = YES;
        _animating = NO;
        
        if(completion) {
            completion();
        }
        
        if(_didDisplayBlock != nil) {
            _didDisplayBlock();
        }
    }
}

- (void)dismissAnimated:(BOOL)animated completion:(void (^)(void))completion {
    [self dismissAnimated:animated duration:animated ? 0.25 : 0 completion:completion]
}

- (void)dismissAnimated:(BOOL)animated duration:(double)duration completion:(void (^)(void))completion {
    if(_animating) {
        return;
    }

    _animating = YES;

    if(_willDismissBlock != nil) {
        _willDismissBlock();
    }

    if (animated) {
        [UIView animateWithDuration:duration delay:0 options:UIViewAnimationOptionBeginFromCurrentState|curve animations:^{
            if(_options&CDPopoverViewAnimationOptionFadeInOut) {
                _contentView.alpha = 0;
            }
            
            _contentView.frame = _sourceRect;
            _backgroundView.alpha = 0;
        } completion:^(BOOL finished) {
            _toggled = NO;
            _animating = NO;
            
            [self removeFromSuperview];
            
            if(completion) {
                completion();
            }
            
            if(_didDismissBlock) {
                _didDismissBlock();
            }
        }];
    } else {
        if(_options&CDPopoverViewAnimationOptionFadeInOut) {
            _contentView.alpha = 0;
        }
        
        _contentView.frame = _sourceRect;
        _backgroundView.alpha = 0;
        
        _toggled = NO;
        _animating = NO;
        
        [self removeFromSuperview];
        
        if(completion) {
            completion();
        }
        
        if(_didDismissBlock) {
            _didDismissBlock();
        }
    }
}

@end

@implementation UIView (CDPopover)

- (CDPopoverView *)popoverView {
    CDWeakableReference *reference = objc_getAssociatedObject(self, &UIViewPopoverViewKey);
    if(reference == nil) {
        return nil;
    }

    if([reference.object isKindOfClass:[CDPopoverView class]] && ((CDPopoverView *)reference.object).contentView == self) {
        return reference.object;
    }

    return nil;
}

@end
