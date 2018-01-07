//
//  DBQueries.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/8/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#ifndef DBQueries_h
#define DBQueries_h

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface DBQueries : NSObject

//Arrays
+(NSMutableArray*)getSpotFavorites;
+(NSMutableArray*)getCountyFavorites;
+(NSMutableArray*)getSpotNameFavorites;
+(NSMutableArray*)getAllCounties;
+(NSMutableArray*)getSpotsInCounty:(NSString*)countyInit;
+(NSMutableArray*)getSpotNamesFromSearchString:(NSString*)searchString;

//Counts
+(int)getCountOfSpotFavorites;
+(int)getCountOfAllSpots;;

//Strings
+(NSString*)getSpotNameOfSpotID:(int)idInit;

+(CLLocation*)getLocationOfSpot:(int)idInit;

//Update Database
+(Boolean)addSpotID:(int)spotIDInit SpotName:(NSString*)spotNameInit andCounty:(NSString*)spotCountyInit withLat:(double)latInit andLon:(double)lonInit;
+(void)addSpitcastTable;
+(void)setSpot:(NSString*)spotNameInit toFav:(BOOL)favInit;

//Query Sting
+(NSString*)countOfFavoriteSpots;
+(NSString*)getCountyOfSpotID:(int)idInit;

+(NSString*)getSpotFavoritesQuery;
@end
#endif /* DBQueries_h */
