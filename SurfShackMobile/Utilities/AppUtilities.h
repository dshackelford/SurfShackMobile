//
//  AppUtilities.h
//  Checkers
//
//  Created by Dylan Shackelford on 7/9/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>

//k is for key
#define kMags @"mags"
//#define kMagsShort @"magsShort"
#define kDayArr @"dayArr"
//#define kDayArrShort @"darArrShort"

#define kIndicatorStr @"inidicatorStr"

#define kSurfDict @"surfDict"
#define kWindDict @"windDict"
#define kTideDict @"tideDict"


@interface AppUtilities : NSObject
{
    
}

+(NSString*)getPathToUserInfoFile;
+(NSString*)getPathToSurfDataFile;
+(NSString*)getPathToMonthFile;
+(NSString*)getPathToAllSpotFile;
+(NSString*)getPathToPreferenceFile;
+(NSString*)getPathToCountiesFile;
+(NSString*)getPathToFavoriteSpots;
+(NSString*)getPathToDataProviderNames;

+(NSString*) getPathToAppDatabase;
+(NSString*)getPathToOfflineData;
+(NSString*)getPathToOfflineDatabase;

+(void)addFileNameInPath:(NSString*)path;

+(BOOL)doesFileExistAtPath: (NSString*)path;

+(NSString*)getOpenWeatherKey;

@end
