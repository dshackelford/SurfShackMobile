//
//  MyTabBarController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/14/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PreferenceFactory.h"
#import "DBManager.h"

@interface MyTabBarController : UITabBarController
{
    DBManager* db;
}
@end