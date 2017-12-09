//
//  LogViewController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/2/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppUtilities.h"
#import "PreferenceFactory.h"
#import "AppDelegate.h"
#import "arrowCell.h"
#import "TextInputCell.h"


@interface LogViewController : UITableViewController <UIPickerViewDelegate, UIPickerViewDataSource>
{
    CGSize screenSize;
    
    NSArray* tableData;
    NSArray* pickerData;
    
    int rowHeight;
    int sectionHeader;
}

@property int selectedRow;
@property int selectedSection;

@end