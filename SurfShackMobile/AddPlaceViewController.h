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
#import "DataHandler.h"
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

@interface AddPlaceViewController : UITableViewController <CLLocationManagerDelegate,UISearchBarDelegate,UISearchDisplayDelegate>
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
    
    UIAlertController* alertController;
    
    NSMutableDictionary* countyDict;
    NSMutableArray* countyArr;
    NSMutableArray* favCountyArr;
    BOOL nearByList;
    int downloaded;
}

@property int selectedIndex;

-(void)didAddSpotsToDB:(NSNotification*)notification;

@end
