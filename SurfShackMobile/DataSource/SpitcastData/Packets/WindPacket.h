//
//  WindPacket.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/24/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import "InfoPacket.h"
@interface WindPacket : InfoPacket
{
    int degrees;
    NSString* degreesText;
    int speedKTS;
    int speedMPH;
}

-(void)setDegrees:(int)degInit;
-(void)setDegreesText:(NSString*)degTextInit;
-(void)setSpeedMPH:(double)speedInit;

-(double)getSpeedMPH;
-(double)getSpeedKTS;
-(int)getDirectionDegrees;
@end