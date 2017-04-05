//
//  CDZoomablePickerView.h
//  CodoonSport
//
//  Created by Jinxiao on 4/8/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import <UIKit/UIKit.h>

@class CDZoomablePickerView;

@protocol CDZoomablePickerViewDelegate <NSObject>

@required
- (NSUInteger)numberOfRowsInPickerView:(CDZoomablePickerView *)pickerView;
- (NSString *)titleForCellAtRow:(NSUInteger)row inPickerView:(CDZoomablePickerView *)pickerView;

@optional
- (UIColor *)colorOfTitleForCellAtRow:(NSUInteger)row inPickerView:(CDZoomablePickerView *)pickerView progress:(CGFloat)progress;
- (UIFont *)fontOfTitleForCellAtRow:(NSUInteger)row inPickerView:(CDZoomablePickerView *)pickerView progress:(CGFloat)progress;

- (void)pickerView:(CDZoomablePickerView *)pickerView didSelectRow:(NSUInteger)row;

@end


@interface CDZoomablePickerView : UIView

@property (readonly) UITableView *tableView;

@property (readwrite, nonatomic, weak) id<CDZoomablePickerViewDelegate> delegate;

- (void)layoutVisibleCells;

- (void)scrollsToRowAtIndex:(NSInteger)index animated:(BOOL)animated;

@end
