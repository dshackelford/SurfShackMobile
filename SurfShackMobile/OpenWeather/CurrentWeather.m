//
//  CurrentWeather.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/3/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentWeather.h"

@implementation CurrentWeather

-(void)getCurrentWeatherForLoc:(CLLocation*)locInit
{
    //ESTABLISH THE URL TO GRAB INFO FROM
    NSString* stringURL = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.2f&lon=%.2f&APPID=%@",locInit.coordinate.latitude,locInit.coordinate.longitude,[AppUtilities getOpenWeatherKey]];
        
    //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH
    NSDictionary* jsonDataDict = [self retunJsonDataFromURLString:stringURL];
    
    weatherPacket = [[WeatherPacket alloc] init:jsonDataDict];
}

-(double)getTemp
{
    return [weatherPacket getTemp];
}
-(NSString*)getSunrise
{
    return [weatherPacket getSunriseTime];
}

-(NSString*)getSunset
{
    return [weatherPacket getSunsetTime];
}

-(NSString*)getDescription
{
    return [weatherPacket getDescription];
}

-(NSDictionary*)retunJsonDataFromURLString:(NSString*)stringInit
{
    NSURL* theURL = [NSURL URLWithString:stringInit];
    
    NSURLRequest* theRequest = [NSURLRequest requestWithURL:theURL];
    
    //MAKE THE CONNECTION TO THE INTERNET
    NSURLConnection* theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:nil];
    //    NSURLSession
    
    [theConnection start];
    
    //COLLECT THE NECESSARY DATA
    NSData* receivedData = [[NSData alloc]initWithContentsOfURL:theURL];
    
    //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH
    if(receivedData)
    {
        NSDictionary* jsonDataArray = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
        
        [theConnection cancel];
        
        return  jsonDataArray;
    }
    else
    {
        [theConnection cancel];
        return nil;
    }
    
}

@end
