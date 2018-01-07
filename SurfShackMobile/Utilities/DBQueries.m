//
//  DBQueries.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/8/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DBQueries.h"
#import <FMDB/FMDB.h>
#import "AppUtilities.h"

@implementation DBQueries

+(NSString*)getSpotNameOfSpotID:(int)idInit
{
    NSString* spotName = nil;
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        
        FMResultSet* set = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT SpotName FROM SpitcastSpots WHERE SpotID = %d",idInit]];
        
        while([set next])
        {
            spotName = [set stringForColumn:@"SpotName"];
        }
    }
    [fmdb close];
    
    return spotName;
}

+(NSMutableArray*)getSpotFavorites
{
    NSMutableArray* arrOfSpots = [NSMutableArray array];
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        
        FMResultSet* set = [fmdb executeQuery:[self getSpotFavoritesQuery]];
        while([set next])
        {
            double spotId = [set intForColumn:@"SpotID"];
            [arrOfSpots addObject:[NSNumber numberWithDouble:spotId]];
        }
    }
    [fmdb close];
    
    return arrOfSpots;
}

+(int)getCountOfSpotFavorites
{
    int count = 0;
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        FMResultSet* set = [fmdb executeQuery:@"SELECT count(*) FROM SpitcastSpots WHERE SpotFavorite = 1"];
        while([set next])
        {
            count = [set intForColumn:@"count(*)"];
        }
    }
    [fmdb close];
    
    return count;
}

+(NSMutableArray*)getCountyFavorites
{
    NSMutableArray* arrOfCounties = [NSMutableArray array];
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        
        FMResultSet* set = [fmdb executeQuery:@"SELECT * FROM SpitcastSpots WHERE SpotFavorite = 1 GROUP BY SpotCounty"];
        while([set next])
        {
            NSString* countyName = [set stringForColumn:@"SpotCounty"];
            [arrOfCounties addObject:countyName];
        }
    }
    [fmdb close];
    
    return arrOfCounties;
}

+(NSMutableArray*)getAllCounties
{
    NSMutableArray* arrOfCounties = [NSMutableArray array];
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        
        FMResultSet* set = [fmdb executeQuery:@"SELECT * FROM SpitcastSpots GROUP BY SpotCounty ORDER BY SpotLAT DESC"];
        while([set next])
        {
            NSString* countyName = [set stringForColumn:@"SpotCounty"];
            [arrOfCounties addObject:countyName];
        }
    }
    [fmdb close];
    
    return arrOfCounties;
}

+(NSMutableArray*)getSpotNameFavorites
{
    NSMutableArray* arrOfSpotFavoriteNames = [NSMutableArray array];
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        
        FMResultSet* set = [fmdb executeQuery:@"SELECT SpotName FROM SpitcastSpots WHERE SpotFavorite = 1"];
        while([set next])
        {
            NSString* spotName = [set stringForColumn:@"SpotName"];
            [arrOfSpotFavoriteNames addObject:spotName];
        }
    }
    [fmdb close];
    
    return arrOfSpotFavoriteNames;
}

+(NSMutableArray*)getSpotsInCounty:(NSString*)countyInit
{
    NSMutableArray* spots = [NSMutableArray array];
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        FMResultSet* set = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotCounty LIKE '%%%@%%' ORDER BY SpotLat DESC",countyInit]];
        while([set next])
        {
            NSString* spotName = [set stringForColumn:@"SpotName"];
            [spots addObject:spotName];
        }
    }
    [fmdb close];
    
    return spots;
    
}

+(NSMutableArray*)getSpotNamesFromSearchString:(NSString*)searchString
{
    NSMutableArray* spots = [NSMutableArray array];
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        FMResultSet* set = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotName LIKE '%%%@%%'",searchString]];
        while([set next])
        {
            NSString* spotName = [set stringForColumn:@"SpotName"];
            [spots addObject:spotName];
        }
    }
    [fmdb close];
    
    return spots;
}

+(int)getCountOfAllSpots
{
    int count = 0;
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        
        FMResultSet* set = [fmdb executeQuery:@"SELECT count(*) FROM SpitcastSpots"];
        while([set next])
        {
            count = [set intForColumn:@"count(*)"];
        }
    }
    [fmdb close];
    
    return count;
}

+(CLLocation*)getLocationOfSpot:(int)idInit
{
    CLLocation* aLoc;
    
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        FMResultSet* set = [fmdb executeQuery:[NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotID = %d",idInit]];
        while([set next])
        {
            double lat = [set doubleForColumn:@"SpotLat"];
            double lon = [set doubleForColumn:@"SpotLon"];
            aLoc = [[CLLocation alloc] initWithLatitude:lat longitude:lon];
        }
    }
    [fmdb close];

    return aLoc;
}

#pragma mark - Update Database
+(void)addSpitcastTable
{
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    
    if([fmdb open])
    {
        bool isTable = [fmdb tableExists:@"SpitcastSpots"];
        if(!isTable)
        {
            NSLog(@"no table, need to CREATE TABLE");
            [fmdb executeUpdate:@"CREATE TABLE IF NOT EXISTS SpitcastSpots (SpotID int NOT NULL PRIMARY KEY ON CONFLICT REPLACE UNIQUE, SpotName text, SpotCounty text, SpotLat double DEFAULT 0.0, SpotLon double DEFAULT 0.0, SpotFavorite boolean DEFAULT false)"];
        }
    }
    [fmdb close];
}
+(Boolean)addSpotID:(int)spotIDInit SpotName:(NSString*)spotNameInit andCounty:(NSString*)spotCountyInit withLat:(double)latInit andLon:(double)lonInit
{
    NSMutableString* sql = [NSMutableString stringWithString:@"INSERT INTO SpitcastSpots "];
    
    [sql appendString:@"(SpotID,SpotName,SpotCounty,SpotLat,SpotLon)"];
    [sql appendString:@" VALUES("];
    [sql appendFormat:@"'%d',",spotIDInit];
    [sql appendFormat:@"'%@',",spotNameInit];
    [sql appendFormat:@"'%@',",spotCountyInit];
    [sql appendFormat:@"'%f',",latInit];
    [sql appendFormat:@"'%f'",lonInit];
    [sql appendString:@" )"];
    
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    
    if([fmdb open])
    {
        FMResultSet* set = [fmdb executeQuery:sql];
        NSError* error;
        while([set nextWithError:&error])
        {
            if(error)
            {
                NSLog(@"error found");
            }
        }
    }

    [fmdb close];
    
    return true;
}

+(void)setSpot:(NSString*)spotNameInit toFav:(BOOL)favInit
{
    NSString* sql;
    
    if (favInit == true)
    {
        sql = [NSString stringWithFormat:@"UPDATE SpitcastSpots SET SpotFavorite = 1 WHERE SpotName = '%@'",spotNameInit];
    }
    else
    {
        sql = [NSString stringWithFormat:@"UPDATE SpitcastSpots SET SpotFavorite = 0 WHERE SpotName = '%@'",spotNameInit];
    }
    
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    
    if([fmdb open])
    {
        [fmdb executeUpdate:sql];
    }
    
    [fmdb close];
    
}


+(NSString*)countOfFavoriteSpots
{
    return [NSString stringWithFormat:@"SELECT count(*) FROM SpitcastSpots WHERE SpotFavorite = 1"];
}
+(NSString*)getCountyOfSpotID:(int)idInit
{
    return [NSString stringWithFormat:@"SELECT spotCounty FROM SpitcastSpots WHERE SpotID = %d",idInit];
}
+(NSString*)getSpotFavoritesQuery
{
    return [NSString stringWithFormat: @"SELECT * FROM SpitcastSpots WHERE SpotFavorite = 1"];
}

@end
