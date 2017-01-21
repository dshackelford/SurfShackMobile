//
//  ReportPageViewController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/4/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ReportViewController.h"
#import "AppUtilities.h"
#import "PreferenceFactory.h"
#import "DataHandler.h"
#import "CoreLocation/CoreLocation.h"
#import "arrowCell.h"
#import "DBManager.h"
#import "DateHandler.h"

#import "DataFactory.h"

@interface ReportPageViewController : UIViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate, UITableViewDelegate, UITableViewDataSource>
{
    DBManager* db;
    DataFactory* dataFactory;
    
    UIAlertController* alertController;
    
    IBOutlet UIBarButtonItem* listOfSpotsButton;
    IBOutlet UIBarButtonItem* editButton;
    IBOutlet UIBarButtonItem* refreshButton;
    
    NSMutableArray* tableData;
    UITableView* theTableView;
    
    UIPageControl *pageControl;
    
    UIVisualEffectView *blurEffectView;
    
    CGSize screenSize;
    
    BOOL shouldReloadPageController;
}

@property NSArray* favoriteSpotsArr;
@property NSArray* favoriteCounties;
@property UIPageViewController* pageController;

@end