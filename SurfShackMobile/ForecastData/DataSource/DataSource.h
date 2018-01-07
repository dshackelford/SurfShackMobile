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
#import <AsyncBlockOperation/AsyncBlockOperation.h>
@import CoreLocation;

@protocol DataSource

@property id<DataCollector> collector;

-(id)initWithShortLength:(int)shortLengthInit andLongLength:(int)longLengthInit andCollector:(id<DataCollector>)collectorInit;
-(id)initWithCollector:(id<DataCollector>)collectorInit;

//NSURLSession workarounds
-(void)startSurfDataDownloadForSpotID:(int)spotIDInit andSpotName:(NSString*)spotNameInit andOp:(AsyncBlockOperation*)op;
-(void)startWeatherDownloadForLoc:(CLLocation*)locInit andSpotID:(int)spotID andSpotName:(NSString*)spotNameInit andOp:(AsyncBlockOperation*)op;

-(void)startTideDataDownloadForCounty:(NSString*)countyInit andOp:(AsyncBlockOperation*)op;
-(void)startWindDataDownloadForCounty:(NSString*)countyInit andOp:(AsyncBlockOperation*)op;
-(void)startSwellDataDownloadForCounty:(NSString*)countyInit andOp:(AsyncBlockOperation*)op;
-(void)startWaterTempDownloadForCounty:(NSString*)countyInit andOp:(AsyncBlockOperation*)op;


-(void)getNearBySpots:(NSString*)latInit andLon:(NSString*)lonInit;
-(void)getAllSpotsAndCounties;

@end

#endif /* DataSource_h */
