//
//  PickerInputCell.h
//  Checkers
//
//  Created by Dylan Shackelford on 7/10/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PickerInputCell : UITableViewCell <UIPickerViewDelegate>

@property IBOutlet UILabel* titleLabel;
@property IBOutlet UIPickerView* picker;

@end