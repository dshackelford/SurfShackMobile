//
//  MyTabBarController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/14/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreferenceFactory.h"
#import "AppUtilities.h"
#import "DBManager.h"
#import <FMDB/FMDB.h>

@interface MyTabBarController : UITabBarController
{
    DBManager* db;
    FMDatabase* fmdb;
}
@end
