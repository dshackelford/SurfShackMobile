//
//  CurrentWeather.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/3/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppUtilities.h"
#import "CoreLocation/CoreLocation.h"
#import "WeatherPacket.h"
#import "DataSource.h"

@interface CurrentWeather : NSObject <DataSource>

@property WeatherPacket* weatherPacket;

-(double)getTemp;
-(NSString*)getSunrise;
-(NSString*)getSunset;
-(NSString*)getDescription;
@end
