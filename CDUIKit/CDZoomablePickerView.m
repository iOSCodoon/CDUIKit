//
//  CDZoomablePickerView.m
//  CodoonSport
//
//  Created by Jinxiao on 4/8/15.
//  Copyright (c) 2015 Codoon. All rights reserved.
//

#import "CDZoomablePickerView.h"

@interface CDZoomablePickerCell : UITableViewCell
@property (readwrite, nonatomic, strong) UIImageView *separatorView;
@property (readwrite, nonatomic, strong) UILabel *titleLabel;
@end

@implementation CDZoomablePickerCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if(self)
    {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor clearColor];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
        [self.contentView addSubview:_titleLabel];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    _titleLabel.frame = self.contentView.bounds;
}

@end


@interface CDZoomablePickerView() <UITableViewDataSource, UITableViewDelegate>
@property (readwrite, nonatomic, strong) UITableView *tableView;
@property (readwrite, nonatomic, assign) CGFloat rowHeight;
@property (readwrite, nonatomic, assign) CGFloat numberOfRows;
@end

@implementation CDZoomablePickerView

- (void)dealloc
{
    _tableView.delegate = nil;
    _tableView.dataSource = nil;
}

- (void)awakeFromNib
{
    [super awakeFromNib];
    
    self.backgroundColor = [UIColor clearColor];
    
    _tableView = [[UITableView alloc] initWithFrame:self.bounds style:UITableViewStylePlain];
    _tableView.backgroundColor = [UIColor clearColor];
    _tableView.delegate = self;
    _tableView.dataSource = self;
    _tableView.showsVerticalScrollIndicator = NO;
    _tableView.showsHorizontalScrollIndicator = NO;
    _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    _tableView.tableFooterView = [[UIView alloc] init];
    [self addSubview:_tableView];
}

- (void)layoutSubviews
{
    [super layoutSubviews];

    _tableView.frame = self.bounds;
}

#pragma mark - UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if([_delegate respondsToSelector:@selector(numberOfRowsInPickerView:)])
    {
        _numberOfRows = [_delegate numberOfRowsInPickerView:self];
    }
    
    _numberOfRows += 2;
    _rowHeight = _tableView.height/MIN(3, _numberOfRows);
    
    return _numberOfRows;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return _rowHeight;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    CDZoomablePickerCell *cell = [tableView dequeueReusableCellWithIdentifier:@"cell"];
    if(cell == nil)
    {
        cell = [[CDZoomablePickerCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"cell"];
        cell.backgroundColor = [UIColor clearColor];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *title = @"";
    if(indexPath.row > 0 && indexPath.row < _numberOfRows - 1 && [_delegate respondsToSelector:@selector(titleForCellAtRow:inPickerView:)])
    {
        title = [_delegate titleForCellAtRow:(indexPath.row - 1) inPickerView:self];
    }
    ((CDZoomablePickerCell *)cell).titleLabel.text = title;
    ((CDZoomablePickerCell *)cell).titleLabel.textColor = [UIColor blackColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if(indexPath.row == 0 || indexPath.row == _numberOfRows - 1)
    {
        return;
    }
    
    [self scrollsToRowAtIndex:indexPath.row - 1 animated:YES];
}

#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    if(!decelerate)
    {
        CGFloat offset = scrollView.contentOffset.y;
        NSInteger nearestIndex = offset/_rowHeight;
        if(offset - nearestIndex*_rowHeight > _rowHeight/2)
        {
            nearestIndex++;
        }
        
        [self scrollsToRowAtIndex:nearestIndex animated:YES];

        [self scrollsDidFinish];
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView
{
    CGFloat offset = scrollView.contentOffset.y;
    NSInteger nearestIndex = offset/_rowHeight;
    if(offset - nearestIndex*_rowHeight > _rowHeight/2)
    {
        nearestIndex++;
    }
    
    [self scrollsToRowAtIndex:nearestIndex animated:YES];

    [self scrollsDidFinish];
}

- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self scrollsDidFinish];
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self layoutVisibleCells];
}

- (void)scrollViewWillEndDragging:(UIScrollView *)scrollView withVelocity:(CGPoint)velocity targetContentOffset:(inout CGPoint *)targetContentOffset
{
    CGFloat offset = ((CGPoint)*targetContentOffset).y;
    NSInteger nearestIndex = offset/_rowHeight;
    if(offset - nearestIndex*_rowHeight > _rowHeight/2)
    {
        nearestIndex++;
    }
    
    CGPoint contentOffset = CGPointMake(((CGPoint)*targetContentOffset).x, nearestIndex*_rowHeight);
    *targetContentOffset = contentOffset;
}

- (void)scrollsToRowAtIndex:(NSInteger)index animated:(BOOL)animated
{
    if(index < 0)
    {
        index = 0;
    }
    if(index > _numberOfRows - 1)
    {
        index = _numberOfRows - 1;
    }
    
    [_tableView setContentOffset:CGPointMake(_tableView.contentOffset.x, index*_rowHeight) animated:animated];
}

- (void)scrollsDidFinish {
    CGFloat offset = _tableView.contentOffset.y;
    NSInteger nearestIndex = offset/_rowHeight;
    if(offset - nearestIndex*_rowHeight > _rowHeight/2)
    {
        nearestIndex++;
    }

    if([_delegate respondsToSelector:@selector(pickerView:didSelectRow:)])
    {
        [_delegate pickerView:self didSelectRow:nearestIndex];
    }
}

- (void)layoutVisibleCells
{
    NSArray *cells = [_tableView visibleCells];
    
    for(CDZoomablePickerCell *cell in cells)
    {
        NSIndexPath *indexPath = [_tableView indexPathForCell:cell];
        
        CGFloat cellOffset = indexPath.row*_rowHeight;
        CGFloat contentOffset = _tableView.contentOffset.y;
        CGFloat offset = cellOffset - contentOffset;
        
        if((offset > 0.f && offset <= _rowHeight) || (offset > _rowHeight && offset <= _rowHeight*2))
        {
            CGFloat progress = ABS((offset - _rowHeight)/_rowHeight);
            [self updateCell:cell atRow:indexPath.row withProgress:(1.f - progress)];
        }
        else
        {
            [self updateCell:cell atRow:indexPath.row withProgress:0.f];
        }
    }
}

- (void)updateCell:(CDZoomablePickerCell *)cell atRow:(NSUInteger)row withProgress:(CGFloat)progress
{
    if([_delegate respondsToSelector:@selector(fontOfTitleForCellAtRow:inPickerView:progress:)])
    {
        cell.titleLabel.font = [_delegate fontOfTitleForCellAtRow:row inPickerView:self progress:progress];
    }
    else
    {
        cell.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-UltraLight" size:(34 + (68 - 34)*progress)];
    }
    
    if([_delegate respondsToSelector:@selector(colorOfTitleForCellAtRow:inPickerView:progress:)])
    {
        cell.titleLabel.textColor = [_delegate colorOfTitleForCellAtRow:row inPickerView:self progress:progress];
    }
    else
    {
        cell.titleLabel.textColor = COLOR_WITH_HEX(0x434449, .4f + (1.f - .4f)*progress);
    }
}

@end
