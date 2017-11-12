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

@implementation ReportViewController

-(void)viewDidLoad
{
    db = [[DBManager alloc] init];
    
    [self restrictRotation:NO];
    
    screenSize = [UIScreen mainScreen].bounds.size;
    
    if (screenSize.width > screenSize.height) //maintain a constant screen size for consistency
    {
        //swap the values for a load in horizontal
        double x = screenSize.width;
        screenSize.width = screenSize.height;
        screenSize.height = x;
    }
    
    [db openDatabase];
    favSpots = [db getSpotFavorites];
    county = [db getCountyOfSpotID:[[favSpots objectAtIndex:self.index] intValue]];
    spotName = [db getSpotNameOfSpotID:[[favSpots objectAtIndex:self.index] intValue]];
    [db closeDatabase];
    
    self.view.backgroundColor = [UIColor clearColor];

    NSLog(@"current spot:%@",spotName);
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actOnSpotData:) name:[NSString stringWithFormat:@"%@",spotName] object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(actOnCountyData:) name:[NSString stringWithFormat:@"%@",county] object:nil];
    
    
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    [[UIDevice currentDevice] beginGeneratingDeviceOrientationNotifications];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didRotate:) name:@"UIDeviceOrientationDidChangeNotification" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didReceiveTap:) name:@"tap" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(refreshData:) name:@"refreshData" object:nil];
    
    
    //ADD SUBVIEWS (OFFSET Y BY 70 FOR THE TITLE BAR BEING PRESENT)
//    infoView = [[SubInfoView alloc] initWithFrame:CGRectMake(0, 70, screenSize.width, screenSize.height/4)];
//    [self.view addSubview:infoView];
    
    aCompView = [[CompassView alloc] initWithFrame:CGRectMake(0,100, screenSize.width, screenSize.height/3)];
    [self.view addSubview:aCompView];
    
    aPlotView = [[PlotView alloc] initWithFrame:CGRectMake(0,100 + aCompView.frame.size.height, screenSize.width, 200)];
    [self.view addSubview:aPlotView];
    

//    aPlotView.layer.borderWidth = 2;
//    aPlotView.layer.borderColor = [UIColor blackColor].CGColor;
    
    aCompView.hidden = YES;
//    infoView.hidden = YES;
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
    
    //LOCATION MANAGER FOR COMPASS
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    [locationManager startUpdatingHeading];
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestAlwaysAuthorization];
    
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColor:) name:@"changeColorPref" object:nil];
    
    spotDict = [OfflineData getOfflineDataForID:[[favSpots objectAtIndex:self.index] intValue]];
    [self chooseDataToDisplay];
}

-(void)changeColor:(NSNotification*)notification
{
    NSDictionary* dict = [PreferenceFactory getPreferences];
    
    self.navigationController.navigationBar.barTintColor = [dict objectForKey:kColorScheme];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self restrictRotation:NO];
    
    NSLog(@"view %d WILL appear",(int)self.index);
    
    //set the title bar in the pageview controller
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeTitle" object:[NSNumber numberWithInteger:self.index]];
    
    spotDict  = [dataFactory getASpotDictionary:spotName andCounty:county];
    
    if (spotDict != nil)
    {
        [self spotHasData];
    }
    else
    {
        //and wait for the notifications to come in
        [indicator startAnimating];
    }
    
    [super viewWillAppear:YES];
}


-(void)actOnSpotData:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^()
    {
        NSLog(@"got some spot data for %@",spotName);
        spotDict  = [dataFactory getASpotDictionary:spotName andCounty:county];
        if (spotDict != nil)
        {
            [self spotHasData];
        }
    });
}

-(void)actOnCountyData:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^()
    {
        NSLog(@"got some county data for %@",county);
        spotDict  = [dataFactory getASpotDictionary:spotName andCounty:county];
        if (spotDict != nil)
        {
            [self spotHasData];
        }
    });
}

-(void)refreshData:(NSNotification*)notification
{
    aCompView.hidden = YES;
    infoView.hidden = YES;
    
    headingLabel.hidden = YES;
    aPlotView.hidden = YES;
    
    indicator.hidden = NO;
    [indicator startAnimating];
    
    NSLog(@"attempt resfresh");
}

//if there is data, then current values can be derived thusly
-(void)spotHasData
{
    [indicator stopAnimating];
    indicator.hidden = YES;
    spotDict = [dataFactory setCurrentValuesForSpotDict:spotDict];
    [OfflineData saveSpotDict:spotDict withID:[[favSpots objectAtIndex:self.index] intValue]];
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

@end
