//
//  MyTabBarController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/14/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyTabBarController.h"
#import "DBQueries.h"


@implementation MyTabBarController

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"tab bar controller loaded");
    
    int count = 0;
    fmdb = [FMDatabase databaseWithPath:[AppUtilities getPathToAppDatabase]];
    if([fmdb open])
    {
        FMResultSet* set = [fmdb executeQuery:[DBQueries countOfFavoriteSpots]];
        while([set next])
        {
            count = [set intForColumn:@"count(*)"];
            NSLog(@"favorite spots count = %i",count);
        }
    }
    [fmdb close];
    
    self.view.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];

    //choosing which screen to go to on load up
    if (count > 0)
    {
        self.selectedIndex = 0; //go to report view controller
    }
    else
    {
        [PreferenceFactory getPreferences]; //initialize the preferences
        
        self.selectedIndex = 1; //go to add a spot //still throw the
    }
}

@end
