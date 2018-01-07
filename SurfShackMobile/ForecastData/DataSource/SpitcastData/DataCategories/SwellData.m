//
//  SwellData.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/14/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwellData.h"
#import "SwellPacket.h"

@implementation SwellData

-(id)initWithCounty:(NSString *)countyInit andOp:(AsyncBlockOperation *)op andCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    self.urlStr = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/swell/%@/?dcat=week",countyInit];
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
              
              
              if([jsonDataArray count] == 0 || jsonDataArray == nil)
              {
                  NSLog(@"%@ county: no swell data was downloaded",self.countyName);
                  [self.collector swellDataDictReceived:nil forCounty:self.countyName];
                  [self.op complete];
                  return;
              }
              NSLog(@"%@ county swell data download completed",self.countyName);
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
              //NSMutableDictionary* swellDict = [self makeDictionaryForData:weekArray ofTypeHeight:YES];
              
              NSMutableArray* dictWeekArray = [NSMutableArray array];
              
              for(int i = 0; i < [weekArray count]; i = i + 1)
              {
                  NSMutableArray* dictArray = [NSMutableArray array];
                  
                  for(SwellPacket* packet in [weekArray objectAtIndex:i])
                  {
                      [dictArray addObject:[packet makeDictFromPacket]];
                  }
                  
                  [dictWeekArray addObject:dictArray];
              }
              
              NSMutableDictionary* swellDict = [NSMutableDictionary dictionary];
              [swellDict setObject:dictWeekArray forKey:@"swellArray"];
              [swellDict setValue:self.countyName forKey:@"countyID"];
              [self.collector swellDataDictReceived:swellDict forCounty:self.countyName];
              [self.op complete];
    }
}
@end
