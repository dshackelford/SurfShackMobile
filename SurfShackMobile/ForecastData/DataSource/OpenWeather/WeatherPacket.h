//
//  WeatherPacket.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/3/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import "DateHandler.h"
#import "CoreLocation/CoreLocation.h"

@interface WeatherPacket : NSObject
{
    CLLocation* location;
    double lat;
    double lon;
    
    NSString* desctription;
    double temp;
    NSString* sunsetTime;
    NSString* sunriseTime;
}


//SETTERS
-(id)init:(id)dataSet;

-(void)setLat:(NSString*)latInit;
-(void)setLon:(NSString*)lonInit;
-(void)setDescription:(NSString*)descriptionInit;
-(void)setTemp:(NSString*)tempInit;
-(void)setSunsetTime:(NSString*)sunsetInit;
-(void)setSunriseTime:(NSString*)sunriseInit;

//GETTERS
-(double)getLon;
-(double)getLat;
-(double)getTemp;
-(NSString*)getDescription;
-(NSString*)getSunsetTime;
-(NSString*)getSunriseTime;

@end