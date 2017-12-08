//
//  DataFactoryDelegate.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/7/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#ifndef DataFactoryDelegate_h
#define DataFactoryDelegate_h

#import <UIKit/UIKit.h>

@protocol DataFactoryDelegate

-(void)gotDataForCounty:(NSString*)countyID;
-(void)gotDataForSpot:(NSString*)spotID;

@end
#endif /* DataFactoryDelegate_h */
