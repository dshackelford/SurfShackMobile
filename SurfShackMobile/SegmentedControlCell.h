//
//  SegmentedControlCell.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/30/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SegmentedControlCell : UITableViewCell

@property IBOutlet UILabel* titleLabel;
@property IBOutlet UISegmentedControl* segControl;

@end