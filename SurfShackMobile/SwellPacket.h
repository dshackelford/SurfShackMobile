//
//  SwellPacket.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/7/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import "InfoPacket.h"

@interface SwellPacket : InfoPacket
{
    NSMutableArray* swellData;
    double hst;
}

-(NSMutableArray*)getSwellDataArray;
-(double)getHST;

@end