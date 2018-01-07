//
//  MapVC.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 12/7/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MapVC.h"
#import <FMDB/FMDB.h>
#import "AppUtilities.h"
#import "SpotAnnotation.h"

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
    
    
    FMDatabase* fmDB = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    
    if([fmDB open])
    {
        FMResultSet* result = [fmDB executeQuery:@"SELECT SpotID,SpotName,SpotCounty,SpotLat,SpotLon FROM SpitcastSpots"];
        while([result next])
        {
            CLLocationCoordinate2D spotCoord = CLLocationCoordinate2DMake([result doubleForColumn:@"SpotLat"], [result doubleForColumn:@"SpotLon"]);
            MKPointAnnotation* annot = [[MKPointAnnotation alloc] init];
            annot.coordinate = spotCoord;
            annot.title = [result stringForColumn:@"SpotName"];
            annot.subtitle = [result stringForColumn:@"SpotCounty"];
            [self.mapView addAnnotation:annot];
        }
    }
}

- (nullable MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    if([annotation isKindOfClass:[SpotAnnotation class]])
    {
        // Try to dequeue an existing pin view first.
        MKPinAnnotationView*    pinView = (MKPinAnnotationView*)[mapView
                                                                 dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!pinView)
        {
            // If an existing pin view was not available, create one.
            pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                      reuseIdentifier:@"CustomPinAnnotationView"];
            pinView.pinColor = MKPinAnnotationColorRed;
            pinView.animatesDrop = YES;
            pinView.canShowCallout = YES;
            
            // If appropriate, customize the callout by adding accessory views (code not shown).
        }
        else
            pinView.annotation = annotation;
        
        return pinView;
    }
    
    return nil;
}

@end
