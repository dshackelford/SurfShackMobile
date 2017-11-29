//
//  PossessionDatabase.m
//  Possession
//
//  Created by John Shackelford on 2/3/13.
//  Copyright (c) 2013 Tritera Incorporated. All rights reserved.
//

#import "DBManager.h"
#import "DBTableColumn.h"

typedef enum
{
    dbCol_SpotID = 0,
    dbCol_SpotName = 1,
    dbCol_SpotCounty = 2,
    dbCol_SpotLat = 3,
    dbCol_SpotLon = 4,
    dbCol_SpotFavorite = 5,
}SurfShackDBColoumn;


@implementation DBManager

-(id) init
{
    self = [super init];
    
    //These are the columns the database should have - just add new ones before the nil
    colNames = [NSArray arrayWithObjects:@"SpotID",@"SpotName",@"SpotCounty",@"SpotLat",@"SpotLon",@"SpotFavorite", nil];
    
    return self;
}

#pragma mark - Database Management

// Open the database if it does not exist, create a new one.
- (Boolean)openDatabase
{
    Boolean openSuccess = [self openDatabaseSimple];
    if(openSuccess == false)
    {
        //Failed to open db so lets try to create a new one.
        Boolean createNewSuccess = [self createNewDatabase];
        if(createNewSuccess == true)
        {
            openSuccess = [self openDatabaseSimple];
            NSLog( @"Attempt to openDatabaseSimple after creating new returned %d", openSuccess);
            return true;
        }
        else
        {
            //Unable to create - something really out of wack
            return false;
        }
    }
    
    return true;
}

-(Boolean) openDatabaseSimple
{
    NSString* path = [self getActiveDatabaseFilePath];
    Boolean doesFileExist = [AppUtilities doesFileExistAtPath:path];
    if(doesFileExist == false)
    {
        return false;
    }
    if (sqlite3_open([path UTF8String], &database) == SQLITE_OK)
    {
        return true;
    }
    else
    {
        // Even though the open failed, call close to properly clean up resources.
        sqlite3_close(database);
        NSLog( @"Failed to open database with message '%s'.", sqlite3_errmsg(database));
    }
    return false;
    
}

//"PRAGMA table_info(tablename)"
-(NSMutableArray*) getActualListOfColumns
{
    NSString* sql = @"PRAGMA table_info(SpitcastSpots)";
    const char* sqlCstr = [sql UTF8String];
    
    NSMutableArray* results = [[NSMutableArray alloc] init];
    
    sqlite3_stmt *statement;
    
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
    if (sqlite3_prepare_v2(database, sqlCstr, -1, &statement, NULL) == SQLITE_OK)
    {
        // We "step" through the results - once for each row.
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            int colIndex = sqlite3_column_int(statement, 0);
            NSString* columnName = [NSString stringWithUTF8String: (char*)sqlite3_column_text(statement, 1)];
            NSString* columnType = [NSString stringWithUTF8String: (char*)sqlite3_column_text(statement, 2)];
            DBTableColumn* col = [[DBTableColumn alloc] init];
            [col setColumnName:columnName];
            [col setTypeName:columnType];
            [col setColumnNumber:colIndex];
            
            [results addObject:col];
#if !__has_feature(objc_arc)
            [col release];
#endif
        }
    }
    sqlite3_finalize(statement);
    
    return results;
}

//RETURNS THE NAMES OF THE COLUMNS IN A READABLE FORMAT
-(NSMutableArray*) getDesignListOfColumns
{
    NSMutableArray* results = [[NSMutableArray alloc] init];
    [results addObjectsFromArray:colNames];
    
    return results;
}

-(void) alterDbStructureAddMissingColumns
{
    NSMutableArray* currentCols;
    [self openDatabaseSimple];
    currentCols = [self getActualListOfColumns];
    [self closeDatabase];
    
    NSUInteger colCount = [currentCols count];
    NSUInteger designColCount = [colNames count];
    if(colCount != designColCount)
    {
        NSLog(@"The existing database and the design database is out of sync!");
        NSMutableArray* missingColNames = [self newGetListOfMissingColumns];
        NSUInteger countOfMissingCols = [missingColNames count];
        [self openDatabaseSimple];
        for( int i = 0; i < countOfMissingCols; i++)
        {
            NSString* missingColName = [missingColNames objectAtIndex:i];
            NSLog(@"Missing Column Name in Current database = %@", missingColName);
            
            if ([missingColName isEqualToString:[colNames objectAtIndex:dbCol_SpotID]] == true)
            {
                [self alterDB_addSpotIDColumn];
            }
            else if([missingColName isEqualToString:[colNames objectAtIndex:dbCol_SpotName]] == true)
            {
                [self alterDB_addSpotNameColumn];
            }
            else if([missingColName isEqualToString:[colNames objectAtIndex:dbCol_SpotCounty]] == true)
            {
                [self alterDB_addSpotCountyColumn];
            }
            else if([missingColName isEqualToString:[colNames objectAtIndex:dbCol_SpotLat]] == true)
            {
                [self alterDB_addSpotLatColumn];
            }
            else if([missingColName isEqualToString:[colNames objectAtIndex:dbCol_SpotLon]] == true)
            {
                [self alterDB_addSpotLonColumn];
            }
            else if([missingColName isEqualToString:[colNames objectAtIndex:dbCol_SpotFavorite]] == true)
            {
                [self alterDB_addSpotFavoriteColumn];
            }
        }
        [self closeDatabase];
    }
    else
    {
        NSLog(@"The existing database and the design database has the same number of columns");
    }
#if !__has_feature(objc_arc)
    [currentCols release];
#endif
}

-(NSMutableArray*) newGetListOfMissingColumns
{
    [self openDatabaseSimple];
    NSMutableArray* currentCols;
    NSMutableArray* currentColNames = [[NSMutableArray alloc] init ];
    NSMutableArray* missingColumnNames = [[NSMutableArray alloc] init ];
    
    currentCols = [self getActualListOfColumns];//In the existing database
    NSUInteger designColCount = [colNames count];
    NSUInteger currentColCount = [currentCols count];
    for(int i = 0; i < currentColCount; i++)
    {
        DBTableColumn* tableColumn = (DBTableColumn*)[currentCols objectAtIndex:i];
        NSString* colName = [tableColumn getColumnName];
        [currentColNames addObject:colName];
    }
    
    for(int i = 0; i < designColCount; i++)
    {
        NSString* designColName = [colNames objectAtIndex:i];
        NSPredicate* predicate = [NSPredicate predicateWithFormat:@"SELF like %@", designColName];
        NSArray* missingItems = [currentColNames filteredArrayUsingPredicate: predicate];
        if([missingItems count] < 1)
        {
            [missingColumnNames addObject:designColName];
        }
    }
    [self closeDatabase];
#if !__has_feature(objc_arc)
    [currentCols release];
#endif
    return missingColumnNames;
}

- (Boolean) closeDatabase
{
    int ret = sqlite3_close(database);
    if(ret == SQLITE_OK)
        return true;
    else
        return false;
}

-(NSString*) getActiveDatabaseFilePath
{
    NSString* pathToDB = [AppUtilities getPathToAppDatabase];
    return pathToDB;
}

- (Boolean)doesActiveDBFileExist
{
    Boolean exist;
    NSString* dbPath = [self getActiveDatabaseFilePath];
    NSLog(@"Database = %@", dbPath);
    
    exist = [AppUtilities doesFileExistAtPath:dbPath];
    return exist;
}

- (Boolean)createNewDatabase
{
    NSString* path = [AppUtilities getPathToAppDatabase];
    Boolean success = true;
    const char* dbpath = [path UTF8String];
    NSLog(@"Path to Database = %@",path);
    statusMessage = @"";
    
    if (sqlite3_open(dbpath, &database) == SQLITE_OK)
    {
        char *errMsg;

        const char* sql_stmt = "CREATE TABLE IF NOT EXISTS SpitcastSpots (SpotID int NOT NULL PRIMARY KEY ON CONFLICT REPLACE UNIQUE, SpotName text, SpotCounty text, SpotLat double DEFAULT 0.0, SpotLon double DEFAULT 0.0, SpotFavorite boolean DEFAULT false)";
        
        if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg) != SQLITE_OK)
        {
            statusMessage = @"Failed to create SpitcastSpots table";
            success = false;
            NSLog(@"Failed to create SpitcastSpots table");
        }
        
        sqlite3_close(database);
    }
    else
    {
        statusMessage = @"Failed to open/create database";
        success = false;
    }
    // Even though the open failed, call close to properly clean up resources.
    sqlite3_close(database);
    return success;
}


-(Boolean)addSpotID:(int)spotIDInit SpotName:(NSString*)spotNameInit andCounty:(NSString*)spotCountyInit withLat:(double)latInit andLon:(double)lonInit
{
    NSMutableString* sql = [NSMutableString stringWithString:@"INSERT INTO SpitcastSpots "];
    
    [sql appendString:@"(SpotID,SpotName,SpotCounty,SpotLat,SpotLon)"];
    [sql appendString:@" VALUES("];
    [sql appendFormat:@"'%d',",spotIDInit];
    [sql appendFormat:@"'%@',",spotNameInit];
    [sql appendFormat:@"'%@',",spotCountyInit];
    [sql appendFormat:@"'%f',",latInit];
    [sql appendFormat:@"'%f'",lonInit];
    [sql appendString:@" )"];
    
    
    sqlite3_stmt *insert_statement = nil;
    
    const char* sqlCstr = [sql UTF8String];
    if (sqlite3_prepare_v2(database, sqlCstr, -1, &insert_statement, NULL) != SQLITE_OK)
    {
        sqlite3_finalize(insert_statement);
        NSLog(@"SQLITE3_PREPARE FAILED %s", sqlite3_errmsg(database));
        return false;
    }
    
    if (sqlite3_step(insert_statement) != SQLITE_DONE)
    {
        NSLog(@"SQLITE3_STEP FAILED %s", sqlite3_errmsg(database));
    }
    
    sqlite3_finalize(insert_statement);
    return true;
}

#pragma mark - Basic Query
-(Boolean) executeQuery :(NSString*)sql
{
    const char* sqlCstr = [sql UTF8String];
    Boolean success = false;
    sqlite3_stmt *statement;
    
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
    if (sqlite3_prepare_v2(database, sqlCstr, -1, &statement, NULL) == SQLITE_OK)
    {
        //success = true;
        if(sqlite3_step(statement) == SQLITE_DONE)
        {
            success = true;
        }
    }
    sqlite3_finalize(statement);
    return success;
}

-(NSMutableArray*) executeQuery:(NSString*)sql forReturnOf:(SurfShackDBColoumn)dbCol
{
    const char* sqlCstr = [sql UTF8String];
    NSMutableArray* results = [[NSMutableArray alloc] init];
    //#endif
    
    sqlite3_stmt *statement;
    
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
    if (sqlite3_prepare_v2(database, sqlCstr, -1, &statement, NULL) == SQLITE_OK)
    {
        // "step" through the results - once for each row.
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            if(statement != nil)
            {
                if(dbCol == dbCol_SpotLat || dbCol == dbCol_SpotLon)
                {
                    double x = sqlite3_column_double(statement, dbCol);
                    [results addObject:[NSNumber numberWithDouble:x]];
                }
                else if(dbCol == dbCol_SpotID)
                {
                    int x = sqlite3_column_int(statement, dbCol);
                    [results addObject:[NSNumber numberWithInteger:x]];
                }
                else
                {
                    const unsigned char* st = sqlite3_column_text(statement, dbCol);
                    [results addObject:[NSString stringWithCString:st encoding:NSUTF8StringEncoding]];
                }
            }
        }
    }
    sqlite3_finalize(statement);
    return results;
}


-(Boolean)deleteAllSpots
{
    NSString* sql = @"DELETE FROM SpitcastSpots";
    Boolean success = [self executeQuery:sql];
    return success;
}

-(NSMutableArray*)getAllSpots
{
    NSString *sql = @"SELECT * FROM SpitcastSpots ORDER BY SpotID DESC";
    NSMutableArray* results = [self executeQuery:sql forReturnOf:dbCol_SpotName];
    
    return results;
}

-(NSMutableArray*)getSomeSpots:(unsigned int)limit
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots ORDER BY SpotID ASC LIMIT %d", limit];
    NSMutableArray* results = [self executeQuery:sql forReturnOf:dbCol_SpotID];
    
    return results;
}

-(NSMutableArray*)getAllCounties
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots GROUP BY SpotCounty ORDER BY SpotLAT DESC"];

    return [self executeQuery:sql forReturnOf:dbCol_SpotCounty];
}

-(NSMutableArray*)getCountyFavorites
{
    NSString *sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotFavorite = 1 GROUP BY SpotCounty"];
    
    return [self executeQuery:sql forReturnOf:dbCol_SpotCounty];
}

-(NSMutableArray*)getSpotNamesInCounty:(NSString*)countyInit
{
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotCounty LIKE '%%%@%%' ORDER BY SpotLat DESC",countyInit];
//    NSString* sql = [NSString stringWithFormat:@"SELECT SpotName From SpitcastSpots WHERE SpotCounty = '%@' ORDER BY SpotLat DESC",countyInit];

    return [self executeQuery:sql forReturnOf:dbCol_SpotName];
}

-(NSMutableArray*)getSpotFavorites
{
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotFavorite = 1"];
    
    return [self executeQuery:sql forReturnOf:dbCol_SpotID];
}

-(NSMutableArray*)getSpotNameFavorites
{
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotFavorite = 1"];
    
    return [self executeQuery:sql forReturnOf:dbCol_SpotName];
}


-(NSString*)getCountyOfSpotID:(int)idInit
{
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotID = %d",idInit];
    
    return [[self executeQuery:sql forReturnOf:dbCol_SpotCounty] lastObject];
}

-(NSMutableArray*)getSpotNamesFromSearchString:(NSString*)searchString
{
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotName LIKE '%%%@%%'",searchString];
    
    return [self executeQuery:sql forReturnOf:dbCol_SpotName];
}

-(NSString*)getSpotNameOfSpotID:(int)idInit
{
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotID = %d",idInit];
    return [[self executeQuery:sql forReturnOf:dbCol_SpotName] lastObject];
}

-(CLLocation*)getLocationOfSpot:(int)idInit
{
    NSString* sql = [NSString stringWithFormat:@"SELECT * FROM SpitcastSpots WHERE SpotID = %d",idInit];

    NSNumber* lat = [[self executeQuery:sql forReturnOf:dbCol_SpotLat] lastObject];
    NSNumber* lon = [[self executeQuery:sql forReturnOf:dbCol_SpotLon] lastObject];
    
    CLLocation* aLoc = [[CLLocation alloc] initWithLatitude:[lat doubleValue] longitude:[lon doubleValue]];
    return aLoc;
}

-(BOOL)setSpot:(NSString*)spotNameInit toFav:(BOOL)favInit
{
    NSString* sql;
    
    if (favInit == true)
    {
        sql = [NSString stringWithFormat:@"UPDATE SpitcastSpots SET SpotFavorite = 1 WHERE SpotName = '%@'",spotNameInit];
    }
    else
    {
        sql = [NSString stringWithFormat:@"UPDATE SpitcastSpots SET SpotFavorite = 0 WHERE SpotName = '%@'",spotNameInit];
    }

    return [self executeQuery:sql];
}


-(int)getCountOfAllSpots
{
    NSString *sql = @"SELECT * FROM SpitcastSpots";
    const char* sqlCstr = [sql UTF8String];
    sqlite3_stmt *statement;
    int count = 0;
    
    // Preparing a statement compiles the SQL query into a byte-code program in the SQLite library.
    // The third parameter is either the length of the SQL string or -1 to read up to the first null terminator.
    if (sqlite3_prepare_v2(database, sqlCstr, -1, &statement, NULL) == SQLITE_OK)
    {
        // We "step" through the results - once for each row.
        while (sqlite3_step(statement) == SQLITE_ROW)
        {
            count++;
        }
    }
    sqlite3_finalize(statement);
    return count;
}


#pragma mark - Alter Table / Column Updates
-(Boolean) alterDB_addSpotIDColumn
{
    Boolean success = false;
    NSString *updateSQL = [NSString stringWithFormat: @"ALTER TABLE SpitcastSpots ADD COLUMN SpotID text;"];
    success = [self executeQuery:updateSQL];
    NSLog(@"Alter DB alterDB_addSpotIDColumn returned %@ on QUERY = %@", success ? @"TRUE" : @"FALSE", updateSQL);
    return success;
}

-(Boolean) alterDB_addSpotNameColumn
{
    Boolean success = false;
    NSString *updateSQL = [NSString stringWithFormat: @"ALTER TABLE SpitcastSpots ADD COLUMN SpotName text;"];
    success = [self executeQuery:updateSQL];
    NSLog(@"Alter DB alterDB_addSpotNameColumn returned %@ on QUERY = %@", success ? @"TRUE" : @"FALSE", updateSQL);
    return success;
}

-(Boolean) alterDB_addSpotCountyColumn
{
    Boolean success = false;
    NSString *updateSQL = [NSString stringWithFormat: @"ALTER TABLE SpitcastSpots ADD COLUMN SpotCounty text;"];
    success = [self executeQuery:updateSQL];
    NSLog(@"Alter DB alterDB_addSpotCountyColumn returned %@ on QUERY = %@", success ? @"TRUE" : @"FALSE", updateSQL);
    return success;
}

-(Boolean) alterDB_addSpotLatColumn
{
    Boolean success = false;
    NSString *updateSQL = [NSString stringWithFormat: @"ALTER TABLE SpitcastSpots ADD COLUMN SpotLat double DEFAULT 0.0;"];
    success = [self executeQuery:updateSQL];
    NSLog(@"Alter DB alterDB_addSpotLatColumn returned %@ on QUERY = %@", success ? @"TRUE" : @"FALSE", updateSQL);
    return success;
}
-(Boolean) alterDB_addSpotLonColumn
{
    Boolean success = false;
    NSString *updateSQL = [NSString stringWithFormat: @"ALTER TABLE SpitcastSpots ADD COLUMN SpotLon double DEFAULT 0.0;"];
    success = [self executeQuery:updateSQL];
    NSLog(@"Alter DB alterDB_addSpotLonColumn returned %@ on QUERY = %@", success ? @"TRUE" : @"FALSE", updateSQL);
    return success;
}
-(Boolean) alterDB_addSpotFavoriteColumn
{
    Boolean success = false;
    NSString *updateSQL = [NSString stringWithFormat: @"ALTER TABLE SpitcastSpots ADD COLUMN SpotFavorite boolean DEFAULT false;"];
    success = [self executeQuery:updateSQL];
    NSLog(@"Alter DB alterDB_addSpotFavoriteColumn returned %@ on QUERY = %@", success ? @"TRUE" : @"FALSE", updateSQL);
    return success;
}


@end
