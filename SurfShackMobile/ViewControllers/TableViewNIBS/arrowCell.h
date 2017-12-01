//
//  arrowCell.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/25/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface arrowCell : UITableViewCell <UITextFieldDelegate>

@property (weak,nonatomic) IBOutlet UILabel* cellLabel;
@property (weak,nonatomic) IBOutlet UIButton* arrowButton;

-(UILabel*)getCellLabel;

@end