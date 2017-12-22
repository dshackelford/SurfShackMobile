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
#import "CoreLocation/CoreLocation.h"
#import "arrowCell.h"
#import "DBManager.h"
#import "DateHandler.h"
#import "ActivityResponder.h"

#import "DataFactory.h"

@interface ReportPageViewController : UIViewController <UIPageViewControllerDataSource,UIPageViewControllerDelegate, UITableViewDelegate, UITableViewDataSource,ActivityResponder>
{
    DBManager* db;
    DataFactory* dataFactory;
    
    UIAlertController* alertController;
    
    IBOutlet UIBarButtonItem* listOfSpotsButton;
    IBOutlet UIBarButtonItem* editButton;
    IBOutlet UIBarButtonItem* refreshButton;
    
    NSMutableArray* tableData;
    UITableView* theTableView;
    
    IBOutlet UIPageControl *pageControl;
    
    UIVisualEffectView *blurEffectView;
    
    CGSize screenSize;
    
    BOOL shouldReloadPageController;
    
    UIPanGestureRecognizer* swipeDown;
    UISwipeGestureRecognizer* swipeRight;
    UISwipeGestureRecognizer* swipeLeft;
    UITapGestureRecognizer* singleTap;
    UILongPressGestureRecognizer* longPress;
    
    CGPoint startSwipePoint;
}

@property UIActivityIndicatorView* activityView;
@property IBOutlet UIBarButtonItem* activityIndicatorButton;

@property NSArray* favoriteSpotsArr;
@property NSArray* favoriteCounties;
@property UIPageViewController* pageController;

-(IBAction)longPressBegan:(UILongPressGestureRecognizer *)recognizer;

@end
