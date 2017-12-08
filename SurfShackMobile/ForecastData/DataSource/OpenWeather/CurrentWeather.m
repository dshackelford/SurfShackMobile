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

-(id)initWithCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    self.collector = collectorInit;
    
    return self;
}

-(void)startWeatherDownloadForLoc:(CLLocation*)locInit andSpotID:(int)spotID andSpotName:(NSString *)spotNameInit
{
    //ESTABLISH THE URL TO GRAB INFO FROM
    NSString* stringURL = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.2f&lon=%.2f&APPID=%@",locInit.coordinate.latitude,locInit.coordinate.longitude,[AppUtilities getOpenWeatherKey]];
    
    NSURL* theURL = [NSURL URLWithString:stringURL];
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [[session dataTaskWithURL:theURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if(error)
          {
              NSLog(@"there was an error in getting json data from url in spitcast");
          }
          else
          {
              NSLog(@"json weather data download completed");
              NSMutableDictionary* jsonDataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              //[jsonDataDict setValue:[NSNumber numberWithInteger:spotID] forKey:@"spotID"];
              self.weatherPacket = [[WeatherPacket alloc] init:jsonDataDict];
              NSMutableDictionary* weatherDict = [self.weatherPacket makeDict];
              [weatherDict setObject:spotNameInit forKey:@"spotName"];
              [self.collector weatherDataDictReceived:weatherDict];
              
          }
      }] resume];
    
        
    //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH
    //NSDictionary* jsonDataDict = [self retunJsonDataFromURLString:stringURL];
    
}



-(double)getTemp
{
    return self.weatherPacket.getTemp;
}
-(NSString*)getSunrise
{
    return self.weatherPacket.getSunriseTime;
}

-(NSString*)getSunset
{
    return self.weatherPacket.getSunsetTime;
}

-(NSString*)getDescription
{
    return self.weatherPacket.getDescription;
}

/*
-(NSDictionary*)retunJsonDataFromURLString:(NSString*)stringInit
{
    NSURL* theURL = [NSURL URLWithString:stringInit];
    
    NSURLRequest* theRequest = [NSURLRequest requestWithURL:theURL];
    
    //MAKE THE CONNECTION TO THE INTERNET
    NSURLConnection* theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:nil];
    
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
    
}*/

@synthesize collector;

@end
