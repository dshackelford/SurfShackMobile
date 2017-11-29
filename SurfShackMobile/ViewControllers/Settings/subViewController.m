//
//  subViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/30/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "subViewController.h"

@implementation subViewController

-(void)setTableData:(NSMutableArray*)dataInit
{
    tableData = dataInit;
}

-(void)setTitle:(NSString *)titleInit
{
    title = titleInit;
}

-(void)setParagraphs:(NSDictionary*)dictInit
{
    paragraphs = dictInit;
}

@end