//
//  TAKLocationControllerTests.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/21/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKLocationControllerTests.h"
#import "TAKLocationController.h"
#import <objc/runtime.h>

@interface TAKLocationControllerTests ()

@property (nonatomic, strong) TAKLocationController *locationController;

@end

@implementation TAKLocationControllerTests

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.locationController = [[TAKLocationController alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    self.locationController = nil;
    
    [super tearDown];
}

- (void)testLocationControllerInstantiation
{
    STAssertNotNil(self.locationController, @"Cannot instantiate the location controller");
}

- (void)testLocationControllerPropertiesExist
{
    objc_property_t locationManagerProperty = class_getProperty([self.locationController class], "locationManager");
    objc_property_t isLocationManagerCurrentlyActiveProperty = class_getProperty([self.locationController class],
                                                                                 "isLocationManagerCurrentlyActive");
    
    STAssertTrue(locationManagerProperty != NULL, @"LocationController needs a locationManager property");
    STAssertTrue(isLocationManagerCurrentlyActiveProperty != NULL,
                 @"LocationController needs an isLocationManagerCurrentlyActive property");
}

- (void)testEnableLocationManager // Tests both the condition when the location services are enabled and disabled on the device
{
    BOOL areLocationServicesSupported = [CLLocationManager locationServicesEnabled];
    
    BOOL isLocationMangagerEnablingSuccessful = [self.locationController enableLocationManager];
    
    STAssertEquals(areLocationServicesSupported, isLocationMangagerEnablingSuccessful,
                   @"Cannot start location monitoring when location services are enabled / "
                   @"Can start location monitoring when location services are disabled");
}

- (void)testEnableRegionMonitoring
{
    BOOL isRegionMonitoringSupported = [CLLocationManager regionMonitoringAvailable];
    BOOL isLocationManagerAuthorized;
    
    if (([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
        && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)) {
        NSLog(@"Cannot start region monitoring because location services are not enabled.");
        isLocationManagerAuthorized = NO;
    } else {
        isLocationManagerAuthorized = YES;
    }
    
    BOOL isRegionMonitoringSupportedAndLocationManagerAuthorized
         = isRegionMonitoringSupported && isLocationManagerAuthorized;
    
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(60, 60)
                                                               radius:150
                                                           identifier:@"test region"];
    
    BOOL isRegionMonitoringEnablingSuccessful = [self.locationController enableRegionMonitoringForRegion:region];
    
    STAssertEquals(isRegionMonitoringSupportedAndLocationManagerAuthorized, isRegionMonitoringEnablingSuccessful,
                   @"Cannot enable region monitoring when the device supports it /"
                   @"Can enable region monitoring when the device does not support it");
                                                 
}

- (void)testDisableRegionMonitoring
{
    // BOOL isRegionMonitoringSupported = [CLLocationManager regionMonitoringAvailable];
    
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(60, 60)
                                                               radius:150
                                                           identifier:@"test region"];
    
    [self.locationController enableRegionMonitoringForRegion:region];
    
    BOOL isDisablingOfRegionMonitoringSuccessful = [self.locationController disableRegionMonitoringForRegion:region];
    
    STAssertEquals(isDisablingOfRegionMonitoringSuccessful, YES,
                   @"Cannot disable region monitoring");
}

- (void)testDisableRegionMonitoringWhenItHasNotBeenEnabledYet
{
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(60, 60)
                                                               radius:150
                                                           identifier:@"test region"];
    
    BOOL isDisablingOfRegionMonitoringSuccessful = [self.locationController disableRegionMonitoringForRegion:region];
    
    STAssertEquals(isDisablingOfRegionMonitoringSuccessful, YES,
                   @"Cannot disable region monitoring");
}

@end
