//
//  AppDelegate.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/11/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DBManager.h"
#import "PreferenceFactory.h"
#import "CountyHandler.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property () BOOL restrictRotation;

@end

