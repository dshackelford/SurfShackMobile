//
//  SurfShackMobileStringTests.m
//  SurfShackMobileTests
//
//  Created by Dylan Shackelford on 7/11/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "SpitcastData.h"    
#import "DateHandler.h"

@interface SurfShackMovileStringTests : XCTestCase

@end

@implementation SurfShackMovileStringTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    //have a dictionary with settings that determine which class i'm using within the data handler protocol?
    NSString* str = @"SpitcastData";
    id obj = [[NSClassFromString(str) alloc] init];
    
//    NSMutableArray* array = [NSClassFromString(str) getDataFromLocation:10];
    
}

-(void)testDateFormatting
{
    
    int daysInFuture = 0;
    NSDate* aDate = [NSDate dateWithTimeIntervalSinceNow:60*60*24*daysInFuture];
//    NSLog(@"%@",[DateHandler getDateString:aDate]);
    NSMutableArray* arrayOfDates = [DateHandler getArrayOfDayStrings:7];
    
    for (int i = 0; i < [arrayOfDates count]; i++)
    {
        NSLog(@"%@",[arrayOfDates objectAtIndex:i]);
    }

}

-(void)testDayStrChangeToDateNum
{
    NSString* dateFromSpit = @"Friday Jul 22 2016";
    NSString* dateNum = [DateHandler getDateNumberFromDateStr:dateFromSpit];
    
}

-(void)testGetDateStringFromNSDate
{
    NSDate* today = [NSDate dateWithTimeIntervalSinceNow:0];
    NSString* spitDate = [DateHandler getDateString:today];
}

-(void)testRevertSpitdateToDay
{
//    [DateHandler getCurrentDateString];
    [DateHandler getCurrentDay];
}

-(void)testTimeFromIndex
{
    NSString* time = [DateHandler getTimeFromIndex:5];
    NSLog(@"%@",time);
}


- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
