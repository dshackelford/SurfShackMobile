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
    
    for (int i = 0; i < 5; i++)
    {
        NSString* key = [NSString stringWithFormat:@"%d",i];
        
        NSDictionary* obj = [dataSet objectForKey:key];
        
//        NSNumber* dir = [obj objectForKey:@"dir"];
        
        if ([[obj objectForKey:@"dir"] isEqual:[NSNull null]])
        {
            NSLog(@"swell data portion is null");
        }

        else
        {
            [swellData addObject:[dataSet objectForKey:key]];
        }
    }
    
    return self;
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
