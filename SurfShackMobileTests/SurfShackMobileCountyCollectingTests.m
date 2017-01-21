//
//  SurfShackMobileCountyCollectingTests.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 7/23/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "PreferenceFactory.h"
#import "CountyHandler.h"

@interface SurfShackMobileCountyCollectingTests : XCTestCase

@end

@implementation SurfShackMobileCountyCollectingTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testCountyCollection
{
    
    NSLog(@"%@",[CountyHandler getCountyOfSpot:10]);
//    [CountyHandler moldStringForURL:@"Santa Cruz"];
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
