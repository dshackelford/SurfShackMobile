//
//  SpotAnnotation.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/8/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#ifndef SpotAnnotation_h
#define SpotAnnotation_h

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>

@interface SpotAnnotation : NSObject <MKAnnotation>
@property CLLocationCoordinate2D aCoord;
-(id)initWithCoordinate:(CLLocationCoordinate2D)coordInit;
@end
#endif /* SpotAnnotation_h */
