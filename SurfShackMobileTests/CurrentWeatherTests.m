//
//  CurrentWeatherTests.m
//  SurfShackMobile
//
//  Created by Dylan Shackelford on 8/3/16.
//  Copyright © 2016 Dylan Shackelford. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "CurrentWeather.h"
#import "SpitcastData.h"


@interface CurrentWeatherTests : XCTestCase <CLLocationManagerDelegate>
{
    CLLocationManager* locationManager;
    CLLocation* currentLocation;
}
@end

@implementation CurrentWeatherTests

- (void)setUp {
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown {
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample {
//    [self initGPS];
    
    CurrentWeather* aweath = [[CurrentWeather alloc] init];
    CLLocation* aLoc = [[CLLocation alloc] initWithLatitude:32.75 longitude:-117.25];
    //[aweath getCurrentWeatherForLoc:aLoc];
    NSLog(@"Temp: %f",[aweath getTemp]);
    NSLog(@"Description: %@",[aweath getDescription]);
    NSLog(@"sunset: %f",[aweath getSunset]);
    NSLog(@"Sunrise %f",[aweath getSunrise]);
    
    // This is an example of a functional test case.
    // Use XCTAssert and related functions to verify your tests produce the correct results.
}

- (void)testPerformanceExample {
    // This is an example of a performance test case.
    [self measureBlock:^{
        // Put the code you want to measure the time of here.
    }];
}

-(void)initGPS
{
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager requestAlwaysAuthorization];
    [locationManager requestWhenInUseAuthorization];
    [locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    currentLocation = [locations objectAtIndex:0];
    [locationManager stopUpdatingLocation];
    CLGeocoder *geocoder = [[CLGeocoder alloc] init] ;
    [geocoder reverseGeocodeLocation:currentLocation completionHandler:^(NSArray *placemarks, NSError *error)
     {
         if (!(error))
         {
             CLPlacemark *placemark = [placemarks objectAtIndex:0];
             //             NSLog(@"\nCurrent Location Detected\n");
             //             NSLog(@"placemark %@",placemark);
             NSString *locatedAt = [[placemark.addressDictionary valueForKey:@"FormattedAddressLines"] componentsJoinedByString:@", "];
             NSString *Address = [[NSString alloc]initWithString:locatedAt];
             NSString *Area = [[NSString alloc]initWithString:placemark.locality];
             NSString *Country = [[NSString alloc]initWithString:placemark.country];
             NSString *CountryArea = [NSString stringWithFormat:@"%@, %@", Area,Country];
             NSLog(@"%@",CountryArea);
             NSLog(@"%@",placemark);
             NSLog(@"lat: %f",placemark.location.coordinate.latitude);
             NSLog(@"long: %f",placemark.location.coordinate.longitude);
             //
             //             streetLabel.text = locatedAt;
             //             streetLabel.font = [UIFont systemFontOfSize:10];
             //             countyLabel.text = CountryArea;
             //             latLabel.text = [NSString stringWithFormat:@"Lat: %.3f",placemark.location.coordinate.latitude];
             //             lonLabel.text = [NSString stringWithFormat:@"Lon: %.3f",placemark.location.coordinate.longitude];
             
             NSString* lat = [NSString stringWithFormat:@"%.6f",placemark.location.coordinate.latitude];
             NSString* lon = [NSString stringWithFormat:@"%.6f",placemark.location.coordinate.longitude];
             
             NSLog(@"Lat:%@,Long:%@",lat,lon);
             
         }
         else
         {
             NSLog(@"Geocode failed with error %@", error);
             NSLog(@"\nCurrent Location Not Detected\n");
             //return;
             //             CountryArea = NULL;
         }
         /*---- For more results
          placemark.region);
          placemark.country);
          placemark.locality);
          placemark.name);
          placemark.ocean);
          placemark.postalCode);
          placemark.subLocality);
          placemark.location);
          ------*/
     }];
}


@end
