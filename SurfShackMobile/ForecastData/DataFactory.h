//
//  DataFactory.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/18/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpitcastData.h"
#import "CountyHandler.h"
#import "DBManager.h"
#import "CurrentWeather.h"
#import "DateHandler.h"

#import "DataSource.h" //spitcast
#import "DataCollector.h"

@class ReportViewController;

@interface DataFactory : NSObject <DataCollector>
{
    NSMutableDictionary* spotsDict; //obj: array of surf, key is the spotID
    NSMutableDictionary* countiesDict; //obj: array of countyDictionaries
    NSMutableDictionary* reportDicts;
    NSMutableDictionary* viewControllersDict;
    
    int currentReportID;
    
    DBManager* db;
    
    int dateOnLastDownload;
}

@property id<DataSource> surfSource;
@property id<DataSource> weatherSource;
@property NSMutableDictionary* notificationTrackerDict;
@property NSMutableDictionary* spotNameVCs;

-(void)getDataForSpots:(NSArray*)spotIDArray andCounties:(NSArray*)countiesArray;

-(NSMutableDictionary*)getASpotDictionary:(NSString*)spotNameInit andCounty:(NSString*)countyInit andID:(int)idInit;

-(NSMutableArray*)getShorternedVersionOfArray:(NSMutableArray*)arrInit ofLength:(int)rangeInit;

-(NSMutableArray*)getShorternedVersionOfXValArray:(NSMutableArray*)arrInit ofLength:(int)rangeInit;

//update current values
-(NSMutableDictionary*)setCurrentWindDirection:(NSMutableDictionary*)countyDictInit;

-(NSMutableDictionary*)setCurrentSwellDirection:(NSMutableDictionary*)aSpotDictInit;

-(NSMutableDictionary*)setCurrentValuesForSpotDict:(NSMutableDictionary*)spotDictInit;

-(void)removeSpotDictionary:(int)spotName;
-(void)addReportVC:(ReportViewController*)vcInit ForID:(int)idInit;
-(void)removeData;

-(NSMutableDictionary*)dataForSpotID:(int)idInit;
-(void)removeReportVCForID:(int)idInit;

@end
