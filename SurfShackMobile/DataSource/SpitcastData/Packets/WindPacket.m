//
//  WindPacket.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/24/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WindPacket.h"


@implementation WindPacket

-(id)init:(id)dataSet
{
    self = [super init];
    
    [self setDegrees:[[dataSet objectForKey:@"direction_degrees"] intValue]];
    [self setDegreesText:[dataSet objectForKey:@"direction_text"]];
    [self setSpeedKTS:[[dataSet objectForKey:@"speed_kts"] doubleValue]];
    [self setSpeedMPH:[[dataSet objectForKey:@"speed_mph"] doubleValue]];
    [self setCountyName:[dataSet objectForKey: @"name"]];
    [self setTime:[dataSet objectForKey:@"hour"]];
    [self setDay:[dataSet objectForKey:@"day"]];
    [self setDate:[dataSet objectForKey:@"date"]];
    
    return self;
}

-(void)setData:(id)dataSet
{
    [self setDegrees:[[dataSet objectForKey:@"direction_degrees"] intValue]];
    [self setDegreesText:[dataSet objectForKey:@"direction_text"]];
    [self setSpeedKTS:[[dataSet objectForKey:@"speed_kts"] doubleValue]];
    [self setSpeedMPH:[[dataSet objectForKey:@"speed_mph"] doubleValue]];
    [self setCountyName:[dataSet objectForKey: @"name"]];
    [self setTime:[dataSet objectForKey:@"hour"]];
    [self setDay:[dataSet objectForKey:@"day"]];
    [self setDate:[dataSet objectForKey:@"date"]];
}

-(void)setDegrees:(int)degInit
{
    degrees = degInit;
}

-(void)setDegreesText:(NSString *)degTextInit
{
    degreesText = degTextInit;
}

-(void)setSpeedKTS:(double)speedInit
{
    speedKTS = speedInit;
}

-(void)setSpeedMPH:(double)speedInit
{
    speedMPH = speedInit;
}

-(double)getSpeedMPH
{
    return speedMPH;
}

-(double)getSpeedKTS
{
    return speedKTS;
}

-(int)getDirectionDegrees
{
    return degrees;
}

-(double)getPlotData
{
    //i may need to add a if else here to handle the cases of kts and mph??
    return speedMPH;
}
@end
