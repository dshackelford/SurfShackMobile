//
//  DataCategory.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/14/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DataCategory.h"
#import "PreferenceFactory.h"
#import "InfoPacket.h"

@implementation DataCategory
@synthesize collector;

-(id)initWithSpotID:(int)spotIDInit andSpotName:(NSString*)spotName andOp:(AsyncBlockOperation*)op andCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    self.urlStr = [NSString stringWithFormat:@"http://api.spitcast.com/api/spot/forecast/%d/?dcat=week",spotIDInit];
    
    self.downloadedData = nil;
    self.op = op;
    self.collector = collectorInit;
    return self;
}

-(id)initWithCounty:(NSString*)countyInit andOp:(AsyncBlockOperation*)op andCollector:(id<DataCollector>)collectorInit
{
    self = [super init];
    
    self.downloadedData = nil;
    self.op = op;
    self.collector = collectorInit;
    
    return self;
}

-(void)grabData
{
    [self pingTheWeb];
    
}

-(void)pingTheWeb
{
    NSURLSession* session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    NSURL* url =[NSURL URLWithString:self.urlStr];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSHTTPURLResponse* httpResponse = (NSHTTPURLResponse*)response;
        //NSInteger internalServerError = 500;
        //NSLog(@"Error code: %ld",(long)httpResponse.statusCode);
        if(error)
        {
            //return false;
        }
        /*else if(httpResponse.statusCode  == 500)
         {
         NSLog(@"link does not work: internal server error 500. Try a differt ID?");
         //need to increment errors for partial download
         }*/
        else
        {
            [self gotSomeData:data];
            
        }
    }] resume];
}

-(void)gotSomeData:(NSData*)dataInit
{
    //do some logic on the data
    [self.op complete];
}


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


@end
