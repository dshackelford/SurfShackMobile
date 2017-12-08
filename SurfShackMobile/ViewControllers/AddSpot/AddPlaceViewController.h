//
//  AddPlaceViewController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/27/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SpitcastData.h"
#import "AppUtilities.h"
#import "PlotView.h"
#import "CountyHandler.h"

#import "TextInputCell.h"
#import "PickerInputCell.h"
#import "arrowCell.h"

#import "NearByPacket.h"

#import "PreferenceFactory.h"
#import <CoreLocation/CoreLocation.h>

#import "SpotListViewController.h"
#import "DBManager.h"
#import "AppDelegate.h"

#import "DataCollector.h"

@interface AddPlaceViewController : UITableViewController <CLLocationManagerDelegate,UISearchBarDelegate, UISearchControllerDelegate,DataCollector>
{
    DBManager* db;
    
    CGSize screenSize;
    IBOutlet UILabel* titleLabel;
    UITableView* theTableView;
    
    NSArray* tableData;
    NSArray* favSpots; //IDS's
    NSArray* favSpotNames; //String Names
    
    int rowHeight;
    CGFloat sectionHeader;
    
    IBOutlet UIBarButtonItem* locationButton;
    
    UIActivityIndicatorView* indicator;
    
    CLLocationManager* locationManager;
    CLLocation* currentLocation;
    
    NSString* lat;
    NSString* lon;
    
    NSArray* tableDataIDs;
    
    NSArray *searchResults;
    NSString* searchString;
    
    UIAlertController* alertController;
    
    NSMutableDictionary* countyDict;
    NSMutableArray* countyArr;
    NSMutableArray* favCountyArr;
    BOOL nearByList;
    int downloaded;
}

@property UISearchController* searchController;

@property int selectedIndex;

-(void)didAddSpotsToDB:(NSNotification*)notification;

@end
