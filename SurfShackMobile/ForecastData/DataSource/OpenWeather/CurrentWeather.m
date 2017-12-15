//
//  CurrentWeather.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/3/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CurrentWeather.h"
#import <AsyncBlockOperation/AsyncBlockOperation.h>

@implementation CurrentWeather

-(id)initWithCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    self.collector = collectorInit;
    
    return self;
}

-(void)startWeatherDownloadForLoc:(CLLocation*)locInit andSpotID:(int)spotID andSpotName:(NSString *)spotNameInit andOp:(AsyncBlockOperation *)op
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
              NSLog(@"no %@ spot weather data download completed",spotNameInit);
              NSMutableDictionary* weatherDict = [NSMutableDictionary dictionary];
              [weatherDict setObject:spotNameInit forKey:@"spotName"];
              [self.collector weatherDataDictReceived:weatherDict];
              [op complete];
          }
          else
          {
              NSLog(@"%@ spot weather data download completed",spotNameInit);
              NSMutableDictionary* jsonDataDict = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              //[jsonDataDict setValue:[NSNumber numberWithInteger:spotID] forKey:@"spotID"];
              self.weatherPacket = [[WeatherPacket alloc] init:jsonDataDict];
              NSMutableDictionary* weatherDict = [self.weatherPacket makeDict];
              [weatherDict setObject:spotNameInit forKey:@"spotName"];
              [self.collector weatherDataDictReceived:weatherDict];
              [op complete];
          }
      }] resume];
    
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


@synthesize collector;

@end
