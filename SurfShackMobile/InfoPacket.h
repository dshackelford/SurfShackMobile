//
//  InfoPacket.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/30/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "DateHandler.h"

@interface InfoPacket : NSObject
{
    NSString* day;
    int time;
    NSString* date; //20160723
    
    NSString* swellType;
    NSString* tideType;
    NSString* windType;

    double waveHeight;
    
    int spotID;
    NSString* spotName;
    
    NSString* countyName;
    double lat;
    double lon;
}

-(void)setData:(id)dataSet;

//SETTERS
-(id)init:(id)dataSet;

-(void)setDay:(NSString *)dayInit;

-(void)setDate:(NSString*)dateInit;

-(void)setTime:(id)timeInit;

-(void)setSwellType:(NSString *)swellTypeInit;

-(void)setTideType:(NSString*)tideTypeInit;

-(void)setWindType:(NSString*)windTypeInit;

-(void)setSpotID:(double)spotIDInit;

-(void)setSpotName:(NSString *)spotNameInit;

-(void)setWaveHeight:(double)waveHeightInit;
-(void)setCountyName:(NSString*)countyNameInit;
-(void)setLon:(double)lonInit;
-(void)setLat:(double)latInit;

//GETTERS
-(NSString*)getDay;

-(NSString*)getDate;

-(double)getTime;

-(NSString*)getSwellType;

-(NSString*)getTideType;

-(NSString*)getWindType;

-(int)getSpotID;

-(NSString*)getSpotName;

-(NSString*)getCountyName;

-(double)getWaveHeight;

-(double)getLon;
-(double)getLat;

//the data that will be plotted
-(double)getPlotData;


@end