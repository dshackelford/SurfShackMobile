//
//  LogViewController.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/2/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "LogViewController.h"

@implementation LogViewController

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
    
    screenSize = CGSizeMake([UIScreen mainScreen].bounds.size.width,[UIScreen mainScreen].bounds.size.height);
    
    tableData = @[@"When did you go out?",@"How long was the session",@"Description",@"Notify when prediction matches",@"Alert Message"];
    
    rowHeight = 55;
    sectionHeader = 50;
    
    pickerData = @[@"1",@"2",@"3",@"4",@"5",@"6",@"7",@"8",@"9",@"10",@"11",@"12",@"13",@"14",@"15",@"16",@"17",@"18",@"19",@"20",@"21",@"22",@"23",@"24"];
    
    self.title = @"Log a Session";
    
    self.tableView.backgroundColor = [UIColor colorWithRed:240/255.f green:240/255.f blue:240/255.f alpha:1];
    
    self.tableView.scrollEnabled = NO;
    
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(changeColor:) name:@"changeColorPref" object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self restrictRotation:YES];
}

-(void)changeColor:(NSNotification*)notification
{
    NSDictionary* dict = [PreferenceFactory getPreferences];
    
    self.navigationController.navigationBar.barTintColor = [dict objectForKey:kColorScheme];
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

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0; // you can have your own choice, of course
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 1 || indexPath.row == 2)
    {
        return 75;
    }
    else
    {
        return rowHeight;
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    static NSString *HeaderCellIdentifier = @"Header";
//    
//    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:HeaderCellIdentifier];
//    
//    cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:HeaderCellIdentifier];
//    
//    return cell;
//}

-(UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 0)
    {
        TextInputCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"TextInputCell" owner:self options:nil] lastObject];
        
        cell.cellLabel.text = [tableData objectAtIndex:indexPath.row];
        
        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
        datePicker.datePickerMode = UIDatePickerModeDate;
//        [datePicker addTarget:self action:@selector(updateTextField:)
//                     forControlEvents:UIControlEventValueChanged];
        [cell.cellTextField setInputView:datePicker];
        
//        [cell.cellTextField targetForAction:@selector(someTextFieldTouchDown:) withSender:self];
        
//        [cell.cellTextField actionsForTarget: forControlEvent:UIControlEventTouchDown];
//        [cell.cellTextField sendAction:@selector(someTextFieldTouchDown:) to:self forEvent:UIEventTypeTouches];
        
        return cell;
    }
    
    arrowCell* cell = [[[NSBundle mainBundle] loadNibNamed:@"arrowCell" owner:self options:nil] lastObject];
    [tableView setSeparatorStyle:UITableViewCellSeparatorStyleSingleLine];
    
    cell.textLabel.text = [tableData objectAtIndex:indexPath.row];
    
    if (indexPath.row == 3)
    {
        UISwitch* aSwicth= [[UISwitch alloc] initWithFrame:CGRectZero];
        [cell addSubview:aSwicth];
        [cell setAccessoryView:aSwicth];
    }
    else if(indexPath.row == 1 || indexPath.row == 2)
    {
        UIPickerView* aPickerView = [[UIPickerView alloc] initWithFrame:CGRectMake(200, 0, 100, 50)];
        [cell addSubview:aPickerView];
        [cell setAccessoryView:aPickerView];
        aPickerView.delegate = self;
        aPickerView.dataSource = self;

        
    }
    else
    {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator]; //the grey chevron
    }
    
//    cell.imageView.image = [UIImage imageNamed:@"units.png"];
    return cell;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    self.selectedRow = (int)indexPath.row;
    self.selectedSection = (int)indexPath.section;
    
    NSLog(@"%d",self.selectedRow);
    
}

- (IBAction)someTextFieldTouchDown:(UITextField *)sender
{
    NSLog(@"touched textfield");
//    if (self.someTextField.inputView == nil)
//    {
//        UIDatePicker *datePicker = [[UIDatePicker alloc] init];
//        datePicker.datePickerMode = UIDatePickerModeDate;
//        [datePicker addTarget:self action:@selector(updateTextField:)
//             forControlEvents:UIControlEventValueChanged];
//        [self.someTextField setInputView:datePicker];
//    }
}

//-(void)updateTextField:(UIDatePicker *)sender
//{
//    self.someTextField.text = [self.dateFormat stringFromDate:sender.date];
//}


#pragma mark - UIPicker
//- (NSInteger)numberOfRowsInComponent:(NSInteger)component
//{
//    return 24;
//}
- (CGSize)rowSizeForComponent:(NSInteger)component
{
    return CGSizeMake(100, 10);
}

// returns the number of 'columns' to display.
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

// returns the # of rows in each component..
- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 24;
}

// returns width of column and height of row for each component.
- (CGFloat)pickerView:(UIPickerView *)pickerView widthForComponent:(NSInteger)component
{
    return 20.;
}
- (CGFloat)pickerView:(UIPickerView *)pickerView rowHeightForComponent:(NSInteger)component
{
    return rowHeight;
}

// these methods return either a plain NSString, a NSAttributedString, or a view (e.g UILabel) to display the row for the component.
// for the view versions, we cache any hidden and thus unused views and pass them back for reuse.
// If you return back a different object, the old one will be released. the view will be centered in the row rect
- (nullable NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return [pickerData objectAtIndex:row];
    
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    
}

@end
