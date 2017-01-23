 //
//  SettingsViewController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/11/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import "MasterViewController.h"
#import "SpitcastData.h"
#import "PlotView.h"
#import "DataHandler.h"

#import "arrowCell.h"

#import "AddPlaceViewController.h"
#import "SubSettingsViewController.h"
#import "AboutPageViewController.h"
#import "SubSettingColorViewController.h"
#import "SecondaryLabelCell.h"
#import "DayRangeViewController.h"
#import "SurfDataProviderViewController.h"

@interface SettingsViewController : UITableViewController
{
    UITableView* theTableView;
    
    NSArray* tableData;
    NSArray* imageArr;
    NSArray* tableHeaderTitles;
    
    int rowHeight;
    CGFloat sectionHeader;
    
    UILabel* titleLabel;
    CGSize screenSize;
    
    IBOutlet UIBarButtonItem *aboutButton;
}

@property int selectedRow;
@property int selectedSection;
@property int actualSelectedIndex;

-(IBAction)showAboutVC:(id)sender;

@end
