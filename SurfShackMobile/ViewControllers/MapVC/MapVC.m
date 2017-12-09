//
//  MapVC.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/7/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapVC.h"


@implementation MapVC

-(void)viewDidLoad
{
    self.mapView = [[MKMapView alloc] initWithFrame:self.view.frame];
    
    [self.view addSubview:self.mapView];
    
    MKCoordinateSpan span = MKCoordinateSpanMake(0.05, 0.05);
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(32.745598,-117.247786);
    MKCoordinateRegion region = MKCoordinateRegionMake(center,span);
    
    [self.mapView setRegion:region];
    
    self.mapView.mapType = MKMapTypeHybrid;
    self.mapView.showsCompass = YES;
   // self.mapView.
}

@end
