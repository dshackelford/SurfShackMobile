//
//  WaterTempData.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/15/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "WaterTempData.h"
#import "WaterTempPacket.h"

@implementation WaterTempData

-(id)initWithCounty:(NSString *)countyInit andOp:(AsyncBlockOperation *)op andCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    self.urlStr = [NSString stringWithFormat:@"http://api.spitcast.com/api/county/water-temperature/%@/",countyInit];
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
        NSDictionary* jsonDataDict = [NSJSONSerialization JSONObjectWithData:dataInit options:0 error:nil];
        //NSLog(@"%@",jsonDataArray);


    if([[jsonDataDict allKeys] count] == 0 || jsonDataDict == nil)
    {
        NSLog(@"%@ county no water temp data was downloaded",self.countyName);
        [self.collector waterTempDataDictReceived:nil forCounty:self.countyName];
        [self.op complete];
        return;
    }
    NSLog(@"%@ county water temp data download completed",self.countyName);
    WaterTempPacket* waterTemp = [[WaterTempPacket alloc] init:jsonDataDict];

    NSMutableDictionary* tempDict = [NSMutableDictionary dictionary];
    #warning this should probably ask the preferencs what the units are?
    
    [tempDict setObject:[NSNumber numberWithDouble:[waterTemp getTempF]] forKey:@"waterTemp"];
    [tempDict setValue:self.countyName forKey:@"countyID"];
    [self.collector waterTempDataDictReceived:tempDict forCounty:self.countyName];
    [self.op complete];
    }
}
@end
