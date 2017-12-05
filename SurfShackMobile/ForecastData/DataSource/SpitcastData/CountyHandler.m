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
    DBManager* db = [[DBManager alloc] init];
    [db openDatabase];
    
    NSString* county = [db getCountyOfSpotID:locInit];
    
    [db closeDatabase];
    
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
