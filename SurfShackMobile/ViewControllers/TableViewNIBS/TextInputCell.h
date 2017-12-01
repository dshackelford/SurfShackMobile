//
//  TextInputCell.h
//  Checkers
//
//  Created by Dylan Shackelford on 7/9/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextInputCell : UITableViewCell <UITextFieldDelegate>

@property (weak,nonatomic) IBOutlet UILabel* cellLabel;
@property (weak,nonatomic) IBOutlet UITextField* cellTextField;

-(UILabel*)getCellLabel;

@end