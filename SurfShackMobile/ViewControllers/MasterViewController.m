//
//  MasterViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/28/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MasterViewController.h"

@implementation MasterViewController

-(void)restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

@end