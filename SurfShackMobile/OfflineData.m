//
//  OfflineData.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 10/17/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OfflineData.h"
#import "FMDB.h"

@implementation OfflineData

//Saves a current dict for a reportView controller with the key that is the spitcast ID number
+(void)saveSpotDict:(NSMutableDictionary*)aSpotDict withID:(int)idInit
{
    NSLog(@"path: %@",[AppUtilities getPathToOfflineData]);
    
    //remove non-textual data for storage
    [aSpotDict removeObjectForKey:@"swellDict"];

    NSMutableDictionary* offlineDict = [NSMutableDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToOfflineData]];
    
    if(offlineDict == nil)
    {
        offlineDict = [NSMutableDictionary dictionary];
    }
    NSString* idStr = [NSString stringWithFormat:@"%i",idInit];
    
    [offlineDict removeObjectForKey:idStr];
    
    [offlineDict setObject:aSpotDict forKey:idStr];
    
    [offlineDict writeToFile:[AppUtilities getPathToOfflineData] atomically:YES];
}

+(NSMutableDictionary*)getOfflineDataForID:(int)idInit
{
    NSString* idStr = [NSString stringWithFormat:@"%i",idInit];
    
    NSMutableDictionary* offlineDict = [NSMutableDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToOfflineData]];
    
    NSMutableDictionary* spotDict = [offlineDict objectForKey:idStr];
    
    return spotDict;
}



@end
