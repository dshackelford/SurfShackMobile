//
//  PossessionDatabase.h
//  Possession
//
//  Created by John Shackelford on 2/3/13.
//  Copyright (c) 2013 Tritera Incorporated. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>
#import "AppUtilities.h"
#import "CoreLocation/CoreLocation.h"

@interface DBManager : NSObject
{
    sqlite3* database;
    NSArray* colNames;
    NSString* statusMessage;
}

-(Boolean) openDatabase;
-(Boolean) openDatabaseSimple;
-(Boolean) closeDatabase;
-(NSMutableArray*) getActualListOfColumns;
-(NSMutableArray*) getDesignListOfColumns;
-(Boolean) createNewDatabase;

-(NSString*) getActiveDatabaseFilePath;
-(Boolean) doesActiveDBFileExist;



-(Boolean)deleteAllSpots;
-(NSMutableArray*)getAllSpots;
-(NSMutableArray*)getSomeSpots:(unsigned int)limit;
-(int)getCountOfAllSpots;
-(NSMutableArray*)getAllCounties;
-(NSMutableArray*)getCountyFavorites;
-(NSMutableArray*)getSpotNamesInCounty:(NSString*)countyInit;
-(CLLocation*)getLocationOfSpot:(int)idInit;
-(NSString*)getSpotNameOfSpotID:(int)idInit;
//-(NSString*)getSpotNameOfID:(int)idInit;
-(NSMutableArray*)getSpotNamesFromSearchString:(NSString*)searchString;

-(BOOL)setSpot:(NSString*)spotNameInit toFav:(BOOL)favInit;
-(NSMutableArray*)getSpotFavorites;
-(NSMutableArray*)getSpotNameFavorites;
-(NSString*)getCountyOfSpotID:(int)idInit;


-(void) alterDbStructureAddMissingColumns;
-(NSMutableArray*) newGetListOfMissingColumns;
-(Boolean) alterDB_addSpotIDColumn;
-(Boolean) alterDB_addSpotNameColumn;
-(Boolean) alterDB_addSpotCountyColumn;
-(Boolean) alterDB_addSpotLatColumn;
-(Boolean) alterDB_addSpotLonColumn;
-(Boolean) alterDB_addSpotFavoriteColumn;


-(Boolean)addSpotID:(int)spotIDInit SpotName:(NSString*)spotNameInit andCounty:(NSString*)spotCountyInit withLat:(double)latInit andLon:(double)lonInit;


@end
