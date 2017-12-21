//
//  SurfData.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/14/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfData.h"
#import "SurfPacket.h"

@implementation SurfData

-(id)initWithSpotID:(int)spotIDInit andSpotName:(NSString *)spotName andOp:(AsyncBlockOperation *)op andCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    self.urlStr = [NSString stringWithFormat:@"http://api.spitcast.com/api/spot/forecast/%d/?dcat=week",spotIDInit];
    self.spotName = spotName;
    self.op = op;
    self.collector = collectorInit;
    return self;
}

-(void)gotSomeData:(NSData *)dataInit
{
    if(dataInit != nil)
    {
        NSArray* jsonDataArray = [NSJSONSerialization JSONObjectWithData:dataInit options:0 error:nil];
      
        //INITIALIZE ARRAY TO HOLD THE 25 HOURS WORTH OF SURF DATA AT SPECIFIC LOCATION
        NSMutableArray* aDayDataArray = [[NSMutableArray alloc] init];
      
        if([jsonDataArray count] == 0 || jsonDataArray == nil)
        {
          [self.collector surfDataDictReceived:nil forSpot:self.spotName];
          [self.op complete];
          return;
        }
        NSLog(@"%@ spot surf data download completed",self.spotName);
      
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
      [aSurfDict setObject:self.spotName forKey:@"spotName"];
      [self.collector surfDataDictReceived:aSurfDict forSpot:self.spotName];
      [self.op complete];
  }
}

@end
