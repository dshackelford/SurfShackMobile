//
//  SubSettingsViewController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/30/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import "subViewController.h"
#import "PickerInputCell.h"

@interface SubSettingsViewController : subViewController
{
    NSMutableArray* segControlArrays;
}

-(void)setSegControlArrays:(NSMutableArray*)segArraysInit;

@end