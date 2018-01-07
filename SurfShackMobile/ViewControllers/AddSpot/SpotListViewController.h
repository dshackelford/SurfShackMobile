//
//  SpotListViewController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/8/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "arrowCell.h"
#import "PreferenceFactory.h"
#import "AppDelegate.h"


@interface SpotListViewController : UITableViewController
{
    NSMutableArray* tableData;
    
    int sectionHeader;
    
    NSString* title;
    
    CGSize screenSize;
    
    NSDictionary* paragraphs;
    
    NSArray* favSpots;
    
    NSString* county;
}

-(void)setTitle:(NSString*)titleInit;
-(void)setTableData:(NSMutableArray*)tableDataInit;
-(void)setCounty:(NSString*)countyInit;

@end
