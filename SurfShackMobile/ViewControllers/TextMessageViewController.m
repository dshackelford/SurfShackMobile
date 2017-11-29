//
//  TextMessageViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/11/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "TextMessageViewController.h"

@implementation TextMessageViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    NSMutableArray* spotArray;
    NSLog(@"HomeDirectory: %@",NSHomeDirectory());
    
    Boolean success;
    db = [[DBManager alloc] init];
    success = [db openDatabase];
    int mrCount = [db getCountOfAllSpots];
    
    if(mrCount > 1 && success == YES)
    {
        spotArray = [db getSomeSpots:301];
        NSLog(@"%@",spotArray);
        NSMutableArray* arr = [db getDesignListOfColumns];
        NSLog(@"%@",arr);
        
    }
    else
    {
//        NSArray* allSpots = [PreferenceFactory getAllSpots];
//        success = [db openDatabase];
    }
    
    mrCount = [db getCountOfAllSpots];
    NSLog(@"%d",mrCount);
    
    
    [db closeDatabase];
}

@end
