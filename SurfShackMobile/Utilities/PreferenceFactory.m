//
//  PreferenceFactory.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/23/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "PreferenceFactory.h"
#import "SpitcastData.h"

@implementation PreferenceFactory

+(id<DataSource>)getDataServiceWithCollector:(id<DataCollector>)collectorInit
{
    NSDictionary* prefs = [PreferenceFactory getPreferences];
    
    NSString* surfDataProvider = [prefs objectForKey:kSurfDataProvider];
    
    if ([surfDataProvider isEqualToString:@"Spitcast"])
    {
        int shortRange = [[prefs objectForKey:kShortDataLength] intValue];
        int longRange = [[prefs objectForKey:kLongDataLength] intValue];
        
        id<DataSource> aSpitcastAcc = [[SpitcastData alloc] initWithShortLength:shortRange andLongLength:longRange andCollector:collectorInit];
        return aSpitcastAcc;
    }
    //else if(surfDataProvider isEqualToString:@"MagicSeaweed")
    
    return nil;
}

+(NSString*)getIndicatorStrForHeight
{
    if ([AppUtilities doesFileExistAtPath:[AppUtilities getPathToPreferenceFile]] == NO)
    {
        [PreferenceFactory createPreferences];
    }
    
    NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    NSString* heightUnit = [NSString stringWithFormat:@"%@",[prefDict objectForKey:kHeightUnit]];
    if([heightUnit isEqual:[NSNull null]])
    {
        return @"ft"; //catch all
    }
    else
    {
        return heightUnit;
    }
}

+(NSString*)getIndicatorStrForSpeed
{
    if ([AppUtilities doesFileExistAtPath:[AppUtilities getPathToPreferenceFile]] == NO)
    {
        [PreferenceFactory createPreferences];
    }
    
    NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    NSString* speedUnit = [NSString stringWithFormat:@"%@",[prefDict objectForKey:kSpeedUnit]];
    
    if([speedUnit isEqualToString:@""])
    {
        return @"mph"; //catch all
    }
    else
    {
        return speedUnit;
    }
}

+(int)getShortRange
{
    if ([AppUtilities doesFileExistAtPath:[AppUtilities getPathToPreferenceFile]] == NO)
    {
        [PreferenceFactory createPreferences];
    }
    
    NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    int shortRange = [[prefDict objectForKey:kShortDataLength] intValue];
    return shortRange;
}

+(int)getLongRange
{
    if ([AppUtilities doesFileExistAtPath:[AppUtilities getPathToPreferenceFile]] == NO)
    {
        [PreferenceFactory createPreferences];
    }
    
    NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    int longRange = [[prefDict objectForKey:kLongDataLength] intValue];
    return longRange;
}

#pragma mark - Setters
+(void)setIndicatorStrForHeight:(NSString*)indicatorStr
{
    //preferenes will have already been created to select the day range before the user will set it
    NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    
    [prefDict setValue:indicatorStr forKey:kHeightUnit];
    
    [prefDict writeToFile:[AppUtilities getPathToPreferenceFile] atomically:YES];
}

+(void)setIndicatorStrForSpeed:(NSString*)indicatorStr
{
    //preferenes will have already been created to select the day range before the user will set it
    NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    
    [prefDict setValue:indicatorStr forKey:kSpeedUnit];
    
    [prefDict writeToFile:[AppUtilities getPathToPreferenceFile] atomically:YES];
}

+(void)setShortRange:(int)rangeInit
{
    //preferenes will have already been created to select the day range before the user will set it
     NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    
    [prefDict setValue:[NSNumber numberWithInteger:rangeInit] forKey:kShortDataLength];
    
    [prefDict writeToFile:[AppUtilities getPathToPreferenceFile] atomically:YES];
}

+(void)setLongRange:(int)rangeInit
{
    //preferenes will have already been created to select the day range before the user will set it
    NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    
    [prefDict setValue:[NSNumber numberWithInteger:rangeInit] forKey:kLongDataLength];
    
    [prefDict writeToFile:[AppUtilities getPathToPreferenceFile] atomically:YES];
}

+(void)setColorPreference:(NSString*)colorStr
{
    NSLog(@"%@",[AppUtilities getPathToPreferenceFile]);
    
    NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    
    [prefDict setValue:colorStr forKey:kColorScheme];
    
    [prefDict writeToFile:[AppUtilities getPathToPreferenceFile] atomically:YES];
}

+(NSString*)getColorPreference
{
    NSDictionary* prefDict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    
    return [prefDict objectForKey:kColorScheme];
}


+(NSDictionary*)getPreferences
{
    if ([AppUtilities doesFileExistAtPath:[AppUtilities getPathToPreferenceFile]] == NO)
    {
        return [PreferenceFactory createPreferences];
    }
    
     NSDictionary* dict = [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToPreferenceFile]];
    
    [dict setValue:[PreferenceFactory getUIColorForKey:[dict objectForKey:kColorScheme]] forKey:kColorScheme];
    return dict;
}

+(NSDictionary*)createPreferences
{
    NSFileManager* appInfo = [NSFileManager defaultManager];
    
    [appInfo createFileAtPath:[AppUtilities getPathToPreferenceFile] contents:nil attributes:nil];
    
    //ADDING TO THE DICTIONARY SHOULD HAPPEN IN THE SETTINGS
    
    NSArray* keys=@[kUserName,kShortDataLength,kLongDataLength,kSurfDataProvider,kColorScheme,kScreenSizeWidth,kScreenSizeHeight,kHeightUnit,kSpeedUnit];
    
//    UIColor* color = [PreferenceFactory getUIColorForKey:@"Blue"];
    NSArray* objects=@[@"",@3,@6,@"Spitcast",@"Blue",@1,@1,@"ft",@"mph"];
    
    NSMutableDictionary* myDictionary =[[NSMutableDictionary alloc] initWithObjects:objects forKeys:keys];
    
//    [myDictionary setValue:[PreferenceFactory getUIColorForKey:[myDictionary objectForKey:kColorScheme]] forKey:kColorScheme];
    
    [myDictionary writeToFile:[AppUtilities getPathToPreferenceFile] atomically:YES ];
    
    NSDictionary* dict = [NSDictionary dictionaryWithDictionary:myDictionary];
    
    return dict;
}

+(UIColor*)getUIColorForKey:(NSString*)colorKey
{
    //i may need to make a dictionary to handle the sub colors for the plot and markers. i.e. accent colors
    UIColor* color;
    //******
    //alpha was 0.1 and working fine until i wanted the datapoint circles to be darker!!
    //******
    if ([colorKey isEqualToString: @"Red"])
    {
       color= [UIColor colorWithRed:255/255.f green:40/255.f blue:40/255.f alpha:1];
    }
    else if([colorKey isEqualToString: @"Green"])
    {
        color = [UIColor colorWithRed:109/255.f green:170/255.f blue:107/255.f alpha:1];
    }
    else if([colorKey isEqualToString: @"Blue"])
    {
        color =[UIColor colorWithRed:22/255.f green:119/255.f blue:205/255.f alpha:1];
    }
    else if([colorKey isEqualToString: @"Tan"])
    {
        color = [UIColor colorWithRed:226/255.f green:216/255.f blue:148/255.f alpha:1];
    }
    else if([colorKey isEqualToString: @"Grey"])
    {
        color = [UIColor colorWithRed:176/255.f green:176/255.f blue:176/255.f alpha:1];
    }

    return color;
}


+(NSDictionary*)getDataProviderNames
{
    if([AppUtilities doesFileExistAtPath:[AppUtilities getPathToDataProviderNames]])
    {
        return [NSDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToDataProviderNames]];
    }
    else
    {
        NSDictionary* dict = [[NSDictionary alloc] initWithObjects:@[@"Spitcast is the surf forecasting website I've been using for years to know where and when to go for the best surf near me. Jack Muhlis was gracious enough to have an open API restful downloads of his surf prediction algorithm for spots from southern san diego to san francisco. His website is awesome, go check it out!", @"OpenWeather.com is a super cool website that provides current and forecasted weather data for cities all over the world, some free and some paid. They are a super cool website that is so easy to use, I highly recommend you check them out if you looking for weather data in any project you are working on!"] forKeys:@[@"Spitcast.com",@"OpenWeatherAPI.com"]];
        
        [dict writeToFile:[AppUtilities getPathToDataProviderNames] atomically:YES];
        
        return dict;
    }
}
@end
