//
//  SubSettingsViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/30/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubSettingsViewController.h"

@implementation SubSettingsViewController

-(void)viewDidLoad
{
    screenSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    [super viewDidLoad];

    
    self.navigationItem.title = title;

    sectionHeader = 15;
    
    self.tableView.scrollEnabled = NO;
    
    //removes the lines around cells not being used!
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    self.tableView.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)setSegControlArrays:(NSMutableArray*)segArraysInit
{
    //assuming input parameter is an array of multiple arrays that hold strings.
    //also asusming that the count of input array matches the count of table data.
    segControlArrays = segArraysInit;
}


#pragma mark - Table Delegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return sectionHeader; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0) //speed
    {
        arrowCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
        
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        UISegmentedControl* segControlView = [[UISegmentedControl alloc] initWithItems:[segControlArrays objectAtIndex:indexPath.row]]; //add section here
                                              
        segControlView.frame = CGRectMake(screenSize.width/2, 0, 80, 40);
        segControlView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [cell.contentView insertSubview:segControlView aboveSubview:cell.textLabel];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [tableData objectAtIndex:indexPath.row]];
        
        segControlView.tag = indexPath.row;
        
        if([[PreferenceFactory getIndicatorStrForSpeed] isEqualToString:@"mph"])
        {
            segControlView.selectedSegmentIndex = 0;
        }
        else
        {
            segControlView.selectedSegmentIndex = 1;
        }
        
        [segControlView addTarget:self action:@selector(updateSwitchAtIndexPath:) forControlEvents:UIControlEventValueChanged];
        
        return cell;
    }
    else //heights
    {
        arrowCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
        
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
        UISegmentedControl* segControlView = [[UISegmentedControl alloc] initWithItems:[segControlArrays objectAtIndex:indexPath.row]];
        segControlView.frame = CGRectMake(screenSize.width/2, 0, 80, 40);
        segControlView.autoresizingMask = (UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight);
        [cell.contentView insertSubview:segControlView aboveSubview:cell.textLabel];
        
        cell.textLabel.text = [NSString stringWithFormat:@"%@", [tableData objectAtIndex:indexPath.row]];
        
        
        segControlView.tag = indexPath.row;
        if([[PreferenceFactory getIndicatorStrForHeight] isEqualToString:@"ft"])
        {
            segControlView.selectedSegmentIndex = 0;
        }
        else
        {
            segControlView.selectedSegmentIndex = 1;
        }
        
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
    NSLog(@"row: %d",(int)segControl.tag); //the row that the switch is in
    NSLog(@"value: %d",(int)segControl.selectedSegmentIndex); //the value of the segmented control
    
    //write the new indicator value to prefernce factory here
    if(segControl.tag == 0)
    {
        if(segControl.selectedSegmentIndex == 0)
        {
            [PreferenceFactory setIndicatorStrForSpeed:[NSString stringWithFormat:@"mph"]];
        }
        else
        {
            [PreferenceFactory setIndicatorStrForSpeed:[NSString stringWithFormat:@"kts"]];
        }
    }
    else if(segControl.tag == 1)
    {
        
        if(segControl.selectedSegmentIndex == 0)
        {
            [PreferenceFactory setIndicatorStrForHeight:[NSString stringWithFormat:@"ft"]];
        }
        else
        {
            [PreferenceFactory setIndicatorStrForHeight:[NSString stringWithFormat:@"m"]];
        }

    }
}

@end
