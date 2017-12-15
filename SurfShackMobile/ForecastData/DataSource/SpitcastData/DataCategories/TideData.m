//
//  TideData.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/14/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TideData.h"
#import "TidePacket.h"

@implementation TideData

-(id)initWithCounty:(NSString *)countyInit andOp:(AsyncBlockOperation *)op andCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    self.urlStr = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/tide/%@/?dcat=week",countyInit];
    self.countyName = countyInit;
    self.downloadedData = nil;
    self.op = op;
    self.collector = collectorInit;
    return self;
}

-(void)gotSomeData:(NSData *)dataInit
{
    if(dataInit != nil)
    {
      NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:dataInit options:0 error:nil];
      //NSLog(@"%@",jsonDataArray);
    
      //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
      NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
    
    
      if([jsonDataArray count] == 0 || jsonDataArray == nil)
      {
          NSLog(@"%@ county no tide data was downloaded",self.countyName);
          NSMutableDictionary* tidDict = [NSMutableDictionary dictionary];
          [tidDict setValue:self.countyName forKey:@"countyID"];
          [self.collector tideDataDictReceived:nil];
          [self.op complete];
          return;
      }
      NSLog(@"%@ county tide data download completed",self.countyName);
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
      [tideDict setValue:self.countyName forKey:@"countyID"];
      [self.collector tideDataDictReceived:tideDict];
      [self.op complete];
    }
}

@end
