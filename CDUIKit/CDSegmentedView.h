//
//  CDSegmentedView.h
//  CodoonSport
//
//  Created by Jinxiao on 2019/3/20.
//

#import <UIKit/UIKit.h>

#import "CDSegmentedViewControllerAppearance.h"

@class CDSegmentedButton;
@class CDSegmentedView;

@protocol CDSegmentedViewDelegate <NSObject>

- (void)segmentedView:(CDSegmentedView *)segmentedView didSelectIndex:(NSInteger)index;
- (void)segmentedView:(CDSegmentedView *)segmentedView willLayoutIndicatorView:(UIView *)indicatorView withTargetFrame:(inout CGRect *)targetFrame;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CDSegmentedView : UIView

@property (readwrite, nonatomic, weak) id<CDSegmentedViewDelegate> delegate;

@property (readwrite, nonatomic, strong) NSArray <CDSegmentedButton *> *buttons;

@property (readwrite, nonatomic, assign) NSInteger selectedIndex;

@property (readwrite, nonatomic, assign) CDSegmentedViewControllerSegmentStyle segmentedStyle;

@property (readwrite, nonatomic, assign) CDSegmentedViewControllerIndicatorStyle indicatorStyle;
@property (readwrite, nonatomic, strong) UIColor *indicatorColor;
@property (readwrite, nonatomic, strong) UIImage *indicatorImage;
@property (readwrite, nonatomic, assign) BOOL hidesIndicator;

@property (readwrite, nonatomic, strong) UIColor *separatorColor;
@property (readwrite, nonatomic, assign) BOOL hidesSeparator;
@property (readwrite, nonatomic, assign) CGFloat separatorHeight;

@property (readwrite, nonatomic, assign) UIEdgeInsets edgeInsets;

@end

NS_ASSUME_NONNULL_END
