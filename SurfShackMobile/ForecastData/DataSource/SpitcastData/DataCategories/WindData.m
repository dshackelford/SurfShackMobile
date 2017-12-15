//
//  WindData.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/14/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WindData.h"
#import "WindPacket.h"

@implementation WindData

-(id)initWithCounty:(NSString *)countyInit andOp:(AsyncBlockOperation *)op andCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    self.urlStr = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/wind/%@/?dcat=week",countyInit];
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
        NSLog(@"%@ wind data was downloaded",self.countyName);
        NSMutableDictionary* windDict = [NSMutableDictionary dictionary];
        [windDict setValue:self.countyName forKey:@"countyID"];
        [self.collector windDataDictReceived:nil];
        [self.op complete];
        return;
    }
    NSLog(@"%@ county wind data download completed",self.countyName);
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
    [aWindDict setValue:self.countyName forKey:@"countyID"];
    [self.collector windDataDictReceived:aWindDict];
    [self.op complete];
    }
}
@end

