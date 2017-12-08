//
//  DataFactory.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/18/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataFactory.h"

@implementation DataFactory

-(id)init
{
    self = [super init];
    
    self.surfSource = [PreferenceFactory getDataServiceWithCollector:self];
    self.weatherSource = [PreferenceFactory getWeatherServiceWithCollector:self];
    
    spotsDict = [[NSMutableDictionary alloc] init]; //a spot: surf heights and weather
    countiesDict = [[NSMutableDictionary alloc] init];
    
    db = [[DBManager alloc] init];
    
    dateOnLastDownload = 0; //probably should read from a file?
    
    return self;
}

//arrOfLocs holds an array of spotID's
//this is called from report page view contorller
-(void)getDataForSpots:(NSArray*)spotIDArray andCounties:(NSArray*)countiesArray
{
    NSMutableArray* arrOfLocs = [[NSMutableArray alloc] init];
    NSMutableArray* arrOfSpotNames = [[NSMutableArray alloc] init];
    
    //to avoid multithread issues with database queries
    for (NSNumber* num in spotIDArray)
    {
        int intNum = [num intValue];
        
        [db openDatabase];
        [arrOfLocs addObject: [db getLocationOfSpot:intNum]];
        [arrOfSpotNames addObject:[db getSpotNameOfSpotID:intNum]];
        [db closeDatabase];
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

        //If I haven't already downloaed the spotsDict, don't redownload it!
        if ([spotsDict objectForKey:spotName] == nil)
        {
            dateOnLastDownload = [[DateHandler getCurrentDateString] intValue];

            [self.surfSource startSurfDataDownloadForSpotID:spotID andSpotName:spotName];
            [self.weatherSource startWeatherDownloadForLoc:aLoc andSpotID:spotID andSpotName:spotName];
        }
    }
    
    //COUNTY DATA
    for (NSString* county in countiesArray)
    {
        if ([countiesDict objectForKey:county] == nil)
        {
           NSString* spitCounty = [CountyHandler moldStringForURL:county];
            
            [self.surfSource startWaterTempDownloadForCounty:spitCounty];
            [self.surfSource startWindDataDownloadForCounty:spitCounty];
            [self.surfSource startTideDataDownloadForCounty:spitCounty];
            [self.surfSource startSwellDataDownloadForCounty:spitCounty];
        }
    }
}

-(void)surfDataDictReceived:(NSMutableDictionary*)surfData
{
    NSMutableDictionary* aSpotDict = [spotsDict objectForKey:[surfData objectForKey:@"spotName"]];
    if(aSpotDict == nil)
    {
        aSpotDict = [NSMutableDictionary dictionary];
    }
    
    [aSpotDict setObject:surfData forKey:@"surf"];
    
    [spotsDict setObject:aSpotDict forKey:[surfData objectForKey:@"spotName"]];
    [self checkSpotDict];
}

-(void)tideDataDictReceived:(NSMutableDictionary *)tideData
{
    NSMutableDictionary* aCountyDict = [countiesDict objectForKey:[tideData objectForKey:@"countyID"]];
    if(aCountyDict == nil)
    {
        aCountyDict = [NSMutableDictionary dictionary];
    }
    
    [aCountyDict setObject:tideData forKey:@"tide"];
    
    [countiesDict setObject:aCountyDict forKey:[tideData objectForKey:@"countyID"]];
    [self checkCountyDict];
}

-(void)windDataDictReceived:(NSMutableDictionary *)windData
{
    NSMutableDictionary* aCountyDict = [countiesDict objectForKey:[windData objectForKey:@"countyID"]];
    if(aCountyDict == nil)
    {
        aCountyDict = [NSMutableDictionary dictionary];
    }
    
    [aCountyDict setObject:windData forKey:@"wind"];
    
    [countiesDict setObject:aCountyDict forKey:[windData objectForKey:@"countyID"]];
    [self checkCountyDict];
}

-(void)swellDataDictReceived:(NSMutableDictionary *)swellData
{
    NSMutableDictionary* aCountyDict = [countiesDict objectForKey:[swellData objectForKey:@"countyID"]];
    if(aCountyDict == nil)
    {
        aCountyDict = [NSMutableDictionary dictionary];
    }
    
    [aCountyDict setObject:swellData forKey:@"swell"];
    
    [countiesDict setObject:aCountyDict forKey:[swellData objectForKey:@"countyID"]];
    [self checkCountyDict];
}

- (void)waterTempDataDictReceived:(NSMutableDictionary *)waterTempData
{
    NSMutableDictionary* aCountyDict = [countiesDict objectForKey:[waterTempData objectForKey:@"countyID"]];
    if(aCountyDict == nil)
    {
        aCountyDict = [NSMutableDictionary dictionary];
    }
    
    [aCountyDict setObject:[waterTempData objectForKey:@"waterTemp"] forKey:@"waterTemp"];
    
    [countiesDict setObject:aCountyDict forKey:[waterTempData objectForKey:@"countyID"]];
    [self checkCountyDict];
}


- (void)weatherDataDictReceived:(NSMutableDictionary *)weatherData
{
    NSMutableDictionary* aSpotDict = [spotsDict objectForKey:[weatherData objectForKey:@"spotName"]];
    if(aSpotDict == nil)
    {
        aSpotDict = [NSMutableDictionary dictionary];
    }
    [aSpotDict setObject:weatherData forKey:@"weatherDict"];

    [spotsDict setObject:aSpotDict forKey:[weatherData objectForKey:@"spotName"]];
     [self checkSpotDict];
}

-(void)checkCountyDict
{
    for(NSString* key in [countiesDict allKeys])
    {
        NSMutableDictionary* countyDict = [countiesDict objectForKey:key];
        
        NSLog(@"county keys %@",[countyDict allKeys]);
        if([[countyDict allKeys] count] == 4) //swell/wind/tide/watertemp
        {
            NSLog(@"sent county notification under key: %@",key);
            NSOperationQueue* q = [NSOperationQueue mainQueue];
            NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:key object:countyDict];
            }];
            [q addOperation:op];
        }
    }
}

-(void)checkSpotDict
{
    for(NSString* key in [spotsDict allKeys])
    {
        NSMutableDictionary* spotDict = [spotsDict objectForKey:key];
        
        NSLog(@"spot keys %@",[spotDict allKeys]);
        if([[spotDict allKeys] count] == 2)
        {
            NSLog(@"sent spot notification under key: %@",key);
            NSOperationQueue* q = [NSOperationQueue mainQueue];
            NSBlockOperation* op = [NSBlockOperation blockOperationWithBlock:^{
                [[NSNotificationCenter defaultCenter] postNotificationName:key object:spotDict];
            }];
            [q addOperation:op];
        }
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
    //get the first day array of swells
    
    if ([[[aSpotDictInit objectForKey:@"swellDict"] objectAtIndex:0] count] > 0)
    {
        NSMutableArray* swellArr = [[aSpotDictInit objectForKey:@"swellDict"] objectAtIndex:0];
    
        int currentIndex = [DateHandler getIndexFromCurrentTime];
    
        NSMutableDictionary* hourSwellDict = [[[swellArr objectAtIndex:currentIndex] getSwellDataArray] objectAtIndex:0];
    
    
        if ([hourSwellDict objectForKey:@"dir"] != nil)
        {
            double currentDirection = [[hourSwellDict objectForKey:@"dir"] doubleValue];
            currentDirection = currentDirection + 180;
            
            [aSpotDictInit setObject:[NSNumber numberWithDouble:currentDirection] forKey:@"currentSwellDirection"];
        }
    }
    return aSpotDictInit;
    
}

-(NSMutableDictionary*)setCurrentWindDirection:(NSMutableDictionary*)aSpotDictInit
{
    NSMutableDictionary* windDict = [aSpotDictInit objectForKey:@"wind"];

    int currentIndex = [DateHandler getIndexFromCurrentTime];
    
    NSNumber* currentDirection = [[windDict objectForKey:@"windDirectionArray"] objectAtIndex:currentIndex];
    
    [aSpotDictInit setObject:currentDirection forKey:@"windDirection"];
    
    return aSpotDictInit;
}

-(NSMutableDictionary*)setCurrentImportantSwells:(NSMutableDictionary*)aSpotDictInit
{
    if ([[aSpotDictInit objectForKey:@"swellDict"] count] > 0)
    {
        //get the first day array of swells
        NSMutableArray* swellArr = [[aSpotDictInit objectForKey:@"swellDict"] objectAtIndex:0];
    
        int currentIndex = [DateHandler getIndexFromCurrentTime];
    
        NSMutableDictionary* hourSwellDict = [[NSMutableDictionary alloc] init];
    
        if ([[swellArr objectAtIndex:currentIndex] getSwellDataArray] > 0 &&[[swellArr objectAtIndex:currentIndex] getSwellDataArray] != nil )
        {

            hourSwellDict = [[[swellArr objectAtIndex:currentIndex] getSwellDataArray] objectAtIndex:0];
    
            if(hourSwellDict != nil)
            {
                double hst = [[swellArr objectAtIndex:currentIndex] getHST];
                double tp = [[hourSwellDict objectForKey:@"tp"] doubleValue];
                double hs = [[hourSwellDict objectForKey:@"hs"] doubleValue];
                double height = hs*hst;
                height = ceil(height);
        
                int direction = [[hourSwellDict objectForKey:@"dir"] intValue] + 180;
        
                NSString* dirStr = [self getDirectionStrFromDegree:direction];
            
                NSString* mainSwellInfo = [NSString stringWithFormat:@"Dir: %@ \nTP: %.fs \nHt: %.f ft",dirStr,tp,height];
        
                [aSpotDictInit setObject:mainSwellInfo forKey:@"mainSwellInfo"];
            }

        }
        if ([[[swellArr objectAtIndex:currentIndex] getSwellDataArray] count] > 1)
        {
            hourSwellDict = [[[swellArr objectAtIndex:currentIndex] getSwellDataArray] objectAtIndex:1];
    
            if(hourSwellDict != nil)
            {
                double hst = [[swellArr objectAtIndex:currentIndex] getHST];
                double tp = [[hourSwellDict objectForKey:@"tp"] doubleValue];
                double hs = [[hourSwellDict objectForKey:@"hs"] doubleValue];
                double height = hs*hst;
                height = ceil(height);
            
                int direction = [[hourSwellDict objectForKey:@"dir"] intValue];
        
                direction = direction + 180;
                NSString* dirStr = [self getDirectionStrFromDegree:direction];
            
                NSString* secondSwellInfo = [NSString stringWithFormat:@"Dir: %@ \nTP: %.fs \nHt: %.f ft",dirStr,tp,height];
        
                [aSpotDictInit setObject:secondSwellInfo forKey:@"secondSwellInfo"];
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
        int localLowTideIndex = 0;
        
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

-(NSMutableDictionary*)getASpotDictionary:(NSString*)spotNameInit andCounty:(NSString*)countyInit
{
    NSMutableDictionary* subSpotDict = [spotsDict objectForKey:spotNameInit];
    NSMutableDictionary* subCountyDict = [countiesDict objectForKey:countyInit];
    
    NSMutableDictionary* aSpotDict = [[NSMutableDictionary alloc] init];
    
    if ([[subSpotDict allKeys] count] < 1 || [[subCountyDict allKeys] count] < 1)
    {
        return nil;
    }
    
    for (NSString* key in [subCountyDict allKeys])
    {
        [aSpotDict setObject:[subCountyDict objectForKey:key] forKey:key];
    }
    
    for (NSString* key in [subSpotDict allKeys])
    {
        [aSpotDict setObject:[subSpotDict objectForKey:key] forKey:key];
    }
    
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
    [db openDatabase];
    NSString* spotName = [db getSpotNameOfSpotID:spotID];
//    NSString* countyName
    [db closeDatabase];
    [spotsDict removeObjectForKey:spotName];
}

-(void)removeData
{
    //remove all objects from the dictionaries for a fresh download
    [spotsDict removeAllObjects];
    [countiesDict removeAllObjects];
}

@end
