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
    //[aSpotDict removeObjectForKey:@"swell"];

    NSURL* url = [NSURL fileURLWithPath:[AppUtilities getPathToOfflineData]];
    
    if (@available(iOS 11.0, *)) {
        NSMutableDictionary* offlineDict = [[NSMutableDictionary alloc] initWithContentsOfURL:url error:nil];
        
        if(offlineDict == nil)
        {
            offlineDict = [NSMutableDictionary dictionary];
        }
        NSString* idStr = [NSString stringWithFormat:@"%i",idInit];
        
        [offlineDict removeObjectForKey:idStr];
        
        [offlineDict setObject:aSpotDict forKey:idStr];
        
        /*
        NSMutableDictionary* swellDict = [aSpotDict objectForKey:@"swell"];
        NSMutableArray* swellArray = [swellDict objectForKey:@"swellArray"];
        
        for(NSMutableArray* daySwellArray in swellArray)
        {
            for(int i = 0; i < [daySwellArray count]; i = i + 1)
            {
                NSMutableDictionary* hourSwellDict = [daySwellArray objectAtIndex:i];
                
                NSMutableArray* hourSubSwellArray = [hourSwellDict objectForKey:@"hourSwellDict"];
                for(int j =0; j < [hourSubSwellArray count]; j = j + 1)
                {
                    NSMutableDictionary* subSwellDict = [hourSubSwellArray objectAtIndex:j];
                    
                    for(id obj in [subSwellDict allValues])
                    {
                        if([obj isEqual:[NSNull null]])
                        {
                            NSLog(@"need to remove this");
                        }
                    }
                }
            }
        }
        */
        [offlineDict writeToURL:url error:nil];
    }
    else
    {
        // Fallback on earlier versions
    }
}

+(NSMutableDictionary*)getOfflineDataForID:(int)idInit
{
    NSString* idStr = [NSString stringWithFormat:@"%i",idInit];
    
    NSMutableDictionary* offlineDict = [NSMutableDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToOfflineData]];
    
    NSMutableDictionary* spotDict = [offlineDict objectForKey:idStr];
    
    return spotDict;
}



@end
