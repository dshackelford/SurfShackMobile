//
//  downloadOperationTests.m
//  SurfShackMobileTests
//
//  Created by Dylan Shackelford on 11/30/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <XCTest/XCTest.h>
#import "SpitcastData.h"
#import "DataCollector.h"
#import "DataSource.h"

@interface downloadOperationTests : XCTestCase <DataCollector>
{
    CLLocationManager* locationManager;
    CLLocation* currentLocation;
    XCTestExpectation* downloadExpectation;
}
@end

@implementation downloadOperationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

-(void)testDonwload
{
    downloadExpectation = [self expectationWithDescription:@"asynchronous download"];
    id<DataSource> spit = [[SpitcastData alloc] initWithShortLength:3 andLongLength:6 andCollector:self];
    [spit startSurfDataDownloadForSpotID:122 andSpotName:@"spot name"];
    [self waitForExpectationsWithTimeout:30 handler:^(NSError * _Nullable error) {
        NSLog(@"expectations failed due to timeout");
    }];
}

- (void)testExample {
    id<DataSource> spit = [[SpitcastData alloc] initWithShortLength:3 andLongLength:6 andCollector:self];
    [spit startSurfDataDownloadForSpotID:11 andSpotName:@"test name"]; //122
}

-(void)surfDataDictReceived:(NSMutableDictionary *)surfData
{
    [downloadExpectation fulfill];
    NSLog(@"got somethign");
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}


@end
