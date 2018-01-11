//
//  AboutPageViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/30/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AboutPageViewController.h"


@implementation AboutPageViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:UITableViewStyleGrouped];
    
    
    return self;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    NSLog(@"About loaded");
    
        self.tableView.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    
    self.navigationItem.title = @"About";
    
    paragraphEntries = @[@"SurfShack aims to provide a surf report that tailers the information to how they want it. By allowing users to change data ranges, choose surf data providers, and select future data sets, we beleive SurfShack can help any surfer choose the right time and place to go out.",
                @"By recording the quality of a session, you can enable SurfShack to notify you when the same forecasted surf conditions are matched, thereby increasing the probability of a firing surf session.",
                         @"Here at SurfShack, we feel the best surf sessions are those that you share with freind. This is why we decided to implement 'Share the Stoke' feature: a text messaging service that easily lets you tell your friends when a spot is firing and to meet you there after class!",
                @"The active compass in the Report View tracks your phone's heading and adjusts the swell/wind direction relative to your own. We feel this can be a neat feature for exploring new surf spots at real time, especially coupled with the selective future data set feature.",
                @"DshackTech first began as a YouTube technology review channel and expaned into both freelance promotional video work around San Diego and iOS App development in the summer of 2013. The first public iOS app was Mutable. DshackTech has several apps in the pipe line, so be on the look out for 'Cross Hairs', 'Habi-Path', and' Egalitarian Checkers'"];
    
    tableData =[[NSMutableArray alloc] initWithArray: @[@"Why SurfShack",@"Logging Surf Sessions",@"Text Messaging",@"The Compass",@"About DshackTech"]];
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
        cell.textLabel.textColor = [UIColor whiteColor];
    }
    

    cell.backgroundColor = [UIColor blackColor];
    return cell;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    TextDisplayCell *cell = [[[NSBundle mainBundle] loadNibNamed:@"TextDisplayCell" owner:self options:nil] lastObject];
    
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    cell.cellTextView.text = [NSString stringWithFormat:@"%@", [paragraphEntries objectAtIndex:indexPath.section]];

    cell.cellTextView.scrollEnabled  = NO;
    cell.cellTextView.textAlignment = NSTextAlignmentLeft;
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    int selectedRow = (int)indexPath.row;
    
    NSLog(@"touch on row %d", selectedRow);
    
}

@end
