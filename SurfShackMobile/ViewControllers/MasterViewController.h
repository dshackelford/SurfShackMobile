//
//  MasterViewController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/28/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AppDelegate.h"
#import "PreferenceFactory.h"
#import "AppUtilities.h"

@interface MasterViewController : UIViewController
{
//    UILabel* titleLabel;
    CGSize screenSize;
}

-(void)restrictRotation:(BOOL) restriction;

@end