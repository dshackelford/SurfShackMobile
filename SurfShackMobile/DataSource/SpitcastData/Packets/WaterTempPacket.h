//
//  WaterTempPacket.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/18/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import "InfoPacket.h"
@interface WaterTempPacket : InfoPacket
{
    int buoyID;
    double tempF;
    double tempC;
    NSString* clothing;
}

-(void)setBouyID:(int)buoyInit;
-(void)setTempF:(double)tempFInit;
-(void)setTempC:(double)tempCInit;
-(void)setClothing:(NSString*)clothingInit;

-(double)getTempF;
-(double)getTempC;
@end