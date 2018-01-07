//
//  SpitcastData.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/12/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpitcastData.h"
#import "OfflineData.h"
#import <AsyncBlockOperation/AsyncBlockOperation.h>
#import "SurfData.h"
#import "WindData.h"
#import "TideData.h"
#import "SwellData.h"
#import "WeatherData.h"
#import "WaterTempData.h"

@implementation SpitcastData
@synthesize collector;

-(id)initWithShortLength:(int)shortLengthInit andLongLength:(int)longLengthInit andCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    //these vals are determined from the preferences which is called in the preference Factory that will return this object
    shortDataLength = shortLengthInit;
    longDataLength = 6; 
    
    //dataDict = [[NSMutableDictionary alloc] init];
    //swellDict = [[NSMutableDictionary alloc] init];
    
    self.collector = collectorInit;

    return self;
}

-(id)initWithCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    self.collector = collectorInit;
    return self;
}

-(void)startSurfDataDownloadForSpotID:(int)spotIDInit andSpotName:(NSString *)spotNameInit andOp:(AsyncBlockOperation *)op
{
    SurfData* data = [[SurfData alloc] initWithSpotID:spotIDInit andSpotName:spotNameInit andOp:op andCollector:self.collector];
    [data grabData];
}

-(void)startWindDataDownloadForCounty:(NSString*)countyInit andOp:(AsyncBlockOperation *)op
{
    
    WindData* data = [[WindData alloc] initWithCounty:countyInit andOp:op andCollector:self.collector];
    [data grabData];
}


-(void)startTideDataDownloadForCounty:(NSString*)countyInit andOp:(AsyncBlockOperation *)op
{
    TideData* data = [[TideData alloc] initWithCounty:countyInit andOp:op andCollector:self.collector];
    [data grabData];
}


-(void)startWaterTempDownloadForCounty:(NSString*)countyInit andOp:(AsyncBlockOperation*)op
{
    WaterTempData* data = [[WaterTempData alloc] initWithCounty:countyInit andOp:op andCollector:self.collector];
    [data grabData];
}

-(void)startSwellDataDownloadForCounty:(NSString*)countyInit andOp:(AsyncBlockOperation *)op
{
    SwellData* data = [[SwellData alloc] initWithCounty:countyInit andOp:op andCollector:self.collector];
    [data grabData];
}


#pragma mark - DATA AQUISITION // Preparation
/*
-(NSMutableArray*)organizeArrayByTime:(NSMutableArray*)arrayInit andDate:(NSString*)dateInit
{
    NSMutableArray* holdArray = [[NSMutableArray alloc] init];
    
    //don't include the last data packet which is next day
    
    int indexToRemove = 0;
    for (int i = 0; i < [arrayInit count]; i++)
    {
        id obj = [arrayInit objectAtIndex:i];
        if (![[obj getDate] isEqualToString:dateInit ])
        {
            indexToRemove = i;
        }
    }
    
    if ([arrayInit count] > 0)
    {
        [arrayInit removeObjectAtIndex:indexToRemove];
    }
    
    for (int i = 0; i < [arrayInit count] ; i++)
    {
        [holdArray addObject:[NSNumber numberWithInt:0]];
    }
    
    for (int i = 0; i < [arrayInit count]; i++)
    {
        //downshift real times to fit the index starting at 0.
        [holdArray replaceObjectAtIndex:[[arrayInit objectAtIndex:i] getTime] withObject:[arrayInit objectAtIndex:i]];
    }
    
    //REMOVE ANY NON PACKET OBJECTS(SPITCAST SOMETIMES RETURNS CORRUPTED DATA
    NSMutableIndexSet* removalIndex = [[NSMutableIndexSet alloc] init];
    
    for (int i = 0; i < [holdArray count]; i++)
    {
        if ([[holdArray objectAtIndex:i] isKindOfClass:[InfoPacket class]])
        {
            //DON'T DO ANYTING
        }
        else
        {
            [removalIndex addIndex:i];
        }
    }
    
    if ([removalIndex count] > 0)
    {
        [holdArray removeObjectsAtIndexes:removalIndex];
    }
    
    
    return holdArray;
}*/

#pragma mark - Getting Plot Data
-(NSMutableDictionary*)makeDictionaryForData:(NSMutableArray*)dataArrayInit ofTypeHeight:(BOOL)heightBool
{
    NSMutableArray* mags = [self getMagnitudesFromPackets:dataArrayInit];
    NSMutableArray* days = [self getDaysFromPackets:dataArrayInit];
    
    NSString* indicatorStr;
    if (heightBool == YES)
    {
        indicatorStr = [PreferenceFactory getIndicatorStrForHeight];
    }
    else
    {
        indicatorStr = [PreferenceFactory getIndicatorStrForSpeed];
    }
    
    NSMutableDictionary* aDict = [[NSMutableDictionary alloc] initWithObjects:@[mags,days,indicatorStr] forKeys:@[kMags,kDayArr,kIndicatorStr]];
    
    return aDict;
    
}

-(NSMutableArray*)getDaysFromPackets:(NSMutableArray*)dataArrayInit
{
    NSMutableArray* dayArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [dataArrayInit count]; i++)
    {
        NSMutableArray* aDayData = [dataArrayInit objectAtIndex:i];
        
        for (int j = 0; j < [aDayData count]; j++)
        {
            id packet = [aDayData objectAtIndex:j];
            [dayArray addObject:[packet getDay]];
        }
    }
    return dayArray;
    
}

-(NSMutableArray*)getMagnitudesFromPackets:(NSMutableArray*)dataArrayInit
{
    NSMutableArray* magArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [dataArrayInit count]; i++)
    {
        NSMutableArray* aDayData = [dataArrayInit objectAtIndex:i];
        
        for (int j = 0; j < [aDayData count]; j++)
        {
            id packet = [aDayData objectAtIndex:j];

            [magArray addObject:[NSNumber numberWithDouble:[packet getPlotData]]];
        }
    }
    
    return magArray;
}


#pragma mark - Location Data
-(void)getAllSpotsAndCounties
{
    //ESTABLISH THE URL TO GRAB INFO FROM
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/spot/all"];

    NSURL* theURL = [NSURL URLWithString:stringURL];
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [[session dataTaskWithURL:theURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if(error)
          {
              NSLog(@"there was an error in getting json data from url in spitcast");
          }
          else
          {
              NSLog(@"json data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              NSLog(@"%@",jsonDataArray);
              
               NSMutableArray* allSpotData = [[NSMutableArray alloc] init];
              
              //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
              for (id dataSet in jsonDataArray)
              {
                  CountyInfoPacket* aCountyPacket = [[CountyInfoPacket alloc] init:dataSet];
                  [allSpotData addObject:aCountyPacket];
              }
              
              [self.collector countyAndSpotsReceived:allSpotData];
          }
      }] resume];
}

-(void)getNearBySpots:(NSString*)latInit andLon:(NSString*)lonInit
{
    //ESTABLISH THE URL TO GRAB INFO FROM
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/spot/nearby?longitude=%@&latitude=%@",lonInit,latInit];

    NSURL* theURL = [NSURL URLWithString:stringURL];
    
    NSURLSessionConfiguration* sessionConfig = [NSURLSessionConfiguration defaultSessionConfiguration];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:sessionConfig];
    
    [[session dataTaskWithURL:theURL completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          if(error)
          {
              NSLog(@"there was an error in getting json data from url in spitcast");
          }
          else
          {
              NSLog(@"json data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              NSLog(@"%@",jsonDataArray);
              
              //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
              NSMutableArray* nearBySpotArray = [[NSMutableArray alloc] init];
              
              //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
              for (id dataSet in jsonDataArray)
              {
                  NearByPacket* nearByPacket = [[NearByPacket alloc] init:dataSet];
                  [nearBySpotArray addObject:nearByPacket];
              }
              
              [self.collector nearbySpotsReceived:nearBySpotArray];
          }
      }] resume];

}

- (void)startWeatherDownloadForLoc:(CLLocation *)locInit andSpotID:(int)spotID andSpotName:(NSString *)spotNameInit {
    
}


@end
