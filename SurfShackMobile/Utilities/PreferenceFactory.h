//
//  PreferenceFactory.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/23/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataSource.h"
#import "AppUtilities.h"
#import "CountyHandler.h"
#import "DataCollector.h"

//k is for key
#define kUserName @"UserName"
#define kShortDataLength @"ShortDataLength"
#define kLongDataLength @"LongDataLength"
#define kSurfDataProvider @"SurfDataProvider"
#define kColorScheme @"ColorScheme"
#define kScreenSizeWidth @"ScreenSizeWidth"
#define kScreenSizeHeight @"ScreenSizeHeight"
#define kHeightUnit @"heightUnit"
#define kSpeedUnit @"speedUnit"

@interface PreferenceFactory :NSObject
{
    
}

+(id<DataSource>)getDataServiceWithCollector:(id<DataCollector>)collectorInit;

+(id<DataSource>)getWeatherServiceWithCollector:(id<DataCollector>)collectorInit;

+(NSDictionary*)getDataProviderNames;

+(int)getShortRange;
+(int)getLongRange;

+(void)setLongRange:(int)rangeInit;
+(void)setShortRange:(int)rangeInit;

+(NSString*)getIndicatorStrForHeight;
+(NSString*)getIndicatorStrForSpeed;
+(void)setIndicatorStrForHeight:(NSString*)indicatorStr;
+(void)setIndicatorStrForSpeed:(NSString*)indicatorStr;

+(NSDictionary*)getPreferences;

+(NSString*)getColorPreference;
+(void)setColorPreference:(NSString*)colorStr;

@end
