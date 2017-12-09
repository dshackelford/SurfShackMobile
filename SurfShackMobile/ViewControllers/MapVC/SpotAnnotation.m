//
//  SpotAnnotation.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/8/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotAnnotation.h"

@implementation SpotAnnotation
@synthesize aCoord;

-(id)initWithCoordinate:(CLLocationCoordinate2D)coordInit
{
    self = [super init];
    
    self.aCoord = coordInit;
    
    return self;
}
@end
