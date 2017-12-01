//
//  TidePacket.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/26/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TidePacket.h"


@implementation TidePacket

-(id)init:(id)dataSet
{
    self = [super init];
    
    [self setTide:[[dataSet objectForKey:@"tide"] doubleValue]];
    [self setTideMeters:[[dataSet objectForKey:@"tide_meters"] doubleValue]];
    [self setCountyName:[dataSet objectForKey: @"name"]];
    [self setTime:[dataSet objectForKey:@"hour"]];
    [self setDay:[dataSet objectForKey:@"day"]];
    [self setDate:[dataSet objectForKey:@"date"]];
    
    return self;
}

-(void)setData:(id)dataSet
{
    [self setTide:[[dataSet objectForKey:@"tide"] doubleValue]];
    [self setTideMeters:[[dataSet objectForKey:@"tide_meters"] doubleValue]];
    [self setCountyName:[dataSet objectForKey: @"name"]];
    [self setTime:[dataSet objectForKey:@"hour"]];
    [self setDay:[dataSet objectForKey:@"day"]];
    [self setDate:[dataSet objectForKey:@"date"]];
}

-(void)setTide:(double)tideInit
{
    tide = tideInit;
}

-(void)setTideMeters:(double)tideInit
{
    tideMeters = tideInit;
}

-(double)getTide
{
    return tide;
}

-(double)getTideMeters
{
    return tideMeters;
}

-(double)getPlotData
{
    return tide;
}

@end