//
//  CountyHandler.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/24/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CountyHandler.h"


@implementation CountyHandler

+(NSString*)getCountyOfSpot:(int)locInit
{
//    if ([AppUtilities doesFileExistAtPath:[AppUtilities getPathToCountiesFile]] == NO)
//    {
//        //counties file and all spot file are tied together, by creating the counties, you are creating the all spot file
//        [CountyHandler createCountiesFile];
//    }
//    
//    //now to get the county of need, i have a location number
//    NSMutableDictionary* countyDict = [NSMutableDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToCountiesFile]];
////    NSMutableDictionary* allSpotDict = [NSMutableDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToAllSpotFile]];
//    
//    NSString* county = [countyDict valueForKey:[NSString stringWithFormat:@"%d",locInit]];

    DBManager* db = [[DBManager alloc] init];
    [db openDatabase];
    
    NSString* county = [db newGetCountyOfSpotID:locInit];
    
    [db closeDatabase];
    
    return [self moldStringForURL:county];
}

//creates both the all spot file and spot/county file
+(void)createCountiesFile
{
    id<DataHandler> dataService = [PreferenceFactory getDataService];
    NSMutableArray* allSpotData = [dataService getAllSpotsAndCounties];
    
    DBManager* db = [[DBManager alloc] init];
    
    [db openDatabase];
    
    for (CountyInfoPacket* spotData in allSpotData)
    {
        [db addSpotID:[spotData getSpotID] SpotName:[spotData getSpotName] andCounty:[spotData getCountyName] withLat:[spotData getLat] andLon:[spotData getLat]];
    }

    [db closeDatabase];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"AddedSpotsToDB" object:nil];
//
//    NSString* aCounty = [[NSString alloc] init];
//
//    NSMutableDictionary* countyDict = [[NSMutableDictionary alloc] init];
//    NSMutableDictionary* allSpotDict =[[NSMutableDictionary alloc] init];
//    
//    for (int i = 0; i < [allSpotData count]; i++)
//    {
//        aCounty = [[allSpotData objectAtIndex:i] getCountyName];
//
//        NSString* aSpot = [[allSpotData objectAtIndex:i] getSpotName];
//        NSString* aSpotId = [NSString stringWithFormat:@"%d",[[allSpotData objectAtIndex:i] getSpotID]];
//        [allSpotDict setValue:aSpot forKey:aSpotId];
//
//        [countyDict setValue:aCounty forKey:aSpotId];
//    }
//
//    NSFileManager* appInfo = [NSFileManager defaultManager];
//    [appInfo createFileAtPath:[AppUtilities getPathToAllSpotFile] contents:nil attributes:nil];
//    [allSpotDict writeToFile:[AppUtilities getPathToAllSpotFile] atomically:YES];
//    
//    [appInfo createFileAtPath:[AppUtilities getPathToCountiesFile] contents:nil attributes:nil];
//    [countyDict writeToFile:[AppUtilities getPathToCountiesFile] atomically:YES];
}

+(NSString*)moldStringForURL:(NSString*)strInit
{
    NSString* lowCase = [strInit lowercaseString];
    if ( [[lowCase componentsSeparatedByString:@" "] count] > 1)
    {
        lowCase = [lowCase stringByReplacingOccurrencesOfString:@" " withString:@"-"];
    }
    return lowCase;
}

@end