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
@interface DBQueries : NSObject

+(NSMutableArray*)getSpotFavorites;
+(NSMutableArray*)getCountyFavorites;
+(NSMutableArray*)getSpotNameFavorites;
+(NSString*)getSpotNameOfSpotID:(int)idInit;
+(int)getCountOfAllSpots;
+(NSMutableArray*)getAllCounties;

//Table adjustments
+(Boolean)addSpotID:(int)spotIDInit SpotName:(NSString*)spotNameInit andCounty:(NSString*)spotCountyInit withLat:(double)latInit andLon:(double)lonInit;

//Query Sting
+(NSString*)countOfFavoriteSpots;
+(NSString*)getCountyOfSpotID:(int)idInit;

+(NSString*)getSpotFavoritesQuery;
@end
#endif /* DBQueries_h */
