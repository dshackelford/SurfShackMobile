//
//  DatumView.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/17/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DatumView.h"

@implementation DatumView

-(id)initSunsetWithAFrame:(CGRect)frameInit
{
    self = [super initWithFrame:frameInit];
    
    self.frame = frameInit;
    
    UIBezierPath* sunsetPath = [UIBezierPath bezierPath];
    [sunsetPath moveToPoint:CGPointMake(0,30)];
    [sunsetPath addLineToPoint:CGPointMake(60,30)];
    [sunsetPath addArcWithCenter:CGPointMake(30, 30) radius:20 startAngle:0 endAngle:M_PI clockwise:YES];
    [sunsetPath closePath];
    
    sunsetImage = [Bezier draw:sunsetPath inView:self atPoint:CGPointMake(self.frame.size.width/2, 90) ofSize:CGSizeMake(60, 60)];
                   
    [self addSubview:sunsetImage];
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 80)];
    label.text = @"hello";
    label.textAlignment  = NSTextAlignmentCenter;
    [self addSubview:label];
    
    return self;
}

-(id)initSunriseWithAFrame:(CGRect)frameInit
{
    self = [super initWithFrame:frameInit];
    
    self.frame = frameInit;
    
    UIBezierPath* sunsetPath = [UIBezierPath bezierPath];
    [sunsetPath moveToPoint:CGPointMake(0,30)];
    [sunsetPath addLineToPoint:CGPointMake(60,30)];
    [sunsetPath addArcWithCenter:CGPointMake(30, 30) radius:20 startAngle:0 endAngle:M_PI clockwise:NO];
    [sunsetPath closePath];
    
    sunsetImage = [Bezier draw:sunsetPath inView:self atPoint:CGPointMake(self.frame.size.width/2,60) ofSize:CGSizeMake(60, 60)];
    
    [self addSubview:sunsetImage];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 100)];
    label.textAlignment  = NSTextAlignmentCenter;
    [self addSubview:label];
    
    return self;
}

-(id)initHighTideWithAFrame:(CGRect)frameInit
{
    self = [super initWithFrame:frameInit];
    
    self.frame = frameInit;
    
    UIBezierPath* sunsetPath = [UIBezierPath bezierPath];
    [sunsetPath moveToPoint:CGPointMake(0,30)];
    [sunsetPath addLineToPoint:CGPointMake(60,30)];
    [sunsetPath addLineToPoint:CGPointMake(30, 30)];
    [sunsetPath addLineToPoint:CGPointMake(10, 50)];
    [sunsetPath addLineToPoint:CGPointMake(50, 50)];
    [sunsetPath addLineToPoint:CGPointMake(30, 30)];
    [sunsetPath closePath];
    
    sunsetImage = [Bezier draw:sunsetPath inView:self atPoint:CGPointMake(self.frame.size.width/2,90) ofSize:CGSizeMake(60, 60)];
    
    [self addSubview:sunsetImage];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 80)];
    label.textAlignment  = NSTextAlignmentCenter;
    [self addSubview:label];
    
    return self;
}

-(id)initLowTideWithAFrame:(CGRect)frameInit
{
    self = [super initWithFrame:frameInit];
    
    self.frame = frameInit;
    
    UIBezierPath* sunsetPath = [UIBezierPath bezierPath];
    [sunsetPath moveToPoint:CGPointMake(0,30)];
    [sunsetPath addLineToPoint:CGPointMake(60,30)];
    [sunsetPath addLineToPoint:CGPointMake(30, 30)];
    [sunsetPath addLineToPoint:CGPointMake(10,10)];
    [sunsetPath addLineToPoint:CGPointMake(50, 10)];
    [sunsetPath addLineToPoint:CGPointMake(30, 30)];
    [sunsetPath closePath];
    
    sunsetImage = [Bezier draw:sunsetPath inView:self atPoint:CGPointMake(self.frame.size.width/2,60) ofSize:CGSizeMake(60, 60)];
    
    [self addSubview:sunsetImage];
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(0, 30, 100, 100)];
    label.textAlignment  = NSTextAlignmentCenter;
    [self addSubview:label];
    
    return self;
}

-(id)initMainSwellWithAFrame:(CGRect)frameInit
{
    self = [super initWithFrame:frameInit];
    
    self.frame = frameInit;
    
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(10, 25, 100, 100)];
    label.textAlignment  = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 4;
    [self addSubview:label];
    
    return self;
}

-(id)initSecondSwellWithAFrame:(CGRect)frameInit
{
    self = [super initWithFrame:frameInit];
    
    self.frame = frameInit;
    
    label = [[UILabel alloc] initWithFrame:CGRectMake(25, 25, 100, 100)];
    label.textAlignment  = NSTextAlignmentLeft;
    label.lineBreakMode = NSLineBreakByWordWrapping;
    label.numberOfLines = 4;
    [self addSubview:label];
    
    return self;
}

-(void)updateSwellDisplay:(NSDictionary*)dictInit
{
    
}

-(void)updateLabelStr:(NSString*)strInit
{
    label.text = strInit;
}

@end