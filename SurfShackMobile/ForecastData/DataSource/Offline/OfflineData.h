//
//  OfflineData.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 10/17/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#ifndef OfflineData_h
#define OfflineData_h

#import "FMDB.h"
#import <UIKit/UIKit.h>
#import "AppUtilities.h"

@interface OfflineData : NSObject

+(void)saveSpotDict:(NSMutableDictionary*)aSpotDict withID:(int)idInit;
+(NSMutableDictionary*)getOfflineDataForID:(int)idInit;
@end
#endif /* OfflineData_h */
