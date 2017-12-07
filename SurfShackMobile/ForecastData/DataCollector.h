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

-(void)surfDataDictReceived:(NSMutableDictionary*)surfData;
-(void)tideDataDictReceived:(NSMutableDictionary*)tideData;
-(void)windDataDictReceived:(NSMutableDictionary*)windData;
-(void)swellDataDictReceived:(NSMutableDictionary*)windData;


- (void)weatherDataDictReceived:(NSMutableDictionary *)weatherData;
- (void)waterTempDataDictReceived:(NSMutableDictionary *)waterTempData;

-(void)countyAndSpotsReceived:(NSMutableArray*)countiesArray;
-(void)nearbySpotsReceived:(NSMutableArray*)nearbySpotsArray;
@end

#endif /* DataCollecter_h */
