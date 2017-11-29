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
    
    paragraphEntries = @[@"SurfShack aims to provide a users a surf report app that tailers the information to how they want it. I am tired of seeing surf apps show data in ways they feel is best. Therefore, SurfShack allows users to change what data ranges to see, color schemes, surf data service packages.",
                @"Logging surf sessinos is critical aspect to the usefulness of SurfShack. By recording the quality of a surf session, it will allow SurfShack to notify you when the same forecasted surf conditions are matched, increasing the probabliliy of a firing surf session.",
                @"Here at surfShack, we feel the best surf sessions are those that you share with freinds, which is why we decided to implement 'share the Stoke' a text messaging service that easily lets you tell your friends when a spot is firing and to meet you there after class!",
                @"Alot of of the inforatmion from the Bouys just off the shore of your favorite surf spots pass information in the form of direction. Rather then just tell you the direction, the active compass in the Report View tracks your phone's magnetic heading and adjusts the information direction such that your relative positions adds more value to the predicition.",
                @"DshackTech first began as a YouTube technology review channel and expaned into both freelance promotional video work around San Diego and iOS App devolopment in the summer of 2013. The first public iOS ap was Mutable, a simple snake game that requires dexterity to manuever through the mutable environemtn to get the golden gem. DshackTech has several apps in the pipe line, so be on the look out for 'Cross Hairs', 'Habi-Path', and' Egalitarian Checkers'"];
    
    tableData =[[NSMutableArray alloc] initWithArray: @[@"Why SurfShack",@"Logging Surf Sessions",@"Text Messaging",@"The Compass",@"About DShackTech"]];
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
