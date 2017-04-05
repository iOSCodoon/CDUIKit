//
//  CDJumpableLabel.m
//  CodoonSport
//
//  Created by Jinxiao on 11/9/15.
//  Copyright © 2015 Codoon. All rights reserved.
//

#import "CDJumpableLabel.h"

typedef struct
{
    double x;
    double y;
} JumpableLabelValue;

JumpableLabelValue ValueOnCubicBezier(JumpableLabelValue* cp, double t)
{
    double ax, bx, cx;
    double ay, by, cy;
    double squared, cubed;
    JumpableLabelValue result;
    
    cx = 3.0 * (cp[1].x - cp[0].x);
    bx = 3.0 * (cp[2].x - cp[1].x) - cx;
    ax = cp[3].x - cp[0].x - cx - bx;
    
    cy = 3.0 * (cp[1].y - cp[0].y);
    by = 3.0 * (cp[2].y - cp[1].y) - cy;
    ay = cp[3].y - cp[0].y - cy - by;
    
    squared = t * t;
    cubed = squared * t;
    
    result.x = (ax * cubed) + (bx * squared) + (cx * t) + cp[0].x;
    result.y = (ay * cubed) + (by * squared) + (cy * t) + cp[0].y;
    
    return result;
}

NSInteger const JumpSteps = 30;

@interface CDJumpableLabel ()
@property (readwrite, nonatomic, assign) NSInteger index;
@property (readwrite, nonatomic, assign) double from;
@property (readwrite, nonatomic, assign) double to;
@property (readwrite, nonatomic, assign) double lastTime;
@property (readwrite, nonatomic, strong) NSMutableArray *points;
@end

@implementation CDJumpableLabel

- (void)reset
{
    _lastTime = 0.f;
    _index = 0;
    _from = 0.f;
    _to = 0.f;
    _points = [[NSMutableArray alloc] init];
}

- (void)jumpFrom:(double)from to:(double)to duration:(double)duration
{
    [self reset];
    
    _from = from;
    _to = to;
    
    JumpableLabelValue begin = {.x = 0, .y = 0};
    JumpableLabelValue end = {.x = 1, .y = 1};
    JumpableLabelValue c1 = {.x = 0.25, .y = 0.1};
    JumpableLabelValue c2 = {.x = 0.25, .y = 1};
    
    JumpableLabelValue curves[4] = {begin, c1, c2, end};
    
    double dt;
    dt = 1.0/(JumpSteps - 1.0);
    for(int i = 0; i < JumpSteps; i++)
    {
        JumpableLabelValue point = ValueOnCubicBezier(curves, i*dt);
        double time = point.x*duration;
        double value = point.y*(to - from) + from;
        
        [_points addObject:[NSArray arrayWithObjects:@(time), @(value), nil]];
    }
    
    [self update];
}

- (void)update
{
    NSString *(^formatter)(double) = ^NSString *(double value) {
        if(_formatterBlock != nil)
        {
            return _formatterBlock(value);
        }
        else
        {
            return [NSString stringWithFormat:@"%f", value];
        }
    };
    
    NSString *text = nil;
    if(_index >= JumpSteps)
    {
        _value = _to;
        text = formatter(_to);
    }
    else
    {
        NSArray *point = [_points objectAtIndex:_index];
        _index++;
        
        double value = [[point safeObjectAtIndex:1] doubleValue];
        double time = [[point safeObjectAtIndex:0] doubleValue];
        double delay = time - _lastTime;
        _lastTime = time;
        
        _value = value;
        text = formatter(value);
        
        [self performSelector:@selector(update) withObject:nil afterDelay:delay];
    }
    
    self.text = text;
}

- (void)cancelJump
{
    NSString *(^formatter)(double) = ^NSString *(double value) {
        if(_formatterBlock != nil)
        {
            return _formatterBlock(value);
        }
        else
        {
            return [NSString stringWithFormat:@"%f", value];
        }
    };
    _value = _to;
    NSString *text = formatter(_to);
    self.text = text;
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(update) object:nil];
}

- (void)setValue:(double)value {
    NSString *(^formatter)(double) = ^NSString *(double value) {
        if(_formatterBlock != nil)
        {
            return _formatterBlock(value);
        }
        else
        {
            return [NSString stringWithFormat:@"%f", value];
        }
    };
    _value = value;
    NSString *text = formatter(_value);
    self.text = text;
    [[self class] cancelPreviousPerformRequestsWithTarget:self selector:@selector(update) object:nil];
}

@end
