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

-(void)writeDictToFile
{
    
}

@end
