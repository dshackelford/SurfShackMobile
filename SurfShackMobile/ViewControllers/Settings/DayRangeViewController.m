//
//  DayRangeViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/31/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "DayRangeViewController.h"


@implementation DayRangeViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
//    NSLog(@"view loaded");
    screenSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    
    self.tableView.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    
    NSLog(@"About loaded");
    self.navigationItem.title = @"Day Ranges";
    
    tableData =[[NSMutableArray alloc] initWithArray: @[@"Short Range (Days)",@"Long Range (Days)"]];
    
    
    //removes the lines around cells not being used!
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.scrollEnabled = NO;
}


#pragma mark - Table Delegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 45;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderCellIdentifier = @"Header";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:HeaderCellIdentifier];
        cell.textLabel.text = [tableData objectAtIndex:section];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:20];
    }
    
    
    cell.backgroundColor = [UIColor lightGrayColor];
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.section == 0)
    {

        arrowCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
        
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        UISegmentedControl* segControlView = [[UISegmentedControl alloc] initWithItems:@[@"1",@"2",@"3",@"4"]];

        segControlView.frame = cell.contentView.frame;
        
        segControlView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        [cell.contentView insertSubview:segControlView aboveSubview:cell.textLabel];
        
        segControlView.tag = indexPath.section;
        
        segControlView.selectedSegmentIndex = [PreferenceFactory getShortRange] - 1;
        
        [segControlView addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    else
    {
        arrowCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
        
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        UISegmentedControl* segControlView = [[UISegmentedControl alloc] initWithItems:@[@"1",@"2",@"3",@"4",@"5",@"6",@"7"]];
        
        segControlView.frame = cell.contentView.frame;
        
        segControlView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        
        [cell.contentView insertSubview:segControlView aboveSubview:cell.textLabel];
        
        segControlView.tag = indexPath.section;
        
        segControlView.selectedSegmentIndex = [PreferenceFactory getLongRange] -1;
        
        [segControlView addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int selectedRow = (int)indexPath.row;
    
    NSLog(@"touch on row %d", selectedRow);
    
}

- (void)updateSwitchAtIndexPath:(UISegmentedControl*)segControl
{
    NSLog(@"%d",(int)segControl.tag);
    NSLog(@"value: %d",(int)segControl.selectedSegmentIndex);
    
    //write the new indicator value to prefernce factory here
    if(segControl.tag == 0)
    {
        [PreferenceFactory setShortRange:(int)(segControl.selectedSegmentIndex+1)];
    }
    else if(segControl.tag == 1)
    {
        [PreferenceFactory setLongRange:(int)(segControl.selectedSegmentIndex + 1)];
    }
    
}

@end
