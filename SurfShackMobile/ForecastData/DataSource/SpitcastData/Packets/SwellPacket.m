//
//  SwellPacket.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/7/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SwellPacket.h"

@implementation SwellPacket

-(id)init:(id)dataSet
{
    self = [super init];
    
    [self setDay:[dataSet objectForKey:@"day"]];
    [self setDate:[dataSet objectForKey:@"date"]];
    [self setTime:[dataSet objectForKey:@"hour"]];
    [self setCountyName:[dataSet objectForKey:@"name"]];
    [self setHSTValue:[[dataSet objectForKey:@"hst"] doubleValue]];
    
    swellData = [[NSMutableArray alloc] init];
    
    //there are 5 swell info dictionaries to check
    for (int i = 0; i < 5; i++)
    {
        NSString* key = [NSString stringWithFormat:@"%d",i];
        
        NSDictionary* obj = [dataSet objectForKey:key];
        
        NSNumber* dir = [obj objectForKey:@"dir"];
        //double dirDouble = [dir doubleValue];
        
        if ([dir isEqual:[NSNull null]] || dir == nil)
        {
#warning still need to figure out how to handle nill portions
            //NSLog(@"swell data portion is null");
        }

        else
        {
            NSMutableDictionary* swellInfoDict = [NSMutableDictionary dictionary];
            [swellInfoDict setObject:dir forKey:@"dir"];
            [swellInfoDict setObject:[obj objectForKey:@"tp"] forKey:@"tp"];
            [swellInfoDict setObject:[obj objectForKey:@"hs"] forKey:@"hs"];
            [swellData addObject:swellInfoDict];
           // [swellData addObject:[dataSet objectForKey:key]];
        }
    }
    
    return self;
}

-(NSMutableDictionary*)makeDictFromPacket
{
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    [dict setObject:[self getDay] forKey:@"day"];
    [dict setObject:[self getDate] forKey:@"date"];
    [dict setObject:[NSNumber numberWithDouble:[self getTime]] forKey:@"hour"];
    //[dict setObject:[self getCountyName] forKey:@"countyName"];
    [dict setObject:[NSNumber numberWithDouble:[self getHST]] forKey:@"hst"];
    [dict setObject:swellData forKey:@"swellArray"];
    
    return dict;
}

-(void)setHSTValue:(double)hstInit
{
    hst = hstInit;
}

-(double)getHST
{
    return hst;
}

-(NSMutableArray*)getSwellDataArray
{
    return swellData;
}


@end
