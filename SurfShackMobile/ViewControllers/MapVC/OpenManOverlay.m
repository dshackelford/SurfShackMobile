//
//  OpenManOverlay.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 1/9/18.
//  Copyright © 2018 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OpenMapOverlay.h"

@implementation OpenMapOverlay

-(NSURL*)URLForTilePath:(MKTileOverlayPath)path
{
    NSString* str  = [NSString stringWithFormat:@"https://tile.openstreetmap.org/%ld/%ld/%ld.png",path.z,path.x,path.y];
    return [NSURL URLWithString:str];
}

@end
