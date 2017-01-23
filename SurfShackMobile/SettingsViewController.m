//
//  SettingsViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/11/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsViewController.h"


@implementation SettingsViewController

-(void)restrictRotation:(BOOL) restriction
{
    AppDelegate* appDelegate = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDelegate.restrictRotation = restriction;
}

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [self restrictRotation:YES];
    
    //sets the top bar to a color
    NSDictionary* dict = [PreferenceFactory getPreferences];
    
    self.navigationController.navigationBar.barTintColor = [dict objectForKey:kColorScheme];
    
    self.navigationController.navigationBar.barTintColor = [dict objectForKey:kColorScheme];
    //sets the buttons to a color tint
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //sets the buttons in the top bar to a color
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    screenSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    
    tableData = @[ @[@"Day Range",@"Units",@"Color Scheme"],@[@"Surf Data Provider",@"Data Represenatation"]];

    imageArr = @[ @[@"dayRange.png",@"units.png",@"colorScheme.png"],@[@"dataProvider.png",@"notifications.png"]];
 
    tableHeaderTitles = @[@"Aesthetics",@"Data"];
    rowHeight = 55;
    sectionHeader = 50;

    self.tableView.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];

    self.tableView.scrollEnabled = NO;
    
    //removes the lines around cells not being used!
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    aboutButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemBookmarks target:self action:@selector(showAboutVC:)];
    
    self.navigationItem.rightBarButtonItem = aboutButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColor:) name:@"changeColorPref" object:nil];
}

-(void)changeColor:(NSNotification*)notification
{
    NSDictionary* dict = [PreferenceFactory getPreferences];
    
    self.navigationController.navigationBar.barTintColor = [dict objectForKey:kColorScheme];
}

-(void)viewWillAppear:(BOOL)animated
{
    [self restrictRotation:YES];
}

#pragma mark - UITableViewProtocols
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0)
    {
        return 3;
    }
    else if(section == 1)
    {
        return 1; //Asthetics (color scheme)
                    //Data Service
                    //notifications
    }
    else //alert section
    {
        return 2;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 45; // you can have your own choice, of course
}



- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    static NSString *HeaderCellIdentifier = @"Header";
    
    UITableViewCell* cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HeaderCellIdentifier];

    cell.textLabel.text = [tableHeaderTitles objectAtIndex:section];
//    cell.textLabel
    return cell;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    arrowCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
        
    cell.textLabel.text = [[tableData objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator]; //the grey chevron
        
//    cell.imageView.image = [UIImage imageNamed:@"units.png"];
    NSLog(@"secion %ld",(long)indexPath.section);
    NSLog(@"row %ld",(long)indexPath.row);
    cell.imageView.image = [UIImage imageNamed:[[imageArr objectAtIndex:indexPath.section] objectAtIndex:indexPath.row]];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedRow = (int)indexPath.row;
    self.selectedSection = (int)indexPath.section;
    self.actualSelectedIndex  = [self getActualIndexSelected];
    NSLog(@"acutalSelction:%d",self.actualSelectedIndex);
    
//    NSLog(@"touch on row %d", self.selectedRow);
    
    //subsettings with Segmented Control
    if(self.actualSelectedIndex == 0)
    {
        //show day Segmented Control
        [self performSegueWithIdentifier:@"showDayRangePage" sender:self];
    }
    else if (self.actualSelectedIndex == 1)
    {
        [self performSegueWithIdentifier:@"showSubSetting" sender:self];
    }
    else if(self.actualSelectedIndex == 2)
    {
        //show color page with checkmarks
        [self performSegueWithIdentifier:@"showColorPage" sender:self];
    }
    else if(self.actualSelectedIndex == 3)
    {
        [self performSegueWithIdentifier:@"showDataProviders" sender:self];
    }
    
}

-(int)getActualIndexSelected
{
    int rowCount = 0;
    
    for (int i = 0; i < self.selectedSection; i++)
    {
        rowCount = rowCount + (int)[self.tableView numberOfRowsInSection:i];
    }
#warning this may prove to be a problem (int) 
    rowCount = rowCount + self.selectedRow;
    
    return  rowCount;
}

//use this for passing information to the new view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //segmented control settings
    if ([segue.identifier isEqualToString:@"showSubSetting"])
    {
        SubSettingsViewController *destViewController = segue.destinationViewController;
        
        [destViewController setTableData:[[NSMutableArray alloc] initWithArray:@[@"Height",@"Speed"]]];
        NSMutableArray* segArray = [[NSMutableArray alloc] initWithArray:@[@[@"MPH",@"Kts"],@[@"ft",@"m"]]];
            
        [destViewController setSegControlArrays:segArray];
            
        NSString* title = [[tableData objectAtIndex:self.selectedSection] objectAtIndex:self.selectedRow];
        NSLog(@"%@",title);
        [destViewController setTitle:title];
    }
    else if([segue.identifier isEqualToString:@"showColorPage"])
    {
            SubSettingColorViewController *destViewController = segue.destinationViewController;
//                NSMutableArray* data = [[NSMutableArray alloc] initWithArray:@[@"Sunset Red",@"Seagrass Green",@"Ocean Blue",@"Sand Tan",@"Dawnpatrol Grey",]];
//            [destViewController setTableData:data];
            [destViewController setTitle:@"Color Scheme"];
        
    }
    else if([segue.identifier isEqualToString:@"showDataProviders"])
    {
        SurfDataProviderViewController* destViewController = segue.destinationViewController;
    
        [destViewController setTitle:@"Data Providers"];
    }
    else if([segue.identifier isEqualToString:@"showAboutPage"])
    {
//        AboutPageViewController *destViewController = segue.destinationViewController;
//        [destViewController setTableData:[[NSMutableArray alloc] initWithArray:@[@"Height",@"Speed"]]];
//        NSString* title = [tableData objectAtIndex:self.selectedRow];
//        NSLog(@"%@",title);
//        [destViewController setTitle:title];
    }
    else if([segue.identifier isEqualToString:@"showDayRangePage"])
    {
//        DayRangeViewController *destViewController = segue.destinationViewController;
        //        [destViewController setTableData:[[NSMutableArray alloc] initWithArray:@[@"Height",@"Speed"]]];
        //        NSString* title = [tableData objectAtIndex:self.selectedRow];
        //        NSLog(@"%@",title);
        //        [destViewController setTitle:title];
    }
}

-(IBAction)showAboutVC:(id)sender
{
    NSLog(@"show the about page");
    [self performSegueWithIdentifier:@"showAboutPage" sender:self];
}



@end
