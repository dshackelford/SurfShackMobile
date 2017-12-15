//
//  WeatherData.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/14/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WeatherData.h"
#import "WeatherPacket.h"

@implementation WeatherData

-(id)initWithSpotID:(int)spotIDInit andSpotName:(NSString *)spotName
{
    self = [super init];
    
    //self.urlStr = [NSString stringWithFormat:@"http://api.openweathermap.org/data/2.5/weather?lat=%.2f&lon=%.2f&APPID=%@",locInit.coordinate.latitude,locInit.coordinate.longitude,[AppUtilities getOpenWeatherKey]];;
    self.spotName = spotName;
    self.downloadedData = nil;
    return self;
}

-(void)gotSomeData:(NSData *)dataInit
{
    
}

@end
