//
//  ReportPageViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/4/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ReportPageViewController.h"

#import "OfflineData.h"
#import "DBQueries.h"

@implementation ReportPageViewController

-(void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeTitle:) name:@"changeTitle" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changedSpotFavorites:) name:@"changedSpotFavorites" object:nil];
    
    NSLog(@"page view controler loaded");
    
    dataFactory = [[DataFactory alloc] init];
    
    db = [[DBManager alloc] init];
    
    _favoriteSpotsArr = [DBQueries getSpotFavorites];
    _favoriteCounties = [DBQueries getCountyFavorites];

    screenSize = [UIScreen mainScreen].bounds.size;
    
    pageControl = [UIPageControl appearance];
    pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    pageControl.currentPageIndicatorTintColor = [UIColor blackColor];
    pageControl.backgroundColor = [UIColor clearColor];

    //CHOOSE COLORS FROM THE COLOR SCHEME IN PREFERENCE, IT SHOULD BE A DICTIONARY FOR EACH COLOR SCHEME THAT HAS PLOT VIEW COLORS AND BAR COLORS.
    NSDictionary* prefs = [PreferenceFactory getPreferences];
    UIColor* color = [prefs objectForKey:kColorScheme];
    
    self.navigationController.navigationBar.barTintColor = color;
    self.navigationController.navigationBar.titleTextAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:NSForegroundColorAttributeName];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor]; //buttons to a color tint
    //    self.view.backgroundColor = [UIColor colorWithRed:22/255.f green:119/255.f blue:205/255.f alpha:1];
    
    self.tabBarController.view.tintColor = [UIColor colorWithRed:22/255.f green:119/255.f blue:205/255.f alpha:1];
    
    if ([_favoriteSpotsArr count] > 0)
    {
        //refreshButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRefresh target:self action:@selector(didPressRefreshButton:)];
        
        self.activityView = [[UIActivityIndicatorView alloc] initWithFrame:CGRectMake(0, 0, 20, 20)];
        self.activityIndicatorButton = [[UIBarButtonItem alloc] initWithCustomView:self.activityView];
        self.navigationItem.leftBarButtonItem = self.activityIndicatorButton;
        [self.activityView startAnimating];
        
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
    _favoriteSpotsArr = [DBQueries getSpotFavorites];
    _favoriteCounties = [DBQueries getCountyFavorites];
    
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
    if ([[DBQueries getSpotFavorites] count] > 0)
    {
        self.title = [[DBQueries getSpotNameFavorites] objectAtIndex:[notification.object integerValue]];
    }
    
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
    [dataFactory removeData];
    
    [dataFactory getDataForSpots:_favoriteSpotsArr andCounties:_favoriteCounties];
    
    NSLog(@"Swiped Down to refresh!");
    
    //tells the report views to remove their subviews and to start the indicator
    [[NSNotificationCenter defaultCenter] postNotificationName:@"refreshData" object:nil];
    
    [self navigationItem].leftBarButtonItem = self.activityIndicatorButton;
    [self.activityView startAnimating];
}

-(void)changedSpotFavorites:(NSNotification*)notification
{
    _favoriteSpotsArr =  [DBQueries getSpotFavorites];
    [theTableView reloadData];
    
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

#pragma mark - Activity Responder Methods

-(void)isLoadingData:(BOOL)isLoading
{
    if(isLoading)
    {
        self.navigationItem.leftBarButtonItem = self.activityIndicatorButton;
        [self.activityView startAnimating];
    }
    else
    {
        [self.activityView stopAnimating];
    }
}
#pragma mark - Page View Controller Delegate Methods
-(void)addPageViewController
{
    ReportViewController *startingViewController = [self viewControllerAtIndex:0];
    startingViewController.activityDelegate = self;
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
//test change
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
    if (([self.favoriteSpotsArr count] == 0) || (index >= [self.favoriteSpotsArr count]))
    {
        return nil;
    }
    
    // Create a new view controller and pass suitable data.
    ReportViewController *pageContentViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"ReportViewController"];
    
    pageContentViewController.index = index;
    
    NSNumber* spotID = [_favoriteSpotsArr objectAtIndex:index];
    [pageContentViewController setDataFactory:dataFactory];
    pageContentViewController.activityDelegate = self;
    
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
    tableData = [[NSMutableArray alloc] initWithArray:[DBQueries getSpotNameFavorites]];
    
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
    
    singleTap.cancelsTouchesInView = YES;
    
    [self.view addGestureRecognizer:swipeRight];
    [self.view addGestureRecognizer:swipeLeft];
    [self.view addGestureRecognizer:singleTap];
}

//long press is added via the main story board
-(IBAction)longPressBegan:(UILongPressGestureRecognizer *)recognizer
{
    if (recognizer.state == UIGestureRecognizerStateBegan)
    {
        NSLog(@"long press began");
        CGPoint touchPoint = [recognizer locationInView:self.view];
        
        double futureIndexRatio = touchPoint.x/screenSize.width;
        
        [[NSNotificationCenter defaultCenter] postNotificationName:@"futureIndexRatio" object:[NSNumber numberWithDouble:futureIndexRatio]];
        
        self.pageController.dataSource = nil;
        // Long press detected, start the timer
    }
    else if(recognizer.state == UIGestureRecognizerStateChanged)
    {
        CGPoint touchPoint = [recognizer locationInView:self.view];
        
        double futureIndexRatio = touchPoint.x/screenSize.width;

        [[NSNotificationCenter defaultCenter] postNotificationName:@"futureIndexRatio" object:[NSNumber numberWithDouble:futureIndexRatio]];
        NSLog(@"touch point x: %f and ratio: %f",touchPoint.x,futureIndexRatio);
    }
    else
    {
        if (recognizer.state == UIGestureRecognizerStateCancelled
            || recognizer.state == UIGestureRecognizerStateFailed
            || recognizer.state == UIGestureRecognizerStateEnded)
        {
            self.pageController.dataSource = self;
            [self.pageController reloadInputViews];
            NSLog(@"long press ended");
            [[NSNotificationCenter defaultCenter] postNotificationName:@"futureIndexRatio" object:[NSNumber numberWithDouble:-1]];
        }
    }
}

-(void)didSingleTap:(UITapGestureRecognizer*)tapGesture
{
    //post notification
    [[NSNotificationCenter defaultCenter] postNotificationName:@"tap" object:nil];
}


@end
