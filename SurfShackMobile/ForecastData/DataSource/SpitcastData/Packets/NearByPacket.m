//
//  NearByPacket.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/26/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "NearByPacket.h"


@implementation NearByPacket

-(id)init:(id)dataSet
{
    self = [super init];
    
    [self setSpotID:[[dataSet objectForKey:@"spot_id"] doubleValue]];
    [self setSpotName:[dataSet objectForKey:@"spot_name"]];
    
    return self;
}

-(void)setCoord:(NSString*)coordInit
{
    NSArray* arr = [coordInit componentsSeparatedByString:@","];
    NSLog(@"%@",arr);
}

@end