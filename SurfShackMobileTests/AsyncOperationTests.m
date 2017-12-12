//
//  AsyncOperationTests.m
//  SurfShackMobileTests
//
//  Created by Dylan Shackelford on 12/10/17.
//  Copyright © 2017 Dylan Shackelford. All rights reserved.
//

#import <XCTest/XCTest.h>
//#import "AsyncBlockOperation.h"
#import <AsyncBlockOperation/AsyncBlockOperation.h>


@interface AsyncOperationTests : XCTestCase
{
    XCTestExpectation* downloadExpectation;
}
@property NSOperationQueue* q;

@end

@implementation AsyncOperationTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
    downloadExpectation = [self expectationWithDescription:@"asynchronous download"];
    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    
    NSBlockOperation* endOP = [NSBlockOperation blockOperationWithBlock:^{
        NSLog(@"operation eneded");
        [downloadExpectation fulfill];
    }];

    // Method 1. Using `AsyncBlockOperation` object
        
    AsyncBlockOperation *operation = [AsyncBlockOperation blockOperationWithBlock:^(AsyncBlockOperation *op) {
        
        sleep(9);
        NSLog(@"op finsihed");
        [op complete]; // call this method when async task finished
    }];
    [endOP addDependency:operation];
    [queue addOperation:endOP];
    [queue addOperation:operation];
    [self waitForExpectationsWithTimeout:10 handler:^(NSError * _Nullable error) {
        NSLog(@"expectations failed due to timeout");
    }];
    
    /*
    // Method 2. Using `NSOperationQueue` method
    [queue addOperationWithAsyncBlock:^(AsyncBlockOperation *op) {
        [op complete];
    }];*/
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

@end
