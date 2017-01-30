//
//  ReportPageViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/4/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportPageViewController.h"

@implementation ReportPageViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTitle:) name:@"changeTitle" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedSpotFavorites:) name:@"changedSpotFavorites" object:nil];
    
    NSLog(@"page view controler loaded");
    
    dataFactory = [[DataFactory alloc] init];
    
    db = [[DBManager alloc] init];
    if ([db openDatabase])
    {
        _favoriteSpotsArr = [db getSpotFavorites]; //array of NSNumbers integers
        _favoriteCounties = [db getCountyFavorites]; //array of strings
    }
    [db closeDatabase];
    
    screenSize = [UIScreen mainScreen].bounds.size;
    
    pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor clearColor];

    
    NSDictionary* prefs = [PreferenceFactory getPreferences];
    UIColor* color = [prefs objectForKey:kColorScheme];
    
    //CHOOSE COLORS FROM THE COLOR SCHEME IN PREFERENCE, IT SHOULD BE A DICTIONARY FOR EACH COLOR SCHEME THAT HAS PLOT VIEW COLORS AND BAR COLORS.
    self.navigationController.navigationBar.barTintColor = color;
    
    self.tabBarController.view.tintColor = [UIColor colorWithRed:22/255.f green:119/255.f blue:205/255.f alpha:1];
    
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    //sets the buttons to a color tint
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    //    self.view.backgroundColor = [UIColor colorWithRed:22/255.f green:119/255.f blue:205/255.f alpha:1];
    
    if ([_favoriteSpotsArr count] > 0)
    {
        //NAVIGATION BAR BUTTONS
        listOfSpotsButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemOrganize target:self action:@selector(didPressListOfSpotsButton:)];
        self.navigationItem.rightBarButtonItem = listOfSpotsButton;
        
        shouldReloadPageController = NO;
        // Create page view controller
        self.pageController = [self.storyboard instantiateViewControllerWithIdentifier:@"PageViewController"];
        self.pageController.dataSource = self;
        
        [self addPageViewController];
    }
    else
    {
        //I think the app should just push you to the add a spot page if first time opening it up, but imma leave it here just in case user is a savage
        alertController = [UIAlertController alertControllerWithTitle:@"NO SPOTS TO LOOK UP!" message:@"Please add spots in the ADD Spot Page." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
    [self establishGestures];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:YES];
    
    //check to see there are favorite spots selected by the user
    if ([db openDatabase])
    {
        _favoriteSpotsArr = [db getSpotFavorites];
        _favoriteCounties = [db getCountyFavorites];
    }
    [db closeDatabase];
    
    NSLog(@"Report Page Appeared");
    
    //if there are favorites, download some data
    if ([_favoriteSpotsArr count] > 0)
    {
        NSLog(@"%@",_favoriteSpotsArr);
        [dataFactory getDataForSpots:_favoriteSpotsArr andCounties:_favoriteCounties];
    }
    else //tell the user to select some favorite spots
    {
        self.title = @"ReportView";
        alertController = [UIAlertController alertControllerWithTitle:@"NO SPOTS TO LOOK UP!" message:@"Please add spots in the ADD Spot Page." preferredStyle:UIAlertControllerStyleAlert];
        
        UIAlertAction* defaultAction = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:^(UIAlertAction * action) {
        }];
        
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    
//    int currentTimeIndex = [DateHandler getIndexFromCurrentTime];
//    
//    if (currentTimeIndex > 7 && currentTimeIndex < 19)
//    {
//        self.view.backgroundColor = [UIColor blueColor];
//    }
//    else if(currentTimeIndex > 19 && currentTimeIndex < 22)
//    {
//        self.view.backgroundColor = [UIColor darkGrayColor];
//    }
//    else if(currentTimeIndex >=22 && currentTimeIndex < 24)
//    {
//        self.view.backgroundColor = [UIColor darkGrayColor];
//    }
}

-(void)changeTitle:(NSNotification*)notification
{
    [db openDatabase];
    _favoriteSpotsArr = [db getSpotFavorites];
    if ([[db getSpotFavorites] count] > 0)
    {
        self.title = [[db getSpotNameFavorites] objectAtIndex:[notification.object integerValue]];
    }
    [db closeDatabase];
    
}

//SHOW THE TABLE OF FAVORITE SPOTS IN VIEW
-(IBAction)didPressListOfSpotsButton:(id)sender
{
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//
//    if(orientation == UIInterfaceOrientationLandscapeLeft || orientation == UIInterfaceOrientationLandscapeRight)
//    {
//        theTableView.frame = CGRectMake(0, 60, screenSize.height, screenSize.width - 100);
//    }
//    else
//    {
//        theTableView.frame = CGRectMake(0, 60, screenSize.width, screenSize.height - 100);
//    }
    
//    theTableView.frame = self.view.bounds;
    
    NSLog(@"Wants list table");
    if (theTableView != nil && theTableView.hidden == NO)
    {
        theTableView.hidden = YES;
        blurEffectView.hidden = YES;
    }
    else if(theTableView == nil)
    {
        [self addFavoritesTable];
    }
    else
    {
        theTableView.hidden = NO;
        blurEffectView.hidden = NO;
    }
}

-(IBAction)didPressEditButton:(id)sender
{
    NSLog(@"edit table of favorite spots");
}

-(IBAction)didPressRefreshButton:(id)sender
{

//    NSLog(@"did press refresh button");
//    // Create a new view controller and pass suitable data.
//    ReportViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
//    
//    pageContentViewController.index = pageControl.currentPage;
//    [pageContentViewController refreshData];
//    
////    [pageContentViewController refreshData];
//    int spotID = [[_favoriteSpotsArr objectAtIndex:pageControl.currentPage] intValue];
//    [dataFactory removeSpotDictionary:spotID];
//    //also add one for the county?
//    [dataFactory getDataForSpots:_favoriteSpotsArr andCounties:_favoriteCounties];
}

-(void)changedSpotFavorites:(NSNotification*)notification
{
    [db openDatabase];
    _favoriteSpotsArr = [db getSpotFavorites];
    [theTableView reloadData];
    [db closeDatabase];
    
    NSLog(@"changed spot favorites %@",_favoriteSpotsArr);
    
    if([_favoriteSpotsArr count] > 0)
    {
        [self addPageViewController];
    }
    if ([_favoriteSpotsArr count] == 0)
    {
        [self.pageController removeFromParentViewController];
        [self.pageController.view removeFromSuperview];
        [self.pageController willMoveToParentViewController:nil];
    }
}


#pragma mark - Page View Controller Delegate Methods
-(void)addPageViewController
{
    ReportViewController *startingViewController = [self viewControllerAtIndex:0];
    NSArray *viewControllers = @[startingViewController];
    [self.pageController setViewControllers:viewControllers direction:UIPageViewControllerNavigationDirectionForward animated:NO completion:nil];
    
    // Change the size of page view controller
    self.pageController.view.frame = CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height - 40);
    
    [self addChildViewController:_pageController];
    [self.view addSubview:_pageController.view];
    [self.pageController didMoveToParentViewController:self];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerBeforeViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ReportViewController*) viewController).index;


    if ((index == 0) || (index == NSNotFound))
    {
        return [self viewControllerAtIndex:[_favoriteSpotsArr count]];
    }
    
    index--;
    
    return [self viewControllerAtIndex:index];
}

- (UIViewController *)pageViewController:(UIPageViewController *)pageViewController viewControllerAfterViewController:(UIViewController *)viewController
{
    NSUInteger index = ((ReportViewController*) viewController).index;
    
    if (index == NSNotFound) {
        return nil;
    }
    
    index++;
    if (index == [self.favoriteSpotsArr count]) {
        return [self viewControllerAtIndex:0];
    }
    
    return [self viewControllerAtIndex:index];
}


- (ReportViewController *)viewControllerAtIndex:(NSUInteger)index
{
    if (([self.favoriteSpotsArr count] == 0) || (index >= [self.favoriteSpotsArr count])) {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ReportViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
    
    pageContentViewController.index = index;
    
    if([db openDatabase])
    {
        NSString* aSpotName = [db getSpotNameOfSpotID:[[_favoriteSpotsArr objectAtIndex:index] intValue]];
        NSString* aCounty = [db getCountyOfSpotID:[[_favoriteSpotsArr objectAtIndex:index] intValue]];
        [pageContentViewController setSpotDict:[dataFactory getASpotDictionary:aSpotName andCounty:aCounty]];
    }
    [pageContentViewController setDataFactory:dataFactory];
    [db closeDatabase]; //jsut added
    
    return pageContentViewController;
}


- (NSInteger)presentationCountForPageViewController:(UIPageViewController *)pageViewController
{
    return [self.favoriteSpotsArr count];
}

- (NSInteger)presentationIndexForPageViewController:(UIPageViewController *)pageViewController
{
    return 0;
}

#pragma mark - List of Spots Table

-(void)addFavoritesTable
{
    //show list of spaces
    [db openDatabase];
    tableData = [[NSMutableArray alloc] initWithArray:[db getSpotNameFavorites]];
    [db closeDatabase];
    
    int rowHeight = 40;
    
    unsigned long tableHeight = rowHeight*[_favoriteSpotsArr count];
    
    
//    UIInterfaceOrientation orientation = [UIApplication sharedApplication].statusBarOrientation;
//    

    theTableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 60, screenSize.height, tableHeight) style:UITableViewStylePlain];
    
    [theTableView setRowHeight:rowHeight];
    
    [theTableView setDataSource:self];
    [theTableView setDelegate:self];
    
    theTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    if (tableHeight > screenSize.height)
    {
        [theTableView setScrollEnabled:YES];
    }
    else
    {
        [theTableView setScrollEnabled:NO];
    }
    
    [self.view insertSubview:theTableView aboveSubview:pageControl];
    
    //ADDING GAUSSIAN BLUR UNDER TABLE
    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleExtraLight];
    blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    blurEffectView.frame = self.view.bounds;
    blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view insertSubview:blurEffectView belowSubview:theTableView];
}


#pragma mark - UITableViewProtocols
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [tableData count];
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    UIView *headerView = [[UIView alloc] init];
    headerView.backgroundColor = [UIColor clearColor];
    return headerView;
}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    arrowCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator]; //the grey chevron
    
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    pageControl.currentPage = indexPath.row;
    theTableView.hidden = YES;
    
    //detect landscape here
//    theTableView.hidden = YES;
}


// Override to support conditional editing of the table view.
// This only needs to be implemented if you are going to be returning NO
// for some items. By default, all items are editable.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return YES if you want the specified item to be editable.
    return YES;
}

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableDictionary* aDict = [NSMutableDictionary dictionaryWithContentsOfFile:[AppUtilities getPathToFavoriteSpots]];
        
        [aDict removeObjectForKey:[tableData objectAtIndex:indexPath.row]];
        
        [aDict writeToFile:[AppUtilities getPathToFavoriteSpots] atomically:YES];
        
        [tableData removeObjectAtIndex:indexPath.row];
        
        [tableView reloadData];
    }
}

- (UITableViewCellEditingStyle)tableView:(UITableView *)aTableView editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Detemine if it's in editing mode
    if (theTableView.editing)
    {
        return UITableViewCellEditingStyleDelete;
    }
    
    return UITableViewCellEditingStyleDelete;
}

//excluding a row from relocation
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    //    if (indexPath.row == 0) // Don't move the first row
    //        return NO;
    
    return YES;
}


- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)sourceIndexPath toIndexPath:(NSIndexPath *)destinationIndexPath
{
    [tableData exchangeObjectAtIndex:sourceIndexPath.row withObjectAtIndex:destinationIndexPath.row];
    
    [theTableView reloadData];
    
    //need a better way of keeping an index of the favorites spots, dictionaries jumble them up
}

#pragma mark - Gestures
-(void)didSwipeDown:(UIPanGestureRecognizer *)aSwipeDown
{
    if (aSwipeDown.state == UIGestureRecognizerStateBegan)
    {
        startSwipePoint = [aSwipeDown locationInView:self.view];
        NSLog(@"swipe starts");
    }
    else if(aSwipeDown.state == UIGestureRecognizerStateChanged)
    {
        NSLog(@"swiping");
        CGPoint currentPoint = [aSwipeDown locationInView:self.view];
        int y = -startSwipePoint.y + currentPoint.y;
//        NSLog(@"%d",y);
        if(y>0 && y <75)
        {
            self.view.frame = CGRectMake(0, y, screenSize.width, screenSize.height);
        }
        else if (y > 75)
        {
                
                [dataFactory removeData];
                
                [dataFactory getDataForSpots:_favoriteSpotsArr andCounties:_favoriteCounties];
                
                NSLog(@"Swiped Down to refresh!");
                
                //tells the report views to remove their subviews and to start the indicator
                [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshData" object:nil];
                
                [UIView animateWithDuration:.5 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                    self.view.frame  = CGRectMake(0, 0, screenSize.width,screenSize.height);
                } completion:^(BOOL finished) {
                    
                }];
        }
    }
    else if(aSwipeDown.state == UIGestureRecognizerStateEnded)
    {
        
                //move the screen back up a little bit faster
            [UIView animateWithDuration:.25 delay:0.0 options:UIViewAnimationOptionCurveEaseIn animations:^{
                self.view.frame  = CGRectMake(0, 0, screenSize.width,screenSize.height);
            } completion:^(BOOL finished) {
                
            }];
        
    }
    
}



- (BOOL)gestureRecognizerShouldBegin:(UIGestureRecognizer *)gestureRecognizer
{
    NSLog(@"started swiping");
    return YES;
}


-(void)establishGestures
{
    singleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSingleTap:)];
    singleTap.numberOfTapsRequired = 1;

    swipeRight = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:nil];
    swipeRight.direction = UISwipeGestureRecognizerDirectionRight;
    
    swipeLeft = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:nil];
    swipeLeft.direction = UISwipeGestureRecognizerDirectionLeft;
    
    swipeDown = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(didSwipeDown:)];
    [swipeDown requireGestureRecognizerToFail:swipeLeft];
    [swipeDown requireGestureRecognizerToFail:swipeRight];
    [swipeDown requireGestureRecognizerToFail:singleTap];
    
    singleTap.cancelsTouchesInView = YES;
    
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:singleTap];
    [self.view addGestureRecognizer:swipeDown];
}

-(void)didSingleTap:(UITapGestureRecognizer*)tapGesture
{
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tap" object:nil];
    
}
@end
