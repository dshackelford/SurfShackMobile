//
//  OfflineData.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 10/17/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OfflineData.h"

@implementation OfflineData
/*
-(id)init
{
    self = [super init];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[AppUtilities getPathToOfflineData]];
    
    if(![db open])
    {
        
    }
    
    //bool success = [db executeStatements:sql];
    
    return self;
}
*/
//Saves a current dict for a reportView controller with the key that is the spitcast ID number
+(void)saveSpotDict:(NSMutableDictionary*)aSpotDict withID:(int)idInit
{
    NSLog(@"path: %@",[AppUtilities getPathToOfflineData]);
    
    NSMutableDictionary* offlineDict = [NSMutableDictionary dictionary ];
    //get offlineDict from file
    if([AppUtilities doesFileExistAtPath:[AppUtilities getPathToOfflineData]])
    {
    
        offlineDict = [NSMutableDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToOfflineData]];
    }
    else
    {
        //make the offline file
        NSFileManager* appInfo = [NSFileManager defaultManager];
         [appInfo createFileAtPath:[AppUtilities getPathToOfflineData] contents:nil attributes:nil];
    }
     offlineDict = [NSMutableDictionary dictionary ];
    NSString* idStr = [NSString stringWithFormat:@"%i",idInit];
    
    [offlineDict removeObjectForKey:idStr];
    
    [offlineDict setObject:aSpotDict forKey:idStr];
    
    [offlineDict writeToFile:[AppUtilities getPathToOfflineData] atomically:YES];
}

@end
