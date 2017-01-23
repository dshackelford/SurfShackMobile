//
//  SpitcastData.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/12/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//
#import "AppUtilities.h"
#import "DataHandler.h"
#import "DateHandler.h"
#import "CountyHandler.h"

#import "SurfPacket.h"
#import "CountyInfoPacket.h"
#import "WindPacket.h"
#import "TidePacket.h"
#import "NearByPacket.h"
#import "SwellPacket.h"
#import "WaterTempPacket.h"


#import "DBManager.h"

@interface SpitcastData : NSObject <DataHandler>
{
    //these values will be set in the factory based of the preferences
    DBManager* db;

    int shortDataLength;
    int longDataLength;
    
    
    NSMutableDictionary* dataDict;
    NSMutableDictionary* swellDict;
    NSMutableArray* countyList;
}

-(id)initWithShortLength:(int)shortLengthInit andLongLength:(int)longLengthInit;

-(NSArray*)retunJsonDataFromURLString:(NSString*)stringInit;

-(NSMutableArray*)organizeArrayByTime:(NSMutableArray*)arrayInit andDate:(NSString*)dateInit;


//new stuff, savage
//-(NSMutableDictionary*)getSurfDataForLocation:(int)locInit;
//-(NSMutableDictionary*)getWindDataForCounty:(NSString*)countyInit;
//-(NSMutableDictionary*)getTideDataForCounty:(NSString*)countyInit;
//-(double)getWaterTempForCounty:(NSString*)countyInit;
//-(NSMutableArray*)getSwellDataForCounty:(NSString *)countyInit;
//
//-(NSMutableArray*)getAllSpotsAndCounties;
//-(NSMutableArray*)getNearBySpots:(NSString*)latInit andLon:(NSString*)lonInit;

@end

