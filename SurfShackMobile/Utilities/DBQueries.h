//
//  DBQueries.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/8/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#ifndef DBQueries_h
#define DBQueries_h

#import <UIKit/UIKit.h>
@interface DBQueries : NSObject

+(NSString*)countOfFavoriteSpots;
+(NSString*)getCountyOfSpotID:(int)idInit;
@end
#endif /* DBQueries_h */
