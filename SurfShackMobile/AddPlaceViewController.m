//
//  AddPlaceViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/27/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AddPlaceViewController.h"


@implementation AddPlaceViewController

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
    self.navigationController.navigationBar.barTintColor = [[PreferenceFactory getPreferences] objectForKey:kColorScheme];
    //sets the buttons to a color tint
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //sets the buttons in the top bar to a color
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(didAddSpotsToDB:) name:@"AddedSpotsToDB" object:nil];
    
    NSLog(@"HomeDirectory: %@",NSHomeDirectory());
    
    countyArr = [[NSMutableArray alloc] init];
    
    Boolean success;
    db = [[DBManager alloc] init];
    success = [db openDatabase];
    int mrCount = [db getCountOfAllSpots];
    [db closeDatabase];
    
    
    screenSize = [UIScreen mainScreen].bounds.size;
    
    self.title = @"Counties";
    
    nearByList = NO;
    
    rowHeight = 55;
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    
    locationButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAction target:self action:@selector(didPressCurrentLocationButton:)];
    
    self.navigationItem.rightBarButtonItem = locationButton;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColor:) name:@"changeColorPref" object:nil];
    
    if(mrCount > 1 && success == YES)
    {
        [db openDatabase];
        countyArr = [db getAllCounties];
        favSpots = [db getSpotFavorites];
        favSpotNames = [db getSpotNameFavorites];
        favCountyArr = [db getCountyFavorites];
        
        tableData = countyArr;
        NSLog(@"%@",countyArr);
        [db closeDatabase];
        
    }
    else
    {
        alertController = [UIAlertController alertControllerWithTitle:@"Finding Spots" message:@"please wait a second for this to happen" preferredStyle:UIAlertControllerStyleAlert];
        [self presentViewController:alertController animated:YES completion:nil];

        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0),
                                                  ^{
        SpitcastData* dataService = [PreferenceFactory getDataService];
        NSMutableArray* allSpotData = [dataService getAllSpotsAndCounties];

        [db openDatabase];
        
        for (CountyInfoPacket* spotData in allSpotData)
        {
            [db addSpotID:[spotData getSpotID] SpotName:[spotData getSpotName] andCounty:[spotData getCountyName] withLat:[spotData getLat] andLon:[spotData getLon]];
        }
        
        [db closeDatabase];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"AddedSpotsToDB" object:nil];
                                                      
        });
    }
    
    [super viewDidLoad];
}

-(void)changeColor:(NSNotification*)notification
{
    NSDictionary* dict = [PreferenceFactory getPreferences];
    
    self.navigationController.navigationBar.barTintColor = [dict objectForKey:kColorScheme];
}

-(void)didAddSpotsToDB:(NSNotification*)notification
{
    dispatch_async(dispatch_get_main_queue(), ^(){
        NSLog(@"ot some spots");
    [alertController dismissViewControllerAnimated:YES completion:nil];
    [db openDatabase];
    tableData = [db getAllCounties];
    [self.tableView reloadData];
    [db closeDatabase];
        
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    NSLog(@"Add Spot View will appear");
//    NSLog(@"%@",favSpots);
    downloaded = 0;
    [self restrictRotation:YES];
    [super viewWillAppear:NO];
    
    if([db openDatabase] && [[db getAllCounties] count] > 0)
    {
        tableData = [db getAllCounties];
        [self.tableView reloadData];
        favSpots = [db getSpotFavorites];
        favCountyArr = [db getCountyFavorites];
    }
    
    [db closeDatabase];
}

-(IBAction)didPressCurrentLocationButton:(id)sender
{
//    locationManager = [[CLLocationManager alloc] init];
//    locationManager.delegate = self;
//    locationManager.distanceFilter = kCLLocationAccuracyBest;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    
    [locationManager requestLocation];
    
    indicator = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(screenSize.width/2 - 15, screenSize.height/2 - 15, 30, 30)];
    [self.view addSubview:indicator];
    [indicator startAnimating];
}



-(void)locationManager:(CLLocationManager *)manager didFailWithError:(nonnull NSError *)error
{
    NSLog(@"ERROR with core location finding? %@",error);
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    downloaded++;
    currentLocation = [locations objectAtIndex:0];
    lat = [NSString stringWithFormat:@"%.6f",currentLocation.coordinate.latitude];
    lon = [NSString stringWithFormat:@"%.6f",currentLocation.coordinate.longitude];
    NSLog(@"lat:%.3f",currentLocation.coordinate.latitude);
    
    [locationManager stopUpdatingLocation];
    
    if (downloaded == 1)
    {
        [self performSelectorOnMainThread:@selector(addDataToTable) withObject:nil waitUntilDone:YES];
    }
}

-(void)addDataToTable
{
    id<DataHandler> dataService = [PreferenceFactory getDataService];
    
    NSArray* nearByData = [dataService getNearBySpots:lat andLon:lon];
    
    [indicator stopAnimating];
    
    NSMutableArray* nearBySpotNames = [[NSMutableArray alloc] init];
    
    for (id obj in nearByData)
    {
        [nearBySpotNames addObject:[obj getSpotName]];
    }
    
    tableData = nearBySpotNames;
    
    nearByList = YES;
    NSLog(@"push view");
    
    [self performSegueWithIdentifier:@"ShowSpotList" sender:self];
}

#pragma mark - UITableViewProtocols
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([searchResults count] > 0) //found a search?
    {
        return [searchResults count];
        
    }
    else
    {
        return [tableData count];
    }
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

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if([searchResults count] > 0)
    {
        arrowCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
                
        cell.textLabel.text = [searchResults objectAtIndex:indexPath.row];
        
        for (NSString* spotName in favSpotNames)
        {
            if([spotName isEqualToString:[searchResults objectAtIndex:indexPath.row]])
            {
//                cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                [cell setAccessoryType:UITableViewCellAccessoryCheckmark];
                break;
            }
        }
        return cell;
    }
    else
    {
        arrowCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
        [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];

        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
        
        for (NSString* county in favCountyArr)
        {
            if([county isEqualToString:[tableData objectAtIndex:indexPath.row]])
            {
                cell.textLabel.font = [UIFont boldSystemFontOfSize:17];
                break;
            }
        }
        return cell;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndex = (int)indexPath.row;

    if([searchResults count] > 0)
    {
        UITableViewCell* cell = [tableView cellForRowAtIndexPath:indexPath];
        
        [db openDatabase];
        
        if (cell.accessoryType == UITableViewCellAccessoryCheckmark)
        {
            //remove the spot from the list of favorites
            cell.accessoryType = UITableViewCellAccessoryNone;
            
            [db setSpot:[searchResults objectAtIndex:indexPath.row] toFav:NO];
        }
        else
        {
            //ass the spot to the list of favorites
            cell.accessoryType = UITableViewCellAccessoryCheckmark;
            
            [db setSpot:[searchResults objectAtIndex:indexPath.row] toFav:YES];
        }
        
        [db closeDatabase];
        
        [tableView deselectRowAtIndexPath:indexPath animated:YES];

    }
    else //normal county list display
    {
        [self performSegueWithIdentifier:@"ShowSpotList" sender:self];
    }
}


//use this for passing information to the new view controller
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    SpotListViewController *destViewController = segue.destinationViewController;
    
    if (nearByList == YES)
    {
        [destViewController setTableData:[[NSMutableArray alloc] initWithArray:tableData]];
        
        NSString* title = @"Near By";
        [destViewController setTitle:title];
        
        nearByList = NO;
    }
    else
    {
        if ([db openDatabase])
        {
            NSMutableArray* arrOfSpotsInCounty = [db getSpotNamesInCounty:[tableData objectAtIndex:self.selectedIndex]];
            [destViewController setTableData:arrOfSpotsInCounty];
        }
        [db closeDatabase];
        
        NSString* title = [tableData objectAtIndex:self.selectedIndex];
        NSLog(@"%@",title);
        [destViewController setTitle:title];
        [destViewController setCounty:[tableData objectAtIndex:self.selectedIndex]];
      
    }
}

-(void)reloadTheTable
{
    if ([db openDatabase])
    {
        favSpots = [db getSpotFavorites];
        favSpotNames = [db getSpotNameFavorites];
        favCountyArr = [db getCountyFavorites];
    }
    [db closeDatabase];
    [self.tableView reloadData];
}



#pragma mark - Search Bar Protocols

- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope
{
//    NSPredicate *resultPredicate = [NSPredicate predicateWithFormat:@"name contains[cd] %@", searchText];
//    NSLog(@"%@",searchText);
    
    [db openDatabase];
    searchResults = [db getSpotNamesFromSearchString:searchText];
    [db closeDatabase];
    
//    NSLog(@"%@",searchResults);
    
    
    [self reloadTheTable];
//    searchResults = [tableData filteredArrayUsingPredicate:resultPredicate];
//    NSLog(@"%@",searchResults);
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
    [self filterContentForSearchText:searchString
                               scope:[[self.searchDisplayController.searchBar scopeButtonTitles]
                                      objectAtIndex:[self.searchDisplayController.searchBar
                                                     selectedScopeButtonIndex]]];
    
    return YES;
}

-(BOOL)searchBarShouldEndEditing:(UISearchBar *)searchBar
{
    searchResults = nil;
    [self reloadTheTable];
    return YES;
}
@end
