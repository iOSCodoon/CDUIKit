//
//  CDSegmentedView.h
//  AFNetworking
//
//  Created by Jinxiao on 2019/3/20.
//

#import <UIKit/UIKit.h>

#import "CDSegmentedViewControllerAppearance.h"

@class CDSegmentedButton;
@class CDSegmentedView;

@protocol CDSegmentedViewDelegate <NSObject>

- (void)segmentedView:(CDSegmentedView *)segmentedView didSelectIndex:(NSInteger)index;

@end

NS_ASSUME_NONNULL_BEGIN

@interface CDSegmentedView : UIView

@property (readwrite, nonatomic, weak) id<CDSegmentedViewDelegate> delegate;

@property (readwrite, nonatomic, strong) NSArray <CDSegmentedButton *> *buttons;

@property (readwrite, nonatomic, assign) NSInteger selectedIndex;

@property (readwrite, nonatomic, assign) CDSegmentedViewControllerSegmentStyle segmentedStyle;

@property (readwrite, nonatomic, strong) UIColor *indicatorColor;
@property (readwrite, nonatomic, assign) BOOL hidesIndicator;
@property (readwrite, nonatomic, assign) CGFloat indicatorHeight;
@property (readwrite, nonatomic, assign) CGFloat indicatorMarginBottom;

@property (readwrite, nonatomic, strong) UIColor *separatorColor;
@property (readwrite, nonatomic, assign) BOOL hidesSeparator;
@property (readwrite, nonatomic, assign) CGFloat separatorHeight;

@end

NS_ASSUME_NONNULL_END
