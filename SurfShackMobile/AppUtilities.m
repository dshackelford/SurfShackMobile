//
//  AppUtilities.m
//  Checkers
//
//  Created by Dylan Shackelford on 7/9/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//
#import <Foundation/Foundation.h>
#import "AppUtilities.h"


@implementation AppUtilities

#pragma mark - File Utitlies
+(NSString*)getPathToUserInfoFile
{
    NSString* homeDirectoryString = NSHomeDirectory();
    NSString* pathToUserInfoFile = [homeDirectoryString stringByAppendingPathComponent:@"/Documents/userInfo"];
    return pathToUserInfoFile;
}

+(NSString*)getPathToSurfDataFile
{
    NSString* homeDirectoryString = NSHomeDirectory();
    NSString* pathToSurfDataFile = [homeDirectoryString stringByAppendingPathComponent:@"/Documents/surfData"];
    return pathToSurfDataFile;
}

+(NSString*)getPathToAllSpotFile
{
    NSString* homeDirectoryString = NSHomeDirectory();
    NSString* pathToSurfDataFile = [homeDirectoryString stringByAppendingPathComponent:@"/Documents/allSpots"];
    return pathToSurfDataFile;
}

+(NSString*)getPathToMonthFile
{
    NSString* homeDirectoryString = NSHomeDirectory();
    NSString* pathToSurfDataFile = [homeDirectoryString stringByAppendingPathComponent:@"/Documents/months"];
    return pathToSurfDataFile;
}

+(NSString*)getPathToPreferenceFile
{
    NSString* homeDirectoryString = NSHomeDirectory();
    NSString* pathToSurfDataFile = [homeDirectoryString stringByAppendingPathComponent:@"/Documents/preferences"];
    return pathToSurfDataFile;
}

+(NSString*)getPathToCountiesFile
{
    NSString* homeDirectoryString = NSHomeDirectory();
    NSString* pathToSurfDataFile = [homeDirectoryString stringByAppendingPathComponent:@"/Documents/counties"];
    return pathToSurfDataFile;
}

+(NSString*)getPathToFavoriteSpots
{
    NSString* homeDirectoryString = NSHomeDirectory();
    NSString* pathToSurfDataFile = [homeDirectoryString stringByAppendingPathComponent:@"/Documents/favoriteSpots"];
    return pathToSurfDataFile;
}

+(NSString*)getPathToDataProviderNames
{
    NSString* homeDirectoryString = NSHomeDirectory();
    NSString* pathToSurfDataFile = [homeDirectoryString stringByAppendingPathComponent:@"/Documents/dataProviders"];
    return pathToSurfDataFile;
}

+(NSString*) getPathToAppDatabase
{
    NSString* basePath = NSHomeDirectory();
    
    NSString* newPath = [basePath stringByAppendingPathComponent:@"Documents/SpitcastDatabase.sqlite"];
    return newPath;
}


+(void)addFileNameInPath:(NSString*)path
{
    NSFileManager* appInfo = [NSFileManager defaultManager];
    
    [appInfo createFileAtPath:path contents:nil attributes:nil];
}

+(BOOL)doesFileExistAtPath:(NSString *)path
{
    BOOL exists = [[NSFileManager defaultManager] fileExistsAtPath:path];
    return exists;
}

+(BOOL)doesThisFileExistOnGitHub
{
    return YES;
}

+(NSString*)getOpenWeatherKey
{
    return @"481f39c90c0b12397c3177c8c09ce3cf";
}



@end
