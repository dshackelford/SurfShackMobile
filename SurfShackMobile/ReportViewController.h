//
//  ReportViewController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/20/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import "MasterViewController.h"
#import "SpitcastData.h"
#import "PlotView.h"
#import "DataHandler.h"
#import "Bezier.h"

#import "arrowCell.h"
#import "CurrentWeather.h"

#import "DataFactory.h"

#import "AppDelegate.h"
#import "DBManager.h"

#import "CompassView.h"
#import "DatumView.h"
#import "SubInfoView.h"


@import Charts;
@interface ReportViewController : MasterViewController <CLLocationManagerDelegate>
{
    DBManager* db;
    
    id<DataHandler> surfDataSource; //DON'T USE THIS ANYMORE

    //CURRENT SPOT
    DataFactory* dataFactory;
    NSString* county;
    NSString* spotName;
    NSMutableDictionary* spotDict;
    NSArray* favSpots;
    
    //SUB-VIEWS
    PlotView* aPlotView;
    CompassView* aCompView;
    SubInfoView* infoView;
    
    //DISPLAY INFO HANDLING
    int currentView; //1 = surf, 2 = wind, 3 = tide;
    BOOL listView; //when the list of spots are shown
    BOOL plotAdded;
    BOOL viewSet; //used for redrawing "viewDidLayoutSubviews"
    
    CLLocationManager* locationManager;
    CLLocation* currentLocation;
    float heading;
    
    //REPORT LABELS
    UILabel* titleLabel;
    UILabel* headingLabel;
    
    //GESTURES
    UITapGestureRecognizer* singleTap;
    UILongPressGestureRecognizer* longPress;
    UISwipeGestureRecognizer* swipeDown;
    UITapGestureRecognizer* doubleTap;
    UISwipeGestureRecognizer* swipeUp;
    
    IBOutlet UIActivityIndicatorView* indicator;
}

@property NSInteger index;

-(void)chooseDataToDisplay;

#pragma mark - Setters
-(void)setSpotDict:(NSMutableDictionary*)dictInit;
-(void)setDataFactory:(DataFactory*)aDataFactory;

-(void)refreshData;

@end
