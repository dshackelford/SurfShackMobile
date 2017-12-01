//
//  TextDisplayCell.h
//  Checkers
//
//  Created by Dylan Shackelford on 7/11/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TextDisplayCell : UITableViewCell <UITextViewDelegate>

@property IBOutlet UITextView* cellTextView;

@end