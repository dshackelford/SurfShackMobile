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


@implementation SpitcastData
@synthesize collector;

-(id)initWithShortLength:(int)shortLengthInit andLongLength:(int)longLengthInit andCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    //these vals are determined from the preferences which is called in the preference Factory that will return this object
    shortDataLength = shortLengthInit;
    longDataLength = 6; 
    
    dataDict = [[NSMutableDictionary alloc] init];
    swellDict = [[NSMutableDictionary alloc] init];
    
    self.collector = collectorInit;

    return self;
}

-(void)startSurfDataDownloadForSpotID:(int)spotIDInit andSpotName:(NSString *)spotNameInit
{
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/spot/forecast/%d/?dcat=week",spotIDInit];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithURL:[NSURL URLWithString:stringURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
          //NSInteger internalServerError = 500;
          NSLog(@"Error code: %ld",(long)httpResponse.statusCode);
          if(error)
          {
              NSLog(@"there was an error in getting json data from url in spitcast");
          }
          /*else if(httpResponse.statusCode  == 500)
           {
           NSLog(@"link does not work: internal server error 500. Try a differt ID?");
           //need to increment errors for partial download
           }*/
          else
          {
              NSLog(@"json surf data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              //NSLog(@"%@",jsonDataArray);
              
              //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
              NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
              
              //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
              for (id dataSet in jsonDataArray)
              {
                  SurfPacket* surfPacket = [[SurfPacket alloc] init:dataSet];
                  [aDayDataArray addObject:surfPacket];
              }
              
              NSString* prevDay =[(SurfPacket*)[aDayDataArray objectAtIndex:0] getDay];
              NSMutableArray* tempDayArray = [NSMutableArray array];
              NSMutableArray* weekArray = [NSMutableArray array];
              
              for(SurfPacket* packet in aDayDataArray)
              {
                  NSString* day = [packet getDay];
                  
                  if(![day isEqualToString:prevDay])
                  {
                      //found the next day
                      [weekArray addObject:tempDayArray.mutableCopy];
                      [tempDayArray removeAllObjects];
                  }
                  else
                  {
                      //add this packet to current temp array
                      [tempDayArray addObject:packet];
                  }
                  prevDay = day;
              }
              
              NSMutableDictionary* aSurfDict =[self makeDictionaryForData:weekArray ofTypeHeight:YES];
              [aSurfDict setObject:@"Surf Height (Powered by Spitcast)" forKey:@"plotLabel"];
              [aSurfDict setObject:spotNameInit forKey:@"spotName"];
              [self.collector surfDataDictReceived:aSurfDict];
          }
      }] resume];
}

-(void)startWindDataDownloadForCounty:(NSString*)countyInit
{
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/wind/%@/?dcat=week",countyInit];
        
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithURL:[NSURL URLWithString:stringURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
          //NSInteger internalServerError = 500;
          NSLog(@"Error code: %ld",(long)httpResponse.statusCode);
          if(error)
          {
              NSLog(@"there was an error in getting json data from url in spitcast");
          }
          /*else if(httpResponse.statusCode  == 500)
           {
           NSLog(@"link does not work: internal server error 500. Try a differt ID?");
           //need to increment errors for partial download
           }*/
          else
          {
              NSLog(@"json wind data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              //NSLog(@"%@",jsonDataArray);
              
              //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
              NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
              
              //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
              for (id dataSet in jsonDataArray)
              {
                  WindPacket* surfPacket = [[WindPacket alloc] init:dataSet];
                  [aDayDataArray addObject:surfPacket];
              }
              
              NSString* prevDay =[(WindPacket*)[aDayDataArray objectAtIndex:0] getDay];
              NSMutableArray* tempDayArray = [NSMutableArray array];
              NSMutableArray* weekArray = [NSMutableArray array];
              
              for(WindPacket* packet in aDayDataArray)
              {
                  NSString* day = [packet getDay];
                  
                  if(![day isEqualToString:prevDay])
                  {
                      //found the next day
                      [weekArray addObject:tempDayArray.mutableCopy];
                      [tempDayArray removeAllObjects];
                  }
                  else
                  {
                      //add this packet to current temp array
                      [tempDayArray addObject:packet];
                  }
                  prevDay = day;
              }
              
              NSMutableDictionary* aWindDict =[self makeDictionaryForData:weekArray ofTypeHeight:NO];
              
              NSMutableArray* windDirectionArray = [[NSMutableArray alloc] init];
              
              for (int i = 0; i < [weekArray count] - 1; i++)
              {
                  for(int j = 0; j < [[weekArray objectAtIndex:i] count] - 1; j ++)
                  {
                      WindPacket* windPacket = [[weekArray objectAtIndex:i] objectAtIndex:j];
                      [windDirectionArray addObject:[NSNumber numberWithInteger:[windPacket getDirectionDegrees]]];
                  }
              }
              
              [aWindDict setObject:windDirectionArray forKey:@"windDirectionArray"];
              
              [aWindDict setObject:@"Wind (Powered by Spitcast)" forKey:@"plotLabel"];
              
              [aWindDict setObject:@"Surf Height (Powered by Spitcast)" forKey:@"plotLabel"];
              [aWindDict setValue:countyInit forKey:@"countyID"];
              [self.collector windDataDictReceived:aWindDict];
          }
      }] resume];
    
}


-(void)startTideDataDownloadForCounty:(NSString*)countyInit
{
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/tide/%@/?dcat=week",countyInit];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithURL:[NSURL URLWithString:stringURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
          //NSInteger internalServerError = 500;
          NSLog(@"Error code: %ld",(long)httpResponse.statusCode);
          if(error)
          {
              NSLog(@"there was an error in getting json data from url in spitcast");
          }
          /*else if(httpResponse.statusCode  == 500)
           {
           NSLog(@"link does not work: internal server error 500. Try a differt ID?");
           //need to increment errors for partial download
           }*/
          else
          {
              NSLog(@"json tide data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              //NSLog(@"%@",jsonDataArray);
              
              //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
              NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
              
              //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
              for (id dataSet in jsonDataArray)
              {
                  TidePacket* surfPacket = [[TidePacket alloc] init:dataSet];
                  [aDayDataArray addObject:surfPacket];
              }
              
              NSString* prevDay =[(TidePacket*)[aDayDataArray objectAtIndex:0] getDay];
              NSMutableArray* tempDayArray = [NSMutableArray array];
              NSMutableArray* weekArray = [NSMutableArray array];
              
              for(TidePacket* packet in aDayDataArray)
              {
                  NSString* day = [packet getDay];
                  
                  if(![day isEqualToString:prevDay])
                  {
                      //found the next day
                      [weekArray addObject:tempDayArray.mutableCopy];
                      [tempDayArray removeAllObjects];
                  }
                  else
                  {
                      //add this packet to current temp array
                      [tempDayArray addObject:packet];
                  }
                  prevDay = day;
              }
              
              //probably need to run organize by time somewhere??
              NSMutableDictionary* tideDict = [self makeDictionaryForData:weekArray ofTypeHeight:YES];
              
              [tideDict setObject:@"Tide (Powered by Spitcast)" forKey:@"plotLabel"];
              [tideDict setValue:countyInit forKey:@"countyID"];
              [self.collector tideDataDictReceived:tideDict];
          }
      }] resume];
}


-(void)startWaterTempDownloadForCounty:(NSString*)countyInit
{
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/water-temperature/%@/?dcat=week",countyInit];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithURL:[NSURL URLWithString:stringURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
          //NSInteger internalServerError = 500;
          NSLog(@"Error code: %ld",(long)httpResponse.statusCode);
          if(error)
          {
              NSLog(@"there was an error in getting json data from url in spitcast");
          }
          /*else if(httpResponse.statusCode  == 500)
           {
           NSLog(@"link does not work: internal server error 500. Try a differt ID?");
           //need to increment errors for partial download
           }*/
          else
          {
              NSLog(@"json water temp data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              //NSLog(@"%@",jsonDataArray);
              
              WaterTempPacket* waterTemp = [[WaterTempPacket alloc] init:jsonDataArray];
              
              NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
#warning this should probably ask the preferencs what the units are?
              [tempDict setObject:[NSNumber numberWithDouble:[waterTemp getTempF]] forKey:@"waterTemp"];
              [tempDict setValue:countyInit forKey:@"countyID"];
              [self.collector waterTempDataDictReceived:tempDict];
          }
      }] resume];
}

-(void)startSwellDataDownloadForCounty:(NSString*)countyInit
{
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/swell/%@/?dcat=week",countyInit];
    
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithURL:[NSURL URLWithString:stringURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
      {
          NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
          //NSInteger internalServerError = 500;
          NSLog(@"Error code: %ld",(long)httpResponse.statusCode);
          if(error)
          {
              NSLog(@"there was an error in getting json data from url in spitcast");
          }
          /*else if(httpResponse.statusCode  == 500)
           {
           NSLog(@"link does not work: internal server error 500. Try a differt ID?");
           //need to increment errors for partial download
           }*/
          else
          {
              NSLog(@"json swell data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              //NSLog(@"%@",jsonDataArray);
              
              //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
              NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
              
              //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
              for (id dataSet in jsonDataArray)
              {
                  SwellPacket* surfPacket = [[SwellPacket alloc] init:dataSet];
                  [aDayDataArray addObject:surfPacket];
              }
              
              NSString* prevDay =[(SwellPacket*)[aDayDataArray objectAtIndex:0] getDay];
              NSMutableArray* tempDayArray = [NSMutableArray array];
              NSMutableArray* weekArray = [NSMutableArray array];
              
              for(SwellPacket* packet in aDayDataArray)
              {
                  NSString* day = [packet getDay];
                  
                  if(![day isEqualToString:prevDay])
                  {
                      //found the next day
                      [weekArray addObject:tempDayArray.mutableCopy];
                      [tempDayArray removeAllObjects];
                  }
                  else
                  {
                      //add this packet to current temp array
                      [tempDayArray addObject:packet];
                  }
                  prevDay = day;
              }
              
              //probably need to run organize by time somewhere??
              NSMutableDictionary* swellDict = [self makeDictionaryForData:weekArray ofTypeHeight:YES];
              
              [swellDict setValue:countyInit forKey:@"countyID"];
              
              [self.collector swellDataDictReceived:swellDict];
          }
      }] resume];
}


#pragma mark - DATA AQUISITION // Preparation

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
}

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
    
    /*
    //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH
    NSArray* jsonDataArray = [self retunJsonDataFromURLString:stringURL];

    //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
    NSMutableArray* allSpotData = [[NSMutableArray alloc] init];

    //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
    for (id dataSet in jsonDataArray)
    {
        CountyInfoPacket* aCountyPacket = [[CountyInfoPacket alloc] init:dataSet];
        [allSpotData addObject:aCountyPacket];
    }

    //RETURN MUTABLE ARRAY OF HOURLY DATA SETS
    return allSpotData;*/
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
    
    /*
    //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH
    NSArray* jsonDataArray = [self retunJsonDataFromURLString:stringURL];
    
    //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
    NSMutableArray* nearBySpotArray = [[NSMutableArray alloc] init];
    
    //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
    for (id dataSet in jsonDataArray)
    {
        NearByPacket* nearByPacket = [[NearByPacket alloc] init:dataSet];
        [nearBySpotArray addObject:nearByPacket];
    }
    
    //RETURN MUTABLE ARRAY OF HOURLY DATA SETS
    return nearBySpotArray;*/
}


-(int)getShortRange
{
    return shortDataLength;
}

-(int)getLongRange
{
    return longDataLength;
}

-(void)setShortRange:(int)rangeInit
{
    
}

-(void)setLongRange:(int)rangeInit
{
    
}


@end
