//
//  DataSource.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 11/30/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#ifndef DataSource_h
#define DataSource_h

#import "DataCollector.h"
@import CoreLocation;

@protocol DataSource

@property id<DataCollector> collector;

-(id)initWithShortLength:(int)shortLengthInit andLongLength:(int)longLengthInit andCollector:(id<DataCollector>)collectorInit;
-(id)initWithCollector:(id<DataCollector>)collectorInit;

//NSURLSession workarounds
-(void)startSurfDataDownloadForSpotID:(int)spotIDInit andSpotName:(NSString*)spotNameInit;
-(void)startTideDataDownloadForCounty:(NSString*)countyInit;
-(void)startWindDataDownloadForCounty:(NSString*)countyInit;
-(void)startSwellDataDownloadForCounty:(NSString*)countyInit;

-(void)startWaterTempDownloadForCounty:(NSString*)countyInit;
-(void)startWeatherDownloadForLoc:(CLLocation*)locInit andSpotID:(int)spotID andSpotName:(NSString*)spotNameInit;



//old stuff
-(NSMutableDictionary*)getSurfDataForLocation:(int)locInit;
-(NSMutableDictionary*)getWindDataForCounty:(NSString*)countyInit;
-(NSMutableDictionary*)getTideDataForCounty:(NSString*)countyInit;
-(double)getWaterTempForCounty:(NSString*)countyInit;
-(NSMutableArray*)getSwellDataForCounty:(NSString *)countyInit;


-(void)getNearBySpots:(NSString*)latInit andLon:(NSString*)lonInit;
-(void)getAllSpotsAndCounties;

//could these be fixed with properties?
-(int)getShortRange;
-(int)getLongRange;
-(void)setShortRange:(int)rangeInit;
-(void)setLongRange:(int)rangeInit;

//weather portion

@end

#endif /* DataSource_h */
