//
//  CDTabBarButton.m
//  CDTabBarController
//
//  Created by Jinxiao on 8/30/15.
//  Copyright (c) 2015 codoon. All rights reserved.
//

#import "CDTabBarButton.h"
#import "CDTabBarItem.h"
#import "CDTabBarBadge.h"

#define kDefaultImageHeight         34
#define kDefaultTitleHeight         10
#define kDefaultTitleOffset         CGPointMake(0.f, 0.f)

@interface CDTabBarButton ()

@property (readwrite, nonatomic, strong) CDTabBarItem *item;

@end

@implementation CDTabBarButton

- (id)initWithItem:(CDTabBarItem *)item
{
    self = [super initWithFrame:CGRectZero];
	if(self)
	{
        self.clipsToBounds = YES;

		self.titleLabel.font = [UIFont systemFontOfSize:10.f];
		self.titleLabel.textAlignment = NSTextAlignmentCenter;
        self.adjustsImageWhenHighlighted = NO;
        
		self.showsTitle = NO;
		self.imageHeight = kDefaultImageHeight;
		self.titleHeight = kDefaultTitleHeight;
		self.titleOffset = kDefaultTitleOffset;
		
		self.item = item;
        
		[self configureButton];
		[self sendSubviewToBack:self.imageView];
		
		for(NSString *keyPath in [CDTabBarItem keyPaths])
		{
			[item addObserver:self forKeyPath:keyPath options:NSKeyValueObservingOptionNew context:NULL];
		}
	}
	
	return self;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    CDTabBarItem *tabBarItem = (CDTabBarItem *)object;
	if([keyPath isEqualToString:@"title"])
	{
		[self setTitle:tabBarItem.title forState:UIControlStateNormal];
	}
	else if([keyPath isEqualToString:@"iconImage"])
	{
		[self setImage:self.item.iconImage forState:UIControlStateNormal];
	}
	else if([keyPath isEqualToString:@"iconHighlightedImage"])
	{
		[self setImage:self.item.iconHighlightedImage forState:UIControlStateHighlighted];
		[self setImage:self.item.iconHighlightedImage forState:UIControlStateSelected|UIControlStateHighlighted];
	}
	else if([keyPath isEqualToString:@"iconSelectedImage"])
	{
		[self setImage:self.item.iconSelectedImage forState:UIControlStateSelected];
	}
	else if([keyPath isEqualToString:@"titleColor"])
	{
		[self setTitleColor:self.item.titleColor forState:UIControlStateNormal];
	}
    else if([keyPath isEqualToString:@"titleHighlightedColor"])
    {
        [self setTitleColor:self.item.titleHighlightedColor forState:UIControlStateHighlighted];
		[self setTitleColor:self.item.titleHighlightedColor forState:UIControlStateHighlighted|UIControlStateSelected];
    }
    else if([keyPath isEqualToString:@"titleSelectedColor"])
    {
        [self setTitleColor:self.item.titleSelectedColor forState:UIControlStateSelected];
    }
    else if([keyPath isEqualToString:@"badge"])
    {
        if(self.item.badge == nil)
        {
            self.badgeView = nil;
        }
        else
        {
            switch(self.item.badge.type)
            {
                case CDTabBarBadgeTypeDot:
                {
                    UIView *view = [[UIView alloc] init];
                    view.backgroundColor = COLOR_WITH_HEX(0xf1585b, 1);
                    view.frame = CGRectMake(0, 0, 10, 10);
                    self.badgeView = view;
                    break;
                }
                case CDTabBarBadgeTypeString:
                {
                    UILabel *label = [[UILabel alloc] init];
                    label.backgroundColor = COLOR_WITH_HEX(0xf1585b, 1);
                    label.text = self.item.badge.value;
                    label.font = [UIFont systemFontOfSize:9];
                    label.textAlignment = NSTextAlignmentCenter;
                    label.textColor = [UIColor whiteColor];
                    [label sizeToFit];
                    label.width += 8;
                    label.height += 4;
                    label.width = MAX(label.width, label.height);
                    self.badgeView = label;
                    break;
                }
                case CDTabBarBadgeTypeIcon:
                {
                    self.badgeView = [[UIImageView alloc] initWithImage:self.item.badge.value];
                }
            }
        }
    }
	
	[self.superview.superview bringSubviewToFront:self.superview];
}

- (void)configureButton
{
	[self setTitle:self.item.title forState:UIControlStateNormal];
	[self setImage:self.item.iconImage forState:UIControlStateNormal];
    
    if([self.item respondsToSelector:@selector(iconHighlightedImage)])
    {
        [self setImage:self.item.iconHighlightedImage forState:UIControlStateSelected|UIControlStateHighlighted];
    }
    if([self.item respondsToSelector:@selector(iconSelectedImage)])
    {
        [self setImage:self.item.iconSelectedImage forState:UIControlStateSelected];
    }
    if([self.item respondsToSelector:@selector(titleColor)] && self.item.titleColor)
    {
        [self setTitleColor:self.item.titleColor forState:UIControlStateNormal];
    }
    if([self.item respondsToSelector:@selector(titleHighlightedColor)] && self.item.titleHighlightedColor)
    {
        [self setTitleColor:self.item.titleHighlightedColor forState:UIControlStateHighlighted|UIControlStateSelected];
        [self setTitleColor:self.item.titleHighlightedColor forState:UIControlStateSelected];
    }
    if([self.item respondsToSelector:@selector(titleSelectedColor)] && self.item.titleSelectedColor)
    {
        [self setTitleColor:self.item.titleSelectedColor forState:UIControlStateSelected];
    }
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    _badgeView.layer.cornerRadius = _badgeView.height/2;
    _badgeView.layer.masksToBounds = YES;
    _badgeView.left = self.width/2 + 6;
    _badgeView.centerY = 10;
}

- (void)setBadgeView:(UIView *)badgeView
{
    if(badgeView != _badgeView)
    {
        if(_badgeView != nil)
        {
            [_badgeView removeFromSuperview];
        }
        
        _badgeView = badgeView;
        
        if(_badgeView != nil)
        {
            [self addSubview:_badgeView];
        }
    }
    
    [self setNeedsLayout];
}

- (void)setShowsTitle:(BOOL)showsTitle
{
	if(self.showsTitle != showsTitle)
	{
		_showsTitle = showsTitle;
        
		[self setNeedsLayout];
	}
}

- (CGRect)imageRectForContentRect:(CGRect)contentRect
{
	if([self currentTitle] && self.showsTitle)
	{
		contentRect.size.height = self.imageHeight;
	}
	
    CGFloat x = (contentRect.size.width - [[self currentImage] size].width)/2.f;
	CGFloat y = (contentRect.size.height - [[self currentImage] size].height)/2.f;
	
	return UIEdgeInsetsInsetRect(contentRect, UIEdgeInsetsMake(y, x, y, x));
}

- (CGRect)titleRectForContentRect:(CGRect)contentRect
{
	if(!self.showsTitle)
	{
		return CGRectZero;
	}
	
	if([self currentImage])
	{
		return CGRectMake(self.titleOffset.x, self.imageHeight + self.titleOffset.y, CGRectGetWidth(contentRect), self.titleHeight);
	}
	
	return contentRect;
}

- (void)dealloc
{
	for(NSString *keyPath in [CDTabBarItem keyPaths])
	{
		[self.item removeObserver:self forKeyPath:keyPath];
	}
}

@end
