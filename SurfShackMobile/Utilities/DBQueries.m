//
//  DBQueries.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/8/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBQueries.h"

@implementation DBQueries

+(NSString*)countOfFavoriteSpots
{
    return [NSString stringWithFormat:@"SELECT count(*) FROM SpitcastSpots WHERE SpotFavorite = 1"];
}
+(NSString*)getCountyOfSpotID:(int)idInit
{
    return [NSString stringWithFormat:@"SELECT spotCounty FROM SpitcastSpots WHERE SpotID = %d",idInit];
}

@end
