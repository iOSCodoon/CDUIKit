//
//  CDTabBarOverlay.m
//  CDTabBarController
//
//  Created by Jinxiao on 8/30/15.
//  Copyright (c) 2015 codoon. All rights reserved.
//

#import "CDTabBarOverlay.h"
#import "CDTabBarItem.h"
#import "CDTabBarButton.h"

@interface CDTabBarOverlay ()

@property (readwrite, nonatomic, strong) NSMutableArray *buttons;
@property (readwrite, nonatomic, strong) UIImageView *backgroundImageView;
@property (readwrite, nonatomic, strong) UIImageView *sliderImageView;

@end
@implementation CDTabBarOverlay

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if(self)
	{
		self.backgroundImageView = [[UIImageView alloc] initWithFrame:self.bounds];
		self.backgroundImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
		[self addSubview:self.backgroundImageView];
		
		self.sliderImageView = [[UIImageView alloc] init];
		[self addSubview:self.sliderImageView];
		
		self.animatesSlider = YES;
		self.selectionControlEvent = UIControlEventTouchDown;
		self.showsTouchWhenHighlighted = YES;
		self.showsTitle = YES;
    }
    
    return self;
}

- (void)setItems:(NSArray *)items
{
    if(self.items != items)
    {
        _items = items;
        _selectedItem = nil;
    }
    
    [self createButtons];
    [self setNeedsLayout];
}

- (void)setItems:(NSArray *)items animated:(BOOL)animated
{
    if(animated)
    {
        [UIView animateWithDuration:.2f delay:.0f options:0 animations:^{
            self.items = items;
        } completion:NULL];
    }
    else
    {
        self.items = items;
    }
}

- (void)setSelectedItem:(CDTabBarItem *)selectedItem
{
	CDTabBarButton *newButton = nil;
	CDTabBarButton *oldButton = nil;
	for(CDTabBarButton *button in self.buttons)
	{
		if(button.item == self.selectedItem)
		{
			oldButton = button;
		}
		
		if(button.item == selectedItem)
		{
			newButton = button;
		}
	}
	
	if(!newButton)
	{
		return;
	}
	
	oldButton.selected = NO;
	newButton.selected = YES;
	
	_selectedItem = selectedItem;
	
	if(!oldButton || oldButton == newButton)
	{
		[self slideToButton:newButton animated:NO];
	}
	else
	{
		[self slideToButton:newButton animated:self.animatesSlider];
	}
}

- (void)setSelectedIndex:(NSInteger)selectedIndex
{
    if(index >= 0 && selectedIndex < [self.items count])
    {
        [self setSelectedItem:[self.items objectAtIndex:selectedIndex]];
    }
}

- (NSInteger)selectedIndex
{
    return [self.items indexOfObject:self.selectedItem];
}

- (void)createButtons
{
	for(CDTabBarButton *button in self.buttons)
	{
		[button removeFromSuperview];
	}
	
	self.buttons = [[NSMutableArray alloc] init];
	
	for(CDTabBarItem *item in self.items)
	{
		CDTabBarButton *button = [[CDTabBarButton alloc] initWithItem:item];
		
		[button setShowsTitle:self.showsTitle];
		[button setShowsTouchWhenHighlighted:self.showsTouchWhenHighlighted];
        
        if(self.tabImageHeight > 0)
        {
            [button setImageHeight:self.tabImageHeight];
        }
        
        if(self.tabTitleHeight > 0)
        {
            [button setTitleHeight:self.tabTitleHeight];
        }
        
        if(!CGPointEqualToPoint(self.tabTitleOffset, CGPointZero))
        {
            [button setTitleOffset:self.tabTitleOffset];
        }

		[button addTarget:self action:@selector(tabBarButtonPressed:) forControlEvents:self.selectionControlEvent];
		
		[self addSubview:button];
		
		[self.buttons addObject:button];
	}
}

- (void)setSelectionControlEvent:(UIControlEvents)selectionControlEvent
{
	if(self.selectionControlEvent != selectionControlEvent)
	{
		_selectionControlEvent = selectionControlEvent;
		
		for(UIButton *button in self.buttons)
		{
			[button removeTarget:nil action:NULL forControlEvents:UIControlEventAllEvents];
			[button addTarget:self action:@selector(tabBarButtonPressed:) forControlEvents:selectionControlEvent];
		}
	}
}

- (void)setShowsTouchWhenHighlighted:(BOOL)showsTouchWhenHighlighted
{
	if(self.showsTouchWhenHighlighted != showsTouchWhenHighlighted)
	{
		_showsTouchWhenHighlighted = showsTouchWhenHighlighted;
		
		for(UIButton *button in self.buttons)
		{
			button.showsTouchWhenHighlighted = showsTouchWhenHighlighted; 
		}
	}
}

- (void)setShowsTitle:(BOOL)showsTitle
{
	if(self.showsTitle != showsTitle)
	{
		_showsTitle = showsTitle;
		
		for(CDTabBarButton *button in self.buttons)
		{
			button.showsTitle = showsTitle;
		}
	}
}

- (void)tabBarButtonPressed:(id)sender
{
    BOOL shouldSelect = YES;
    if(self.delegate && [self.delegate respondsToSelector:@selector(tabBarOverlay:shouldSelectTabAtIndex:)])
    {
        shouldSelect = [self.delegate tabBarOverlay:self shouldSelectTabAtIndex:[self.buttons indexOfObject:sender]];
    }
    
    if(!shouldSelect)
    {
        return;
    }
    
	if(self.delegate && [self.delegate respondsToSelector:@selector(tabBarOverlay:didSelectTabAtIndex:)])
	{
		[self.delegate tabBarOverlay:self didSelectTabAtIndex:[self.buttons indexOfObject:sender]];
	}
}

- (void)slideToButton:(CDTabBarButton *)button animated:(BOOL)animated;
{
    if(animated)
    {
        [UIView animateWithDuration:.2f delay:.0f options:UIViewAnimationOptionBeginFromCurrentState animations:^{
            self.sliderImageView.frame = button.frame;
        } completion:nil];
    }
    else
    {
        self.sliderImageView.frame = button.frame;
    }
}

- (void)layoutSubviews
{
	[super layoutSubviews];
	
	NSUInteger count = [self.buttons count];
	
	NSUInteger buttonWidth = self.bounds.size.width/count;
	
	for(NSUInteger i = 0; i < count; i++)
	{
		CDTabBarButton *button = [self.buttons objectAtIndex:i];
		button.frame = CGRectMake(buttonWidth * i, 0, buttonWidth, self.bounds.size.height);
        
        !button.item.configuration ?: button.item.configuration(button, i);
	}
	
	[self setSelectedItem:self.selectedItem];
}

@end
