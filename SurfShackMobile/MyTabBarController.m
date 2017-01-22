//
//  MyTabBarController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/14/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MyTabBarController.h"

@implementation MyTabBarController

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"tab bar controller loaded");
    
    db = [[DBManager alloc] init];
    [db openDatabase];
    self.view.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    
    //choosing which screen to go to on load up
    if ([[db newGetSpotFavorites] count] > 0)
    {
        self.selectedIndex = 0; //go to report view controller
    }
    else
    {
        [PreferenceFactory getPreferences]; //initialize the preferences
        
        self.selectedIndex = 2; //go to add a spot //still throw the
    }
    
    [db closeDatabase];
    
    
}

@end
