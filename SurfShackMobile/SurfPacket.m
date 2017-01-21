//
//  SurfPacket.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/30/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfPacket.h"

@implementation SurfPacket


-(id)init:(id)dataSet
{
    self = [super init];
    
    [self setDay:[dataSet objectForKey:@"day"]];
    [self setDate:[dataSet objectForKey:@"date"]];
    [self setTime:[dataSet objectForKey:@"hour"]];
    [self setSwellType:[[dataSet objectForKey: @"shape_detail"] valueForKey:@"swell"]];
    [self setTideType:[[dataSet objectForKey:@"shape_detail"] valueForKey:@"tide"]];
    [self setWindType:[[dataSet objectForKey:@"shape_detail"] valueForKey:@"wind"]];
    [self setSpotID:[[dataSet objectForKey:@"spot_id"] doubleValue]];
    [self setSpotName:[dataSet objectForKey: @"spot_name"]];
    [self setWaveHeight:[[dataSet objectForKey:@"size_ft"] doubleValue]];
    
    return self;
}

-(void)setData:(id)dataSet
{
    [self setDay:[dataSet objectForKey:@"day"]];
    [self setDate:[dataSet objectForKey:@"date"]];
    [self setTime:[dataSet objectForKey:@"hour"]];
    [self setSwellType:[[dataSet objectForKey: @"shape_detail"] valueForKey:@"swell"]];
    [self setTideType:[[dataSet objectForKey:@"shape_detail"] valueForKey:@"tide"]];
    [self setWindType:[[dataSet objectForKey:@"shape_detail"] valueForKey:@"wind"]];
    [self setSpotID:[[dataSet objectForKey:@"spot_id"] doubleValue]];
    [self setSpotName:[dataSet objectForKey: @"spot_name"]];
    [self setWaveHeight:[[dataSet objectForKey:@"size_ft"] doubleValue]];
}

#pragma mark - Setters
-(void)setDay:(NSString *)dayInit
{
    day = dayInit;
}

-(void)setDate:(NSString*)dateInit
{
    date = [DateHandler getDateNumberFromDateStr:dateInit];
}

-(void)setTime:(id)timeInit
{
    NSString *AM = @"AM";
    NSString *target=timeInit;
    
    //the time is in the morning
    if([self substring:AM existsInString:target])
    {
        if ([timeInit doubleValue] == 12)
        {
            time = 0; //12am should be the first, it is techincally before 1am
        }
        else
        {
            time = [timeInit doubleValue];
        }
    }
    else //the time is the PM, so its in the military time now.
    {
        if ([timeInit doubleValue] !=12) //12pm should stay as 12
        {
            time = [timeInit doubleValue] + 12;
        }
        else
        {
            time = [timeInit doubleValue];
        }
    }
}

-(BOOL)substring:(NSString *)substr existsInString:(NSString *)str {
    if(!([str rangeOfString:substr options:NSCaseInsensitiveSearch].length==0)) {
        return YES;
    }
    
    return NO;
}

-(void)setSwellType:(NSString *)swellTypeInit
{
    swellType = swellTypeInit;
}


-(void)setTideType:(NSString *)tideTypeInit
{
    tideType = tideTypeInit;
}

-(void)setWindType:(NSString *)windTypeInit
{
    windType = windTypeInit;
}

-(void)setSpotID:(double)spotIDInit
{
    spotID = spotIDInit;
}

-(void)setSpotName:(NSString *)spotNameInit
{
    spotName = spotNameInit;
}

-(void)setWaveHeight:(double)waveHeightInit
{
    waveHeight = waveHeightInit;
    
}

#pragma mark - Getters

-(NSString*)getDay
{
    return day;
}

-(NSString*)getDate
{
    return date;
}

-(double)getTime
{
    return time;
}

-(NSString*)getSwellType
{
    return swellType;
}

-(NSString*)getTideType
{
    return tideType;
}

-(NSString*)getWindType
{
    return windType;
}

-(int)getSpotID
{
    return spotID;
}

-(NSString*)getSpotName
{
    return spotName;
}

-(double)getWaveHeight
{
    return waveHeight;
}

-(double)getPlotData
{
    return waveHeight;
}

@end