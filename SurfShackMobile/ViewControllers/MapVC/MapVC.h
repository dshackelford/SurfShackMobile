//
//  MapVC.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/7/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#ifndef MapVC_h
#define MapVC_h

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "OpenMapOverlay.h"
#import "MasterViewController.h"

@interface MapVC : MasterViewController <MKMapViewDelegate>

@property MKMapView* mapView;
@property MKTileOverlayRenderer* openMapRenderer;

@end

#endif /* MapVC_h */
