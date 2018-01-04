;//
//  DataFactory.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/18/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataFactory.h"
#import <AsyncBlockOperation/AsyncBlockOperation.h>
#import "OfflineData.h"
#import "ReportViewController.h"
#import "DBQueries.h"

@implementation DataFactory

typedef enum{
    waiting,
    valid,
    invalid,
} spotDictState;

-(id)init
{
    self = [super init];
    
    self.surfSource = [PreferenceFactory getDataServiceWithCollector:self];
    self.weatherSource = [PreferenceFactory getWeatherServiceWithCollector:self];
    
    spotsDict = [[NSMutableDictionary alloc] init]; //a spot: surf heights and weather
    countiesDict = [[NSMutableDictionary alloc] init];
    reportDicts = [[NSMutableDictionary alloc] init]; //completed report view dictionaries
    viewControllersDict = [[NSMutableDictionary alloc] init];
    
    self.notificationTrackerDict = [NSMutableDictionary dictionary]; //hold whether or not a notification has already been sent
    self.spotNameVCs = [NSMutableDictionary dictionary];
    
    dateOnLastDownload = 0; //probably should read from a file?
    currentReportID = 0;
    return self;
}

-(void)addReportVC:(ReportViewController*)vcInit ForID:(int)idInit
{
    [viewControllersDict setObject:vcInit forKey:[NSNumber numberWithInteger:idInit]];
}

-(void)removeReportVCForID:(int)idInit
{
    [viewControllersDict removeObjectForKey:[NSNumber numberWithInt:idInit]];
}

-(NSMutableDictionary*)dataForSpotID:(int)idInit
{
    currentReportID = idInit; //only views that are live call this
    
    //check for already locally cached data
    if([reportDicts objectForKey:[NSNumber numberWithInt:idInit]])
    {
        //we have already a completed
        
        NSString* downloadDate = [[reportDicts objectForKey:[NSNumber numberWithInt:idInit]] objectForKey:@"downloadDate"];
        int date = [downloadDate intValue];
        
        if([[DateHandler getCurrentDateString] intValue] > date)
        {
            [[reportDicts objectForKey:[NSNumber numberWithInt:idInit]] setObject:[NSNumber numberWithBool:true] forKey:@"isOld"];
            
            NSArray* spotFavIDs = [DBQueries getSpotFavorites];
            NSArray* countyFavs = [DBQueries getCountyFavorites];
                
            [self getDataForSpots:spotFavIDs andCounties:countyFavs];
            
        }
        
        return [reportDicts objectForKey:[NSNumber numberWithInt:idInit]];
    }
    else
    {
        //nothing already cached. If its nil, then the report view will continue waiting
        NSLog(@"Returing offline data");
        return [OfflineData getOfflineDataForID:idInit];
    }
}

//this is called from report page view contorller
-(void)getDataForSpots:(NSArray*)spotIDArray andCounties:(NSArray*)countiesArray
{
    NSMutableArray* arrOfLocs = [[NSMutableArray alloc] init];
    NSMutableArray* arrOfSpotNames = [[NSMutableArray alloc] init];
    
    //to avoid multithread issues with database queries
    for (NSNumber* num in spotIDArray)
    {
        int intNum = [num intValue];
        
        [arrOfLocs addObject: [DBQueries getLocationOfSpot:intNum]];
        [arrOfSpotNames addObject:[DBQueries getSpotNameOfSpotID:intNum]];
        
        [self.notificationTrackerDict setObject:[NSNumber numberWithBool:false] forKey:[DBQueries getSpotNameOfSpotID:intNum]];
    }
    
    int currentDownloadTry = [[DateHandler getCurrentDateString] intValue];
    NSLog(@"%d",currentDownloadTry);
    
    if (currentDownloadTry > dateOnLastDownload)
    {
        //remove all objects from the dictionaries for a fresh download
        [spotsDict removeAllObjects];
        [countiesDict removeAllObjects];
    }
    
    //SPOT DATA
    for (int i = 0; i < [spotIDArray count]; i++)
    {
        int spotID = [[spotIDArray objectAtIndex:i] intValue];

        CLLocation* aLoc = [arrOfLocs objectAtIndex:i];
        NSString* spotName = [arrOfSpotNames objectAtIndex:i];

        if ([spotsDict objectForKey:spotName] == nil)
        {
            dateOnLastDownload = [[DateHandler getCurrentDateString] intValue];

            [[spotsDict objectForKey:spotName] setObject:[NSNumber numberWithInteger:waiting] forKey:@"state"];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            AsyncBlockOperation *surfOp = [AsyncBlockOperation blockOperationWithBlock:^(AsyncBlockOperation *surfOp) {
                [self.surfSource startSurfDataDownloadForSpotID:spotID andSpotName:spotName andOp:surfOp];
            }];
            AsyncBlockOperation *weatherOp = [AsyncBlockOperation blockOperationWithBlock:^(AsyncBlockOperation *weatherOp) {
                [self.weatherSource startWeatherDownloadForLoc:aLoc andSpotID:spotID andSpotName:spotName andOp:weatherOp];
            }];
            
            NSBlockOperation* spotEndOp = [NSBlockOperation blockOperationWithBlock:^{
                [self checkForCompletionForSpot:spotName andID:spotID];
            }];
            
            [spotEndOp addDependency:surfOp];
            [spotEndOp addDependency:weatherOp];
            
            [queue addOperation:spotEndOp];
            [queue addOperation:surfOp];
            [queue addOperation:weatherOp];
        }
    }
    
    //COUNTY DATA
    for (NSString* county in countiesArray)
    {
        if ([countiesDict objectForKey:county] == nil)
        {
           NSString* spitCounty = [CountyHandler moldStringForURL:county];
            
            NSOperationQueue *queue = [[NSOperationQueue alloc] init];
            
            NSBlockOperation* countyEndOp = [NSBlockOperation blockOperationWithBlock:^{
                [self checkForCompletionForCounty:spitCounty];
            }];
            
            AsyncBlockOperation *waterTempOp = [AsyncBlockOperation blockOperationWithBlock:^(AsyncBlockOperation *waterTempOp) {
                [self.surfSource startWaterTempDownloadForCounty:spitCounty andOp:waterTempOp];
            }];
            AsyncBlockOperation *windOp = [AsyncBlockOperation blockOperationWithBlock:^(AsyncBlockOperation *windOp) {
                [self.surfSource startWindDataDownloadForCounty:spitCounty andOp:windOp];
            }];
            AsyncBlockOperation *tideOp = [AsyncBlockOperation blockOperationWithBlock:^(AsyncBlockOperation *tideOp) {
                [self.surfSource startTideDataDownloadForCounty:spitCounty andOp:tideOp];
            }];
            AsyncBlockOperation *swellOp = [AsyncBlockOperation blockOperationWithBlock:^(AsyncBlockOperation *swellOp) {
                [self.surfSource startSwellDataDownloadForCounty:spitCounty andOp:swellOp];
            }];
            
            [countyEndOp addDependency:waterTempOp];
            [countyEndOp addDependency:windOp];
            [countyEndOp addDependency:tideOp];
            [countyEndOp addDependency:swellOp];

            [queue addOperation:waterTempOp];
            [queue addOperation:windOp];
            [queue addOperation:tideOp];
            [queue addOperation:swellOp];
            [queue addOperation:countyEndOp];
        }
    }
}

-(void)checkForCompletionForSpot:(NSString*)spotName andID:(int)spotID
{
    NSString* county = [CountyHandler getCountyOfSpot:spotID];
    
    NSMutableDictionary* countyDict = [countiesDict objectForKey:county];
    
    if(countyDict)
    {
        if(![[self.notificationTrackerDict objectForKey:spotName] boolValue])
        {
            [self.notificationTrackerDict setObject:[NSNumber numberWithBool:true] forKey:spotName];
            
            NSOperationQueue* q = [NSOperationQueue mainQueue];
            NSBlockOperation* notifOp = [NSBlockOperation blockOperationWithBlock:^{
                
                ReportViewController* vc = [viewControllersDict objectForKey:[NSNumber numberWithInt:spotID]];
                NSLog(@"%@ has data in spot check",spotName);
                [vc youHaveData:[self getASpotDictionary:spotName andCounty:county andID:spotID]];
            }];
            [q addOperation:notifOp];
        }
    }
    
}

-(void)checkForCompletionForCounty:(NSString*)countyName
{
    NSMutableArray* favoriteSpotsArr = [NSMutableArray array];
    
    favoriteSpotsArr = [DBQueries getSpotFavorites];

    for(NSNumber* spotID in favoriteSpotsArr)
    {
        NSString* county = [CountyHandler getCountyOfSpot:[spotID intValue]];
            
        if([county isEqualToString:countyName])
        {
            NSString* spotName = @"";
            
            spotName = [DBQueries getSpotNameOfSpotID:[spotID intValue]];
            
            if([[[spotsDict objectForKey:spotName] allKeys] count] == 2 && ![[self.notificationTrackerDict objectForKey:spotName] boolValue])
            {
                [self.notificationTrackerDict setObject:[NSNumber numberWithBool:true] forKey:spotName];
                
                NSOperationQueue* q = [NSOperationQueue mainQueue];
                NSBlockOperation* notifOp = [NSBlockOperation blockOperationWithBlock:^{
                    
                    ReportViewController* vc = [viewControllersDict objectForKey:spotID];
                    NSLog(@"%@ has data in county check",spotName);
                    [vc youHaveData:[self getASpotDictionary:spotName andCounty:county andID:[spotID intValue]]];
                }];
                [q addOperation:notifOp];
            }

        }
        
    }
}
#pragma mark - Spot Data Receivers
-(void)surfDataDictReceived:(NSMutableDictionary*)surfData forSpot:(NSString *)spotNameInit
{
    if(surfData != nil)
    {
        NSMutableDictionary* aSpotDict = [spotsDict objectForKey:spotNameInit];
        if(aSpotDict == nil)
        {
            aSpotDict = [NSMutableDictionary dictionary];
        }
        
        [aSpotDict setObject:surfData forKey:@"surf"];
        
        [spotsDict setObject:aSpotDict forKey:[surfData objectForKey:@"spotName"]];
    }
    else
    {
        NSLog(@"surf data not found for spot %@",[surfData objectForKey:@"spotName"]);
        NSString* str = @"no data";
        //[aSpotDict setObject:str forKey:@"surf"];
        
        //[spotsDict setObject:aSpotDict forKey:[surfData objectForKey:@"spotName"]];
    }

}

- (void)weatherDataDictReceived:(NSMutableDictionary *)weatherData forSpot:(NSString *)spotNameInit
{
    if(weatherData != nil)
    {
        NSMutableDictionary* aSpotDict = [spotsDict objectForKey:spotNameInit];
        if(aSpotDict == nil)
        {
            aSpotDict = [NSMutableDictionary dictionary];
        }
        
        
        [aSpotDict setObject:weatherData forKey:@"weatherDict"];
        [spotsDict setObject:aSpotDict forKey:[weatherData objectForKey:@"spotName"]];
    }
    else
    {
        NSLog(@"weather data no found for spot %@",[weatherData objectForKey:@"spotName"]);
        //[aSpotDict setObject:@"no data" forKey:@"weatherDict"];
    }
}

#pragma mark - County Data Receivers

-(void)tideDataDictReceived:(NSMutableDictionary *)tideData forCounty:(NSString *)countyNameInit
{
    if(tideData != nil)
    {
        NSMutableDictionary* aCountyDict = [countiesDict objectForKey:countyNameInit];
        if(aCountyDict == nil)
        {
            aCountyDict = [NSMutableDictionary dictionary];
        }
        [aCountyDict setObject:tideData forKey:@"tide"];
        [countiesDict setObject:aCountyDict forKey:[tideData objectForKey:@"countyID"]];
    }
    else
    {
        NSLog(@"tide data not found for spot %@",[tideData objectForKey:@"countyID"]);
        NSString* str = @"no data";
        //[aCountyDict setObject:str forKey:@"tide"];
    }
}

-(void)windDataDictReceived:(NSMutableDictionary *)windData forCounty:(NSString *)countyNameInit
{
    if(windData != nil)
    {
        NSMutableDictionary* aCountyDict = [countiesDict objectForKey:countyNameInit];
        if(aCountyDict == nil)
        {
            aCountyDict = [NSMutableDictionary dictionary];
        }
        [aCountyDict setObject:windData forKey:@"wind"];
        [countiesDict setObject:aCountyDict forKey:[windData objectForKey:@"countyID"]];
    }
    else
    {
        NSLog(@"wind data not found for spot %@",[windData objectForKey:@"countyID"]);
        //[aCountyDict setObject:@"no data" forKey:@"wind"];
    }
}

-(void)swellDataDictReceived:(NSMutableDictionary *)swellData forCounty:(NSString *)countyNameInit
{
    if(swellData != nil)
    {
        NSMutableDictionary* aCountyDict = [countiesDict objectForKey:countyNameInit];
        
        if(aCountyDict == nil)
        {
            aCountyDict = [NSMutableDictionary dictionary];
        }
        [aCountyDict setObject:swellData forKey:@"swell"];
        [countiesDict setObject:aCountyDict forKey:[swellData objectForKey:@"countyID"]];
    }
    else
    {
        NSLog(@"swell data not found for spot %@",[swellData objectForKey:@"countyID"]);
    }
    
}

- (void)waterTempDataDictReceived:(NSMutableDictionary *)waterTempData forCounty:(NSString *)countyNameInit
{
    if(waterTempData != nil)
    {
        NSMutableDictionary* aCountyDict = [countiesDict objectForKey:countyNameInit];
        if(aCountyDict == nil)
        {
            aCountyDict = [NSMutableDictionary dictionary];
        }
        [aCountyDict setObject:[waterTempData objectForKey:@"waterTemp"] forKey:@"waterTemp"];
        [countiesDict setObject:aCountyDict forKey:[waterTempData objectForKey:@"countyID"]];
    }
    else
    {
        NSLog(@"water temp data not found for spot %@",[waterTempData objectForKey:@"countyID"]);
    }
    
}

//this gets called every time a report view will appear, therefore I find it prudent not have to download anything, all the data should be present, this method just parses it
-(NSMutableDictionary*)setCurrentValuesForSpotDict:(NSMutableDictionary*)spotDictInit
{
    spotDictInit = [self setCurrentSwellDirection:spotDictInit];
    spotDictInit = [self setCurrentWindDirection:spotDictInit];
    spotDictInit = [self setCurrentImportantSwells:spotDictInit];
    
    spotDictInit = [self setMaxMinTideTimes:spotDictInit];
    
    return spotDictInit;
}

-(NSMutableDictionary*)setCurrentSwellDirection:(NSMutableDictionary*)aSpotDictInit
{
    NSLog(@"setting current swell direction");
    //get the first day array of swells
    NSMutableArray* swellArray = [[aSpotDictInit objectForKey:@"swell"] objectForKey:@"swellArray"];
    
    if ([swellArray count] > 0)
    {
        //NSMutableArray* swellArr = [[aSpotDictInit objectForKey:@"swellDict"] objectAtIndex:0];
    
        int currentIndex = [DateHandler getIndexFromCurrentTime];
    
#warning this should include a division of current index by day number, not just day 0 especially when I add the movable bar in the plot view
        NSMutableArray* hourSwellArray = [[[swellArray objectAtIndex:0] objectAtIndex:currentIndex] objectForKey:@"swellArray"];
        
#warning should iterate through the hour array for all potential swells
#warning also need to check if its nill as well
        if (![[[hourSwellArray objectAtIndex:0] objectForKey:@"dir"] isEqual:[NSNull null]])
        {
            double currentDirection = [[[hourSwellArray objectAtIndex:0] objectForKey:@"dir"] doubleValue];
            currentDirection = currentDirection + 180;
            
            [aSpotDictInit setObject:[NSNumber numberWithDouble:currentDirection] forKey:@"currentSwellDirection"];
        }
    }
    return aSpotDictInit;
    
}

-(NSMutableDictionary*)setCurrentWindDirection:(NSMutableDictionary*)aSpotDictInit
{
    NSLog(@"setting current wind direction");
    NSMutableDictionary* windDict = [aSpotDictInit objectForKey:@"wind"];

    int currentIndex = [DateHandler getIndexFromCurrentTime];
    
    NSNumber* currentDirection = [[windDict objectForKey:@"windDirectionArray"] objectAtIndex:currentIndex];
    if(currentDirection != nil)
        [aSpotDictInit setObject:currentDirection forKey:@"windDirection"];
    else
        NSLog(@"nil wind direction found!");
    return aSpotDictInit;
}

-(NSMutableDictionary*)setCurrentImportantSwells:(NSMutableDictionary*)aSpotDictInit
{
        NSLog(@"setting current important swells");
    NSMutableArray* weekSwellArray = [[aSpotDictInit objectForKey:@"swell"] objectForKey:@"swellArray"];
    NSMutableArray* daySwellArray = [weekSwellArray objectAtIndex:0];
    int currentIndex = [DateHandler getIndexFromCurrentTime];
    NSMutableArray* hourSwellArray = [[daySwellArray  objectAtIndex:currentIndex] objectForKey:@"swellArray"];
    
    double hst = 0;
    if([[daySwellArray objectAtIndex:currentIndex] objectForKey:@"hst"] != nil)
    {
        hst = [[[daySwellArray  objectAtIndex:currentIndex] objectForKey:@"hst"] doubleValue];
    }
    int count = 0;
    
    for(int i = 0; i < 5; i = i + 1)
    {
        NSMutableDictionary* aSwellDict = [hourSwellArray objectAtIndex:0];
        
        if(aSwellDict != nil)
        {
            if(![[aSwellDict objectForKey:@"tp"] isEqual:[NSNull null]] && ![[aSwellDict objectForKey:@"hs"] isEqual:[NSNull null]] && ![[aSwellDict objectForKey:@"dir"] isEqual:[NSNull null]])
            {
                double tp = [[aSwellDict objectForKey:@"tp"] doubleValue];
                double hs = [[aSwellDict objectForKey:@"hs"] doubleValue];
                
                double height = hs*hst;
                height = ceil(height);
                
                int direction = [[aSwellDict objectForKey:@"dir"] intValue] + 180;
                NSString* dirStr = [self getDirectionStrFromDegree:direction];
                
                NSString* swellInfoStr = [NSString stringWithFormat:@"Dir: %@ \nTP: %.fs \nHt: %.f ft",dirStr,tp,height];
                
                if(count == 0)
                {
                    [aSpotDictInit setObject:swellInfoStr forKey:@"mainSwellInfo"];
                    count = count + 1;
                }
                else
                {
                    [aSpotDictInit setObject:swellInfoStr forKey:@"secondSwellInfo"];
                    break;
                }
            }
        }
    }
    return aSpotDictInit;
}

-(NSString*)getDirectionStrFromDegree:(int)directionInit
{
    NSString* dirStr = [[NSString alloc] init];
    
    if (directionInit < 22.5 || directionInit >= 337.5)
    {
        dirStr = @"N";
    }
    else if(directionInit > 22.5 && directionInit <= 67.5)
    {
        dirStr = @"NE";
    }
    else if(directionInit > 67.5 && directionInit <= 112.5)
    {
        dirStr = @"E";
    }
    else if(directionInit > 112.5 && directionInit <= 157.5)
    {
        dirStr = @"SE";
    }
    else if(directionInit > 157.5 && directionInit <= 202.5)
    {
        dirStr = @"S";
    }
    else if(directionInit > 202.5 && directionInit <= 247.5)
    {
        dirStr = @"SW";
    }
    else if(directionInit > 247.5 && directionInit <= 292.5)
    {
        dirStr = @"W";
    }
    else if(directionInit > 292.5 && directionInit < 337.5)
    {
        dirStr = @"W";
    }
    
    return dirStr;
}

-(NSMutableDictionary*)setMaxMinTideTimes:(NSMutableDictionary*)spotDictInit
{
    int currentTime = [DateHandler getIndexFromCurrentTime];
    NSMutableArray* tideArrInit = [[spotDictInit objectForKey:@"tide"] objectForKey:kMags];
    double nextMaxTide = 0;
    int nextHighTideIndex = 0;
    double previousLowTide = 0;
    int previousLowTideIndex = 0;
    int nextLowTideIndex = 0;
    
    if(currentTime == 0)
    {
        currentTime = 1;
    }
    
    for (int i = currentTime; i < [tideArrInit count]; i++)
    {
        if ([[tideArrInit objectAtIndex:i] doubleValue] > [[tideArrInit objectAtIndex:i+1] doubleValue] && [[tideArrInit objectAtIndex:i] doubleValue] > [[tideArrInit objectAtIndex:i-1] doubleValue])
        {
            nextHighTideIndex = i;
            NSString* timeStr = [DateHandler getTimeFromIndex:nextHighTideIndex];
            [spotDictInit setObject:timeStr forKey:@"nextHighTide"];
            
            nextMaxTide = [[tideArrInit objectAtIndex:i] doubleValue];
            
            break;
        }
    }

    //determine the previous low tide for tide Ratio calculation
    for (int i = 1; i < nextHighTideIndex; i++) //search up to the next high tide
    {
        double localLowTide = 100;
        //int localLowTideIndex = 0;
        
        if ([[tideArrInit objectAtIndex:i] doubleValue] < [[tideArrInit objectAtIndex:i+1] doubleValue] && [[tideArrInit objectAtIndex:i] doubleValue] < [[tideArrInit objectAtIndex:i-1] doubleValue])
        {
            previousLowTideIndex = i;
            
            previousLowTide = [[tideArrInit objectAtIndex:i] doubleValue];
            if(localLowTide > previousLowTide)
            {
                localLowTide = previousLowTide;
            }
        }
    }
    
    double currentTide = [[tideArrInit objectAtIndex:currentTime] doubleValue];
    double tideRatio = 1 - ((nextMaxTide - previousLowTide) - (currentTide - previousLowTide))/(nextMaxTide - previousLowTide);
    if(tideRatio < 0.1)
    {
        tideRatio = 0.15; //limiting so that something shows up on scree
    }
    else if(tideRatio > 0.9)
    {
        tideRatio = 1;
    }
    [spotDictInit setObject:[NSNumber numberWithDouble:tideRatio] forKey:@"tideRatio"];
    
    if(currentTime == 0)
    {
        currentTime = 1; //push it up one for checking. we automatcially know that the next low tide of consequence will bein the future.
    }
    for (int i = currentTime; i < [tideArrInit count]; i++)
    {
        if ([[tideArrInit objectAtIndex:i] doubleValue] < [[tideArrInit objectAtIndex:i+1] doubleValue]  && [[tideArrInit objectAtIndex:i] doubleValue] < [[tideArrInit objectAtIndex:i-1] doubleValue])
        {
            nextLowTideIndex = i;
            NSString* timeStr = [DateHandler getTimeFromIndex:nextLowTideIndex];
            [spotDictInit setObject:timeStr forKey:@"nextLowTide"];
            break;
        }
    }
    
    //determine if tide is rising or dropping
    bool risingTide = false;
    if(nextHighTideIndex >= nextLowTideIndex)
    {
        //tide is dropping beacause it is closer to a low tide
        risingTide = false;
    }
    else
    {
        risingTide = true;
    }
    
    [spotDictInit setObject:[NSNumber numberWithBool:risingTide] forKey:@"risingTide"];
    
    return spotDictInit;
}

-(NSMutableDictionary*)getASpotDictionary:(NSString*)spotNameInit andCounty:(NSString*)countyInit andID:(int)idInit
{
    NSMutableDictionary* subSpotDict = [spotsDict objectForKey:spotNameInit];
    NSMutableDictionary* subCountyDict = [countiesDict objectForKey:countyInit];
    
    NSMutableDictionary* aSpotDict = [[NSMutableDictionary alloc] init];
    
    if ([[subSpotDict allKeys] count] < 1 || [[subCountyDict allKeys] count] < 1)
    {
        return nil;
    }
    if([[subCountyDict allKeys] count] == 4)
    {
        for (NSString* key in [subCountyDict allKeys])
        {
            if([subCountyDict objectForKey:key] == nil)
            {
                return nil;
            }
            if([subCountyDict objectForKey:key] != nil && [[subCountyDict allKeys] count] == 4)
            {
                [aSpotDict setObject:[subCountyDict objectForKey:key] forKey:key];
            }
        }
    }
    else
    {
        return nil;
    }
    
    if([[subSpotDict allKeys] count] == 2)
    {
        NSDictionary* surfDict =[subSpotDict objectForKey:@"surf"];
        if(![surfDict isKindOfClass:[NSDictionary class]] || surfDict == nil || [[surfDict allKeys] count] < 2)
        {
            return nil;
        }
        for (NSString* key in [subSpotDict allKeys])
        {
            [aSpotDict setObject:[subSpotDict objectForKey:key] forKey:key];
        }
    }
    else{
        return nil;
    }
    
    aSpotDict = [self setCurrentValuesForSpotDict:aSpotDict];
    [aSpotDict setObject:[NSNumber numberWithBool:false] forKey:@"isOld"];
    [aSpotDict setObject:[DateHandler getCurrentDateString] forKey:@"downloadDate"];
    
    [reportDicts setObject:aSpotDict forKey:[NSNumber numberWithInteger:idInit]];
    
    [OfflineData saveSpotDict:aSpotDict withID:idInit];
    
    return aSpotDict;
}

#warning this is where 7 day break??
-(NSMutableArray*)getShorternedVersionOfArray:(NSMutableArray*)arrInit ofLength:(int)rangeInit
{
    NSMutableArray* shortArray = [[NSMutableArray alloc] init];
    
    int shortArrLength = rangeInit*24; //there are 24 items in a day array
    
    if ([arrInit count] == 0)
    {
        //        NSLog(@"got a problem");
        return arrInit;
    }
    
    for (int i = 0; i< shortArrLength ;i++ )
    {
        [shortArray addObject:[arrInit objectAtIndex:i]];
    }
    
    return shortArray;
}

-(NSMutableArray*)getShorternedVersionOfXValArray:(NSMutableArray*)arrInit ofLength:(int)rangeInit
{
    NSMutableArray* shortArray = [[NSMutableArray alloc] init];
    
    int shortArrLength = rangeInit*24; //there are 24 items in a day array
    
    if ([arrInit count] == 0)
    {
        return arrInit;
    }
    
    if (rangeInit > 1)
    {
        for (int i = 0; i<shortArrLength;i++ )
        {
            [shortArray addObject:[arrInit objectAtIndex:i]];
        }
    }
    else
    {
        for (int i = 0; i<shortArrLength;i++ )
        {
            if (i < 13)
            {
                [shortArray addObject:[NSString stringWithFormat:@"%d",i]];
            }
            else
            {
                [shortArray addObject:[NSString stringWithFormat:@"%d",i - 12]];
            }
        }
    }
    
    return shortArray;
}

-(void)removeSpotDictionary:(int)spotID
{
    NSString* spotName = [DBQueries getSpotNameOfSpotID:spotID];
    [spotsDict removeObjectForKey:spotName];
}

-(void)removeData
{
    //remove all objects from the dictionaries for a fresh download
    [spotsDict removeAllObjects];
    [countiesDict removeAllObjects];
}

@end
