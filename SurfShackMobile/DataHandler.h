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

//@required
//this is the main one that will be called from the report view for the rest of the views
-(void)getDataForLocations:(NSArray*)arrOfLocs;
-(NSMutableDictionary*)getDataDict;

//this is the method that will be called for the first report view on a different thread then the the rest of the spots.
-(NSDictionary*)getDataForLocation:(int)locInit;

//the dictionary returned will be under the key of the spotID.
//there will be arrays for surfData/tideData/windData/units

-(NSMutableArray*)getNearBySpots:(NSString*)latInit andLon:(NSString*)lonInit;
-(NSMutableArray*)getAllSpotsAndCounties;

-(NSMutableArray*)getShorternedVersionOfArray:(NSMutableArray*)arrInit ofLength:(int)rangeInit;
-(NSMutableArray*)getShorternedVersionOfXValArray:(NSMutableArray*)arrInit ofLength:(int)rangeInit;


-(int)getShortRange;
-(int)getLongRangt;
-(void)setShortRange:(int)rangeInit;
-(void)setLongRange:(int)rangeInit;



@end