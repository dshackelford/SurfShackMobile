//
//  CountyHandler.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/24/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CountyHandler.h"
#import "DBQueries.h"

@implementation CountyHandler

+(NSString*)getCountyOfSpot:(int)locInit
{
    FMDatabase* fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    
    
    NSString* county = @"unkown";
    if([fmdb open])
    {
        FMResultSet* set = [fmdb executeQuery:[DBQueries getCountyOfSpotID:locInit]];
        
        while([set next])
        {
            county = [set stringForColumn:@"spotCounty"];
        }
    }
    [fmdb close];
    
    return [self moldStringForURL:county];
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
