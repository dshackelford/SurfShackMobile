//
//  SpitcastData.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/12/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//
#import "AppUtilities.h"
#import "DateHandler.h"
#import "CountyHandler.h"
#import "PreferenceFactory.h"

#import "SurfPacket.h"
#import "CountyInfoPacket.h"
#import "WindPacket.h"
#import "TidePacket.h"
#import "NearByPacket.h"
#import "SwellPacket.h"
#import "WaterTempPacket.h"

#import "DataCollector.h"
#import "DataSource.h"

@interface SpitcastData : NSObject <DataSource>
{
    //these values will be set in the factory based of the preferences

    int shortDataLength;
    int longDataLength;
    
    NSMutableArray* countyList;
}

@end

