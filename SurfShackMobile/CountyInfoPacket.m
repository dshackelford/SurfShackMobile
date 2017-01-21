//
//  CountyInfoPacket.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/14/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CountyInfoPacket.h"


@implementation CountyInfoPacket

-(id)init:(id)dataSet
{
    self = [super init];
    
    [self setCountyName:[dataSet objectForKey:@"county_name"]];
    [self setLat:[[dataSet objectForKey:@"latitude"] doubleValue]];
    [self setLon:[[dataSet objectForKey:@"longitude"] doubleValue]];
    [self setSpotID:[[dataSet objectForKey:@"spot_id"] doubleValue]];
    [self setSpotName:[dataSet objectForKey: @"spot_name"]];
    
    return self;
}

-(void)setLat:(double)latInit
{
    lat = latInit;
}

-(void)setLon:(double)lonInit
{
    lon = lonInit;
}

-(void)setCountyName:(NSString*)countyNameInit
{
    countyName = countyNameInit;
}

-(NSString*)getCountyName
{
    return countyName;
}

-(double)getLat
{
    return lat;
}

-(double)getLon
{
    return lon;
}
@end