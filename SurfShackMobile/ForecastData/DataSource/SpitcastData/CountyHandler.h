//
//  CountyHandler.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/24/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppUtilities.h"
#import "PreferenceFactory.h"
#import "SpitcastData.h"
#import "DBManager.h"
#import "CountyInfoPacket.h"

@interface CountyHandler : NSObject

+(void)createCountiesFile;
+(NSString*)getCountyOfSpot:(int)locInit;
+(NSString*)moldStringForURL:(NSString*)strInit;
@end