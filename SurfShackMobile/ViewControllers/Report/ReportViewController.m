//
//  ReportViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/20/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportViewController.h"
#import "OfflineData.h"
#import "DBQueries.h"

@implementation ReportViewController

-(void)viewDidLoad
{
    
    [self restrictRotation:NO];
    
    screenSize = [UIScreen mainScreen].bounds.size;
    if (screenSize.width > screenSize.height) //maintain a constant screen size for consistency
    {
        //swap the values for a load in horizontal
        double x = screenSize.width;
        screenSize.width = screenSize.height;
        screenSize.height = x;
    }
    
    db = [[DBManager alloc] init];
    
    favSpots = [DBQueries getSpotFavorites];
    spotID = [[favSpots objectAtIndex:self.index] intValue];
    
    county = [CountyHandler getCountyOfSpot:spotID];
    
    spotName = [DBQueries getSpotNameOfSpotID:spotID];
    
    self.view.backgroundColor = [UIColor clearColor];

    [self registerForNotifications];
    
    aCompView = [[CompassView alloc] initWithFrame:CGRectMake(0,100, screenSize.width, screenSize.height/3)];
    [self.view addSubview:aCompView];
    
    aPlotView = [[PlotView alloc] initWithFrame:CGRectMake(0,100 + aCompView.frame.size.height, screenSize.width, 200)];
    [self.view addSubview:aPlotView];
    
    aCompView.hidden = YES;
    aPlotView.hidden = YES;
    
    titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 70, screenSize.width/3 - 20, 25)];
    titleLabel.font = [UIFont boldSystemFontOfSize:23];
    [self.view addSubview:titleLabel];
    
    headingLabel  = [[UILabel alloc] initWithFrame:CGRectMake(screenSize.width/2 - 25, 70, 50, 20)];
    headingLabel.textAlignment = NSTextAlignmentCenter;
    headingLabel.font = [UIFont boldSystemFontOfSize:17];
    headingLabel.text = @"";
    [self.view addSubview:headingLabel];
    
    //maybe determine this from the preference on what the user wants to see first?
    currentView = 1;
    
    [self initializeCLLocationManager];
    
    self.noDataCount = 0;
    
    [dataFactory addReportVC:self ForID:spotID]; //essentially this is just saying that this report view is the main view???
    
    [super viewDidLoad];
}

-(void)registerForNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTap:) name:@"tap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"refreshData" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(futureIndexSet:) name:@"futureIndexRatio" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColor:) name:@"changeColorPref" object:nil];
}

-(void)initializeCLLocationManager
{
    //LOCATION MANAGER FOR COMPASS
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingHeading];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestAlwaysAuthorization];
}

-(void)changeColor:(NSNotification*)notification
{
    NSDictionary* dict = [PreferenceFactory getPreferences];
    
    self.navigationController.navigationBar.barTintColor = [dict objectForKey:kColorScheme];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self restrictRotation:NO];
    
    [self.activityDelegate isLoadingData:true];
    
    //set the title bar in the pageview controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTitle" object:[NSNumber numberWithInteger:self.index]];
    
    spotDict = [dataFactory dataForSpotID:spotID];
    
    if(spotDict)
    {
        aPlotView.isOfflineData = [[spotDict objectForKey:@"isOld"] boolValue];
        [self.activityDelegate isLoadingData:aPlotView.isOfflineData];
        [self chooseDataToDisplay];
    }

    [super viewWillAppear:YES];
}

//called when new data downloaded from data factory
-(void)youHaveData:(NSMutableDictionary*)reportDictInit
{
    if(reportDictInit)
    {
        spotDict = reportDictInit;
        
        aPlotView.isOfflineData = [[reportDictInit objectForKey:@"isOld"] boolValue]; //read from the report Dict, there should be a value for if the data is old or not.
        [self.activityDelegate isLoadingData:aPlotView.isOfflineData];
        NSLog(@"%@ choosing to display new data it received",spotName);
        [self chooseDataToDisplay];
    }
}



-(void)showNoDataAlert
{
    UIAlertController* alert = [UIAlertController alertControllerWithTitle:@"Data Missing" message:@"There seems to be missing data for this spot, try another spot close to this one." preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Ok" style:UIAlertActionStyleDefault handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
    
}
-(void)refreshData:(NSNotification*)notification
{
    aCompView.hidden = YES;
    infoView.hidden = YES;
    
    headingLabel.hidden = YES;
    aPlotView.hidden = YES;
    [self.activityDelegate isLoadingData:true];
    NSLog(@"attempt resfresh");
}

-(void)futureIndexSet:(NSNotification*)notification
{
    int index = [notification.object doubleValue]*[[[spotDict objectForKey:@"surf"] objectForKey:@"mags"] count];
    NSMutableDictionary* futureDict = [dataFactory setCurrentValuesForSpotDict:spotDict.mutableCopy];
    
}

//if there is data, then current values can be derived thusly
-(void)spotHasData
{
    [self.activityDelegate isLoadingData:false]; //tell pageViewController that I'm done downloading
    
    spotDict = [dataFactory setCurrentValuesForSpotDict:spotDict];
    [OfflineData saveSpotDict:spotDict withID:[[favSpots objectAtIndex:self.index] intValue]];
    aPlotView.isOfflineData = false;
    [self chooseDataToDisplay];
    NSLog(@"height units: %@",[PreferenceFactory getIndicatorStrForHeight]);
}


//ROTATION NOTIFICATIN EXECUTION
- (void) didRotate:(NSNotification *)notification
{
    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
    
    switch (orientation)
    {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationLandscapeRight:
        case UIInterfaceOrientationLandscapeLeft:
            [self chooseDataToDisplay];
            break;
        default:
            break;
    }
}


-(void)chooseDataToDisplay
{
    if (spotDict)
    {
        aPlotView.hidden = NO;
        NSDictionary* aSpotDict = spotDict;
        NSDictionary* infoDict;
    
        //the comp view will parse the spotDict for the current values and display them thusly
        [aCompView decideWhichDatumToShow:currentView withSpotDict:spotDict andHeading:heading];
        NSString* indicatorStr;         //surf View!
        if (currentView == 1) //surf view!
        {
            infoDict = [aSpotDict objectForKey:@"surf"];
            indicatorStr = [PreferenceFactory getIndicatorStrForHeight];

        }
        //wind View!
        else if(currentView == 2)
        {
            infoDict = [aSpotDict objectForKey:@"wind"];
            indicatorStr = [PreferenceFactory getIndicatorStrForSpeed];
        }
        //tide View!
        else if(currentView == 3)
        {
            infoDict = [aSpotDict objectForKey:@"tide"];
            indicatorStr = [PreferenceFactory getIndicatorStrForHeight];
        }
    
        UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;

        if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
        {
            NSMutableArray* longMags = [dataFactory getShorternedVersionOfArray:[infoDict objectForKey:kMags] ofLength:[PreferenceFactory getLongRange]];
            
            NSMutableArray* longXVals = [dataFactory getShorternedVersionOfXValArray:[infoDict objectForKey:kDayArr] ofLength:[PreferenceFactory getLongRange]];
            
            [aPlotView establishViewWithData:longMags withXVals:longXVals withIndicatorVal:indicatorStr andPlotLabel:[infoDict objectForKey:@"plotLabel"]];
            
            NSLog(@"width: %f, height: %f",screenSize.width,screenSize.height);
            
            [aPlotView updateFrame:CGRectMake(0, 50, screenSize.height, 2*screenSize.width/3) forCurrentView:currentView];
            
            [self.tabBarController.tabBar setHidden:YES];
            aCompView.hidden = YES;
            infoView.hidden = YES;
            
            headingLabel.hidden = YES;
            
        }
        else if(orientation == UIInterfaceOrientationPortrait)
        {
            NSMutableArray* shortMags = [dataFactory getShorternedVersionOfArray:[infoDict objectForKey:kMags] ofLength:[PreferenceFactory getShortRange]];
            
            NSMutableArray* shortXVals = [dataFactory getShorternedVersionOfXValArray:[infoDict objectForKey:kDayArr] ofLength:[PreferenceFactory getShortRange]];
            
            [aPlotView establishViewWithData:shortMags withXVals:shortXVals withIndicatorVal:indicatorStr andPlotLabel:[infoDict objectForKey:@"plotLabel"]];
            
            [aPlotView updateFrame:CGRectMake(0,screenSize.height - screenSize.height/3 - 75, screenSize.width, screenSize.height/3) forCurrentView:currentView];
  
            [self.tabBarController.tabBar setHidden:NO];
            aCompView.hidden = NO;
            infoView.hidden = NO;
            headingLabel.hidden = NO;
            [aCompView updateColor];
        }

    }
}


#pragma mark - Compass Creation
- (void) locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
    heading = newHeading.trueHeading;
    [aCompView rotateMarkerView:heading];
    
    headingLabel.text = [self getStringFromHeading:heading];
}

-(NSString*)getStringFromHeading:(double)headingInit
{
    NSString* headingStr;
    
    if (headingInit > 337.5 || headingInit < 22.5)
    {
        headingStr = @"N";
    }
    else if (headingInit >= 22.5 && headingInit <= 67.5)
    {
        headingStr = @"NE";
    }
    else if (headingInit > 67.5 && headingInit <= 112.5)
    {
        headingStr = @"E";
    }
    else if (headingInit > 112.5 && headingInit <= 157.5)
    {
        headingStr = @"SE";
    }
    else if (headingInit > 157.5 && headingInit <= 202.5)
    {
        headingStr = @"S";
    }
    else if (headingInit > 202.5 && headingInit <= 247.5)
    {
        headingStr = @"SW";
    }
    else if (headingInit > 247.5 && headingInit <= 292.5)
    {
        headingStr = @"W";
    }
    else if (headingInit > 292.5 && headingInit <= 337.5)
    {
        headingStr = @"NW";
    }
    
    return headingStr;
}


#pragma mark - Setters
-(void)setDataFactory:(DataFactory*)aDataFactory
{
    dataFactory = aDataFactory;
}

-(void)setSpotDict:(NSMutableDictionary *)dictInit
{
    spotDict = dictInit;
}


-(void)didReceiveTap:(NSNotification*)notification
{
    NSLog(@"tapped the screen, call the next view up");
    
    if (!aPlotView.hidden)
    {
        if (currentView == 3)
        {
            currentView = 1;
        }
        else
        {
            currentView = currentView + 1;
        }
        
        [self chooseDataToDisplay];
    }

}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:YES];
    
    [dataFactory removeReportVCForID:spotID];
}
@end
