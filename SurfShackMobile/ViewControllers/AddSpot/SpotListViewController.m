//
//  SpotListViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/8/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SpotListViewController.h"

@implementation SpotListViewController

-(void)restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

-(void)viewDidLoad
{
    
    db = [[DBManager alloc] init];
    [db openDatabase];
        favSpots = [db getSpotNameFavorites];
    [db closeDatabase];
    
    screenSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    [super viewDidLoad];
    
    
    self.navigationItem.title = title;
    
    sectionHeader = 15;
    
    //removes the lines around cells not being used!
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"counties table ");
    [self restrictRotation:YES];
    [super viewWillAppear:YES];
    [self.tableView reloadData];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Prepare For Segue Methods
-(void)setTableData:(NSMutableArray*)tableDataInit
{
    tableData = tableDataInit;
}
-(void)setTitle:(NSString *)titleInit
{
    title = titleInit;
}
-(void)setCounty:(NSString *)countyInit
{
    county = countyInit;
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
    return 0; // you can have your own choice, of course
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    arrowCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
//    determining where to put the check marks on the spots that are already noted as favorites
    for (NSString* favStr in favSpots)
    {
        if ([favStr isEqual:[tableData objectAtIndex:indexPath.row]])
        {
            [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
            break;
        }
    }

    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
    
    [db openDatabase];
    
    if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
    {
        //remove the spot from the list of favorites
        cell.accessoryType = UITableViewCellAccessoryNone;

        [db setSpot:[tableData objectAtIndex:indexPath.row] toFav:NO];
    }
    else
    {
        //ass the spot to the list of favorites
        cell.accessoryType = UITableViewCellAccessoryCheckmark;

        [db setSpot:[tableData objectAtIndex:indexPath.row] toFav:YES];
    }
    
    [db closeDatabase];
    
    [self reloadTheTable];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changedSpotFavorites" object:self];
}

//need to reload the data immediately so that the check marks will appear when the user scrolls away from checkmarked spot
-(void)reloadTheTable
{
    if ([db openDatabase])
    {
        tableData = [db getSpotNamesInCounty:county];
        favSpots = [db getSpotNameFavorites];
    }
    [db closeDatabase];
    [self.tableView reloadData];
}

- (void)updateSwitchAtIndexPath:(UISegmentedControl*)segControl
{
    NSLog(@"%d",(int)segControl.tag);
    NSLog(@"valu: %d",(int)segControl.selectedSegmentIndex);
    
    //write the new indicator value to prefernce factory here
}


@end
