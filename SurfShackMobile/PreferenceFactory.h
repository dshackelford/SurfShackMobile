//
//  PreferenceFactory.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/23/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpitcastData.h"
#import "DataHandler.h"
#import "AppUtilities.h"
#import "CountyHandler.h"

//k is for key
#define kUserName @"UserName"
#define kShortDataLength @"ShortDataLength"
#define kLongDataLength @"LongDataLength"
#define kSurfDataProvider @"SurfDataProvider"
#define kColorScheme @"ColorScheme"
#define kScreenSizeWidth @"ScreenSizeWidth"
#define kScreenSizeHeight @"ScreenSizeHeight"

@interface PreferenceFactory :NSObject
{
    
}

+(id<DataHandler>)getDataService;
+(NSString*)getIndicatorStrForHeight;
+(NSString*)getIndicatorStrForSpeed;

+(NSArray*)getSpotFavorites;
+(void)writeSpotToFavorites:(NSString*)spotNameInit andID:(NSString*)spotIDInit;
+(void)removeSpotFromFavotiesWithID:(NSString*)spotIDInit;

+(NSArray*)getAllSpots;

+(NSString*)getSpotNameFromSpotID:(NSString*)spotID;

+(NSDictionary*)getDataProviderNames;

+(int)getShortRange;
+(int)getLongRange;

+(void)setLongRange:(int)rangeInit;
+(void)setShortRange:(int)rangeInit;

+(NSDictionary*)getPreferences;

+(NSString*)getColorPreference;
+(void)setColorPreference:(NSString*)colorStr;

@end
