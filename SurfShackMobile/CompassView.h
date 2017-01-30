//
//  CompassView.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/17/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Bezier.h"
#import "DatumView.h"
#import "SwellPacket.h"
#import "Bezier.h"
#import "PreferenceFactory.h"
#import "DataFactory.h"

@interface CompassView : UIView
{
    UIImageView* marker1;
    
    UIBezierPath* trianglePath;
    
    int markerInitialDegree;
    UIImageView* rim;

    UIImageView* tideImage;
    
    UILabel* tempLabel;
    UILabel* sunsetLabel;
    UILabel* sunriseLabel;
    
    UIView* markerView;
    
    DatumView* sunsetDatum;
    DatumView* sunriseDatum;
    
    DatumView* highTideDatum;
    DatumView* lowTideDatum;
    
    DatumView* mainSwellDatum;
    DatumView* secondSwellDatum;
    
    //the current angle of markerView rotation
    double angle;
    int currentTag;
}

-(void)rotateMarkerView:(double)degInit;
-(void)decideWhichDatumToShow:(int)currentTagInit withSpotDict:(NSDictionary*)dictInit andHeading:(float)headingInit;
-(void)updateColor;

@end
