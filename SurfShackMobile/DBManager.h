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
- (Boolean) doesActiveDBFileExist;

//-(NSMutableArray*) executeQuery:(NSString*)sql forReturnOf:(SurfShackDBColoumn)dbCol;


-(Boolean)deleteAllSpots;
-(NSMutableArray*)newGetAllSpots;
-(NSMutableArray*)newGetSomeSpots:(unsigned int)limit;
-(int)getCountOfAllSpots;
-(NSMutableArray*)newGetAllCounties;
-(NSMutableArray*)newGetCountyFavorites;
-(NSMutableArray*)getSpotNamesInCounty:(NSString*)countyInit;
-(CLLocation*)newGetLocationOfSpot:(int)idInit;
-(NSString*)newGetSpotNameOfSpotID:(int)idInit;
//-(NSString*)getSpotNameOfID:(int)idInit;
-(NSMutableArray*)newGetSpotNamesFromSearchString:(NSString*)searchString;

-(BOOL)setSpot:(NSString*)spotNameInit toFav:(BOOL)favInit;
-(NSMutableArray*)newGetSpotFavorites;
-(NSMutableArray*)newGetSpotNameFavorites;
-(NSString*)newGetCountyOfSpotID:(int)idInit;


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
