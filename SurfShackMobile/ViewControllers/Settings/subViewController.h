//
//  subViewController.h
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/30/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "arrowCell.h"
#import "PreferenceFactory.h"


@interface subViewController : UITableViewController
{
    NSMutableArray* tableData;
    
    int sectionHeader;
    
    NSString* title;
    
    CGSize screenSize;
    
    NSDictionary* paragraphs;
}


-(void)setTableData:(NSMutableArray*)dataInit;
-(void)setTitle:(NSString*)titleInit;
-(void)setParagraphs:(NSDictionary*)arrInit;
@end