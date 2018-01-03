//
//  CountyHandler.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/24/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppUtilities.h"
#import "DBManager.h"
#import <FMDB/FMDB.h>

@interface CountyHandler : NSObject

+(NSString*)getCountyOfSpot:(int)locInit;
+(NSString*)moldStringForURL:(NSString*)strInit;
@end
