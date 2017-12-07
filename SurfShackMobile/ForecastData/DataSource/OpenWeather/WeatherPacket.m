//
//  WeatherPacket.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/3/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherPacket.h"

@implementation WeatherPacket

-(id)init:(id)dataSet
{
    self = [super init];
    [self setLat:[[dataSet objectForKey:@"coord"] valueForKey:@"lat"]];
    [self setLon:[[dataSet objectForKey:@"coord"] valueForKey:@"lon"]];
    [self setDescription:[[dataSet objectForKey:@"weather"] valueForKey:@"description"]];
    [self setTemp:[[dataSet objectForKey:@"main"] valueForKey:@"temp"]];
    [self setSunsetTime:[[dataSet objectForKey:@"sys"] valueForKey:@"sunset"]];
    [self setSunriseTime:[[dataSet objectForKey:@"sys"] valueForKey:@"sunrise"]];
    spotID = [[dataSet objectForKey:@"spotID"] integerValue];
    
    return self;
}

-(NSMutableDictionary*)makeDict
{
    NSMutableDictionary* aDict = [NSMutableDictionary dictionary];
    
    [aDict setObject:sunsetTime forKey:@"sunset"];
    [aDict setObject:sunriseTime forKey:@"sunrise"];
    [aDict setObject:[NSNumber numberWithDouble:temp] forKey:@"temp"];
    [aDict setObject:[NSNumber numberWithInt:spotID] forKey:@"spotID"];
    
    return aDict;
}

-(void)setLat:(NSString*)latInit
{
    
    lat = [latInit doubleValue];
}

-(void)setLon:(NSString*)lonInit
{
    lon = [lonInit doubleValue];
}

-(void)setDescription:(NSArray*)descriptionInit
{
    desctription = [descriptionInit objectAtIndex:0];
}

-(void)setTemp:(NSString *)tempInit
{
    temp = ([tempInit doubleValue]- 273.15)*9/5 + 32; //it is given in kelvin
}

-(void)setSunsetTime:(NSString *)sunsetInit
{
    NSDate* ts_utc = [NSDate dateWithTimeIntervalSince1970:[sunsetInit doubleValue]];
    
    NSDateFormatter* df_utc = [[NSDateFormatter alloc] init];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy.MM.dd G 'at' HH:mm:ss zzz"];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];
    [df_local setDateFormat:@"HH:mm:ss"];

    NSString* ts_local_string = [df_local stringFromDate:ts_utc];
    
    sunsetTime = [DateHandler getTimeFromPST:ts_local_string];
}

-(void)setSunriseTime:(NSString *)sunriseInit
{
    NSDate* ts_utc = [NSDate dateWithTimeIntervalSince1970:[sunriseInit doubleValue]];
    
    NSDateFormatter* df_utc = [[NSDateFormatter alloc] init];
    [df_utc setTimeZone:[NSTimeZone timeZoneWithName:@"UTC"]];
    [df_utc setDateFormat:@"yyyy.MM.dd G 'at' HH:mm:ss zzz"];
    
    NSDateFormatter* df_local = [[NSDateFormatter alloc] init];
    [df_local setTimeZone:[NSTimeZone timeZoneWithName:@"PST"]];
    [df_local setDateFormat:@"HH:mm:ss"];
    
    NSString* ts_local_string = [df_local stringFromDate:ts_utc];
    
    sunriseTime = [DateHandler getTimeFromPST:ts_local_string];
}
#pragma mark - Getters

-(double)getLat
{
    return lat;
}

-(double)getLon
{
    return lon;
}

-(double)getTemp
{
    return temp;
}

-(NSString*)getDescription
{
    return desctription;
}

-(NSString*)getSunsetTime
{
    return sunsetTime;
}

-(NSString*)getSunriseTime
{
    return sunriseTime;
}

@end
