//
//  OpenMapOverlay.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 1/9/18.
//  Copyright © 2018 Dylan Shackelford. All rights reserved.
//

#ifndef OpenMapOverlay_h
#define OpenMapOverlay_h

#import <MapKit/MapKit.h>

@interface OpenMapOverlay : MKTileOverlay

-(NSURL*)URLForTilePath:(MKTileOverlayPath)path;
@end

#endif /* OpenMapOverlay_h */
