//
//  DataHandler.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/20/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "CoreLocation/CoreLocation.h"

@protocol DataHandler <NSObject>

-(NSMutableDictionary*)getSurfDataForLocation:(int)locInit;
-(NSMutableDictionary*)getWindDataForCounty:(NSString*)countyInit;
-(NSMutableDictionary*)getTideDataForCounty:(NSString*)countyInit;
-(double)getWaterTempForCounty:(NSString*)countyInit;
-(NSMutableArray*)getSwellDataForCounty:(NSString *)countyInit;

-(NSMutableArray*)getNearBySpots:(NSString*)latInit andLon:(NSString*)lonInit;
-(NSMutableArray*)getAllSpotsAndCounties;

//could these be fixed with properties?
-(int)getShortRange;
-(int)getLongRange;
-(void)setShortRange:(int)rangeInit;
-(void)setLongRange:(int)rangeInit;

@end
