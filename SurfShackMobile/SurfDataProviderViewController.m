//
//  SurfDataProviderViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 9/8/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SurfDataProviderViewController.h"

@implementation SurfDataProviderViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    return self;
}

-(void)viewDidLoad 
{
    [super viewDidLoad];
    
//    NSLog(@"About loaded");
    
    self.tableView.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    
    self.navigationItem.title = @"About";
    
    tableData = [[NSMutableArray alloc] initWithArray: @[@"Spitcast.com",@"OpenWeatherAPI.com",@"NOAA"]];
    
    paragraphEntries = @[@"Spitcast is the surf forecasting website I've been using for years to know where and when to go for the best surf near me. Jack Muhlis was gracious enough to have an open API restful downloads of his surf prediction algorithm for spots from southern san diego to san francisco. His website is awesome, go check it out!",
                         @"OpenWeather.com is a super cool website that provides current and forecasted weather data for cities all over the world, some free and some paid. They are a super cool website that is so easy to use, I highly recommend you check them out if you looking for weather data in any project you are working on!",
                         @"NOAA has a plethora of data on their websites. I used them to find the current water temperature along califonia's coast. If you don't know about them, I would definitely check out their swell/buoy reports, there is so much information from NOAA, I barely scratched the surface. "
                         ];
}


#pragma mark - Table Delegate Methods
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return [tableData count];
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 150;
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
    TextDisplayCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"TextDisplayCell" owner:self options:nil] lastObject];
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    cell.cellTextView.text = [NSString stringWithFormat:@"%@", [paragraphEntries objectAtIndex:indexPath.section]];
    
    cell.cellTextView.scrollEnabled  = NO;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int selectedRow = (int)indexPath.row;
    
    NSLog(@"touch on row %d", selectedRow);
    
}

@end
