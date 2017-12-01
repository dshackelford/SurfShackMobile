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
//#import "SpitcastData+Wind.h"
//#import "SpitcastData+Tide.h"
//#import "SpitcastData+Swell.h"


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

-(void)startSurfDataDownloadForLocation:(int)locInit
{
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/spot/forecast/%d/?dcat=week",locInit];
    
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
              NSLog(@"json data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              NSLog(@"%@",jsonDataArray);
              
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
              [aSurfDict setObject:[NSNumber numberWithInt:locInit] forKey:@"spotID"];
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
              NSLog(@"json data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              NSLog(@"%@",jsonDataArray);
              
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
              
              for (int i = 0; i < [[weekArray objectAtIndex:0] count]; i++)
              {
                  WindPacket* windPacket = [[weekArray objectAtIndex:0] objectAtIndex:i];
                  [windDirectionArray addObject:[NSNumber numberWithInteger:[windPacket getDirectionDegrees]]];
              }
              
              [aWindDict setObject:windDirectionArray forKey:@"windDirectionArray"];
              
              [aWindDict setObject:@"Wind (Powered by Spitcast)" forKey:@"plotLabel"];
              
              [aWindDict setObject:@"Surf Height (Powered by Spitcast)" forKey:@"plotLabel"];
              
              [self.collector windDataDictReceived:aWindDict];
          }
      }] resume];
    
}

/*
-(NSMutableDictionary*)getWindDataForCounty:(NSString*)countyInit
{
    NSMutableArray* windData = [self getWindData:[DateHandler getArrayOfDayStrings:longDataLength]  andCounty:countyInit];
    
    NSMutableDictionary* windDict = [self makeDictionaryForData:windData ofTypeHeight:NO];

    
    NSMutableArray* windDirectionArray = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [[windData objectAtIndex:0] count]; i++)
    {
        WindPacket* windPacket = [[windData objectAtIndex:0] objectAtIndex:i];
        [windDirectionArray addObject:[NSNumber numberWithInteger:[windPacket getDirectionDegrees]]];
    }
    
    [windDict setObject:windDirectionArray forKey:@"windDirectionArray"];
    
    [windDict setObject:@"Wind (Powered by Spitcast)" forKey:@"plotLabel"];
    
    return windDict;
}*/

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
              NSLog(@"json data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              NSLog(@"%@",jsonDataArray);
              
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
              
              [self.collector tideDataDictReceived:tideDict];
          }
      }] resume];
}

/*
-(NSMutableDictionary*)getTideDataForCounty:(NSString*)countyInit
{
    NSMutableArray* tideData = [self getTideData:[DateHandler getArrayOfDayStrings:longDataLength]  andCounty:countyInit];
    
    NSMutableDictionary* tideDict = [self makeDictionaryForData:tideData ofTypeHeight:YES];
    
    [tideDict setObject:@"Tide (Powered by Spitcast)" forKey:@"plotLabel"];
    
    return tideDict;
}*/



-(double)getWaterTempForCounty:(NSString*)countyInit
{
    NSMutableArray* surfDataDayRange = [[NSMutableArray alloc] init];
    
            //ESTABLISH THE URL TO GRAB INFO FROM
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/water-temperature/%@/",countyInit];
            
    //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH
    NSArray* jsonDataDict = [self retunJsonDataFromURLString:stringURL];
            
    //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
    NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
    
    WaterTempPacket* waterTemp = [[WaterTempPacket alloc] init:jsonDataDict];
    [aDayDataArray addObject:waterTemp];

    [surfDataDayRange addObject:aDayDataArray];
    
    return [[aDayDataArray lastObject] getTempF];
}


/*
-(NSMutableArray*)getWindData:(NSMutableArray*)dateStrArray andCounty:(NSString*)county
{
    NSMutableArray* windDataDayRange = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [dateStrArray count]; i++)
    {
        //ESTABLISH THE URL TO GRAB INFO FROM
        NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/wind/%@/?dcat=day&dval=%@",county,[dateStrArray objectAtIndex:i]];
        
        //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH
        NSArray* jsonDataArray = [self retunJsonDataFromURLString:stringURL];
        
        //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
        NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
        
        //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
        for (id dataSet in jsonDataArray)
        {
            WindPacket* windData = [[WindPacket alloc] init:dataSet];
            [aDayDataArray addObject:windData];
        }
        
        aDayDataArray = [self organizeArrayByTime:aDayDataArray andDate:[dateStrArray objectAtIndex:i]];
        
        [windDataDayRange addObject:aDayDataArray];
    }
    
    //RETURN MUTABLE ARRAY OF HOURLY DATA SETS
    return windDataDayRange;
}*/

/*
-(NSMutableArray*)getTideData:(NSMutableArray*)dateStrArray andCounty:(NSString*)county
{
    NSMutableArray* tideDataDayRange = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [dateStrArray count]; i++)
    {
        //ESTABLISH THE URL TO GRAB INFO FROM
        NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/tide/%@/?dcat=day&dval=%@",county,[dateStrArray objectAtIndex:i]];
        
        //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH
        NSArray* jsonDataArray = [self retunJsonDataFromURLString:stringURL];
        
        //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
        NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
        
        //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
        for (id dataSet in jsonDataArray)
        {
            TidePacket* tideData = [[TidePacket alloc] init:dataSet];
            [aDayDataArray addObject:tideData];
        }
        
        aDayDataArray = [self organizeArrayByTime:aDayDataArray andDate:[dateStrArray objectAtIndex:i]];
        
        [tideDataDayRange addObject:aDayDataArray];
    }
    
    //RETURN MUTABLE ARRAY OF HOURLY DATA SETS
    return tideDataDayRange;
}
*/

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
              NSLog(@"json data download completed");
              NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
              NSLog(@"%@",jsonDataArray);
              
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
              
              
              
              [self.collector swellDataDictReceived:swellDict];
          }
      }] resume];
}

-(NSMutableArray*)getSwellDataForCounty:(NSString *)countyInit
{
    NSMutableArray* dateStrArray = [DateHandler getArrayOfDayStrings:[PreferenceFactory getLongRange]];
    NSMutableArray* tideDataDayRange = [[NSMutableArray alloc] init];
    
    for (int i = 0; i < [dateStrArray count]; i++)
    {
        //ESTABLISH THE URL TO GRAB INFO FROM
        NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/swell/%@/?dcat=day&dval=%@",countyInit,[dateStrArray objectAtIndex:i]];
        
        //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH
        //NSArray* jsonDataArray = [self retunJsonDataFromURLString:stringURL];
        
        NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
        
        NSLog(@"started downloadtask %i",i);
        [[session dataTaskWithURL:[NSURL URLWithString:stringURL] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error)
          {
              if(error)
              {
                  NSLog(@"there was an error in getting json data from url in spitcast");
              }
              else
              {
                  NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
                  
                  NSLog(@"started downloadtask %i",i);
                  //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
                  NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
                  
                  //ITERATE THROUGH AND INIT INDIVIDUAL HOURLY DATA
                  for (id dataSet in jsonDataArray)
                  {
                      SwellPacket* swellData = [[SwellPacket alloc] init:dataSet];
                      [aDayDataArray addObject:swellData];
                  }
                  
                  aDayDataArray = [self organizeArrayByTime:aDayDataArray andDate:[dateStrArray objectAtIndex:i]];
                  
                  [tideDataDayRange addObject:aDayDataArray];
              }
          }] resume];
    }
    
    //RETURN MUTABLE ARRAY OF HOURLY DATA SETS
    return tideDataDayRange;
    
}



#pragma mark - DATA AQUISITION // Preparation
-(NSArray*)retunJsonDataFromURLString:(NSString*)stringInit
{
    NSURL* theURL = [NSURL URLWithString:stringInit];
    
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
        }
    }] resume];
    
    
    NSURLRequest* theRequest = [NSURLRequest requestWithURL:theURL];
    
    //MAKE THE CONNECTION TO THE INTERNET
    NSURLConnection* theConnection = [NSURLConnection connectionWithRequest:theRequest delegate:nil];
    //    NSURLSession
    
    [theConnection start];
    
    //COLLECT THE NECESSARY DATA
    NSData* receivedData = [[NSData alloc]initWithContentsOfURL:theURL];
    
    //PARSE THE DATA GRABBED FROM SPITCAST - HAS 35 DATA PACKAGES FOR ONE HOUR EACH

    if (receivedData != nil)
    {
        NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:receivedData options:0 error:nil];
        
        [theConnection cancel];
        
        return  jsonDataArray;
    }
    else
    {
        [theConnection cancel];
        return nil;
    }
     
}

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
-(NSMutableArray*)getAllSpotsAndCounties
{
    //ESTABLISH THE URL TO GRAB INFO FROM
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/spot/all"];

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
    return allSpotData;
}

-(NSMutableArray*)getNearBySpots:(NSString*)latInit andLon:(NSString*)lonInit
{
    //ESTABLISH THE URL TO GRAB INFO FROM
    NSString* stringURL = [NSString stringWithFormat:@"http://api.spitcast.com/api/spot/nearby?longitude=%@&latitude=%@",lonInit,latInit];
    
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
    return nearBySpotArray;
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
