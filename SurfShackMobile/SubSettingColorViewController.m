//
//  SubSettingColorViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/30/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SubSettingColorViewController.h"

@implementation SubSettingColorViewController

-(void)viewDidLoad
{
    //removes the lines around cells not being used!
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [super viewDidLoad];
    
        self.tableView.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    
    colorPref = [PreferenceFactory getColorPreference];
    
    tableData = [NSMutableArray arrayWithArray:@[@"Red",@"Green",@"Blue",@"Tan",@"Grey"]];
    
    colorDict = [NSDictionary dictionaryWithObjects:@[@"Sunset Red",@"Seagrass Green",@"Ocean Blue",@"Sand Tan",@"Dawnpatrol Grey"] forKeys:@[@"Red",@"Green",@"Blue",@"Tan",@"Grey"]];
    
    self.navigationItem.title = title;
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
    arrowCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
        
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    NSLog(@"current %@, Pref: %@",[colorDict objectForKey:[tableData objectAtIndex:indexPath.row]],colorPref);
    
    if ([[tableData objectAtIndex:indexPath.row] isEqualToString:colorPref])
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
    }
    else
    {
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    

    cell.textLabel.text = [NSString stringWithFormat:@"%@", [colorDict objectForKey:[tableData objectAtIndex:indexPath.row]]];
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int selectedRow = indexPath.row;
    
    [PreferenceFactory setColorPreference:[tableData objectAtIndex:indexPath.row]];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"changeColorPref" object:nil];
    
    colorPref = [tableData objectAtIndex:indexPath.row];
    
    [tableView reloadData];
    
    NSLog(@"touch on row %d", selectedRow);
    
}



@end