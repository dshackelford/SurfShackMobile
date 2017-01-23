//
//  WaterTempPacket.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/18/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaterTempPacket.h"


@implementation WaterTempPacket

-(id)init:(id)dataSet
{
    self = [super init];
    
    [self setBouyID:[[dataSet objectForKey:@"buoy_id"] intValue]];
    [self setTempC:[[dataSet objectForKey:@"celcius"] doubleValue]];
    [self setTempF:[[dataSet objectForKey:@"fahrenheit"] doubleValue]];
    [self setClothing:[dataSet objectForKey:@"wetsuit"]];
    
    return self;
}

-(void)setBouyID:(int)buoyInit
{
    buoyID = buoyInit;
}

-(void)setTempF:(double)tempFInit
{
    tempF = tempFInit;
}

-(void)setTempC:(double)tempCInit
{
    tempC = tempCInit;
}

-(void)setClothing:(NSString*)clothingInit
{
    clothing = clothingInit;
}

-(double)getTempF
{
    return tempF;
}

-(double)getTempC
{
    return tempC;
}

@end
