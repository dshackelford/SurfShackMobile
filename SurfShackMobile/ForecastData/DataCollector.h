//
//  DataCollecter.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 11/29/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#ifndef DataCollecter_h
#define DataCollecter_h

@protocol DataCollector

@optional
-(void)surfDataDictReceived:(NSMutableDictionary*)surfData forSpot:(NSString*)spotNameInit;
- (void)weatherDataDictReceived:(NSMutableDictionary *)weatherData forSpot:(NSString*)spotNameInit;

-(void)tideDataDictReceived:(NSMutableDictionary*)tideData forCounty:(NSString*)countyNameInit;
-(void)windDataDictReceived:(NSMutableDictionary*)windData forCounty:(NSString*)countyNameInit;
-(void)swellDataDictReceived:(NSMutableDictionary*)windData forCounty:(NSString*)countyNameInit;
- (void)waterTempDataDictReceived:(NSMutableDictionary *)waterTempData  forCounty:(NSString*)countyNameInit;

-(void)countyAndSpotsReceived:(NSMutableArray*)countiesArray;
-(void)nearbySpotsReceived:(NSMutableArray*)nearbySpotsArray;

@end

#endif /* DataCollecter_h */
