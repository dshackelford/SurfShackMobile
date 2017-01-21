//
//  TidePacket.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/26/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//
#import "InfoPacket.h"
@interface TidePacket : InfoPacket
{
    double tide;
    double tideMeters;
}

-(void)setTide:(double)tideInit;
-(void)setTideMeters:(double)tideInit;


-(double)getTide;
-(double)getTideMeters;
@end