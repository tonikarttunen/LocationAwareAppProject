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

@interface TAKLocationController (UnitTestAdditions)

// #warning TODO: Test these methods
- (BOOL)isEnablingRegionMonitoringSuccessfulForRegion:(CLRegion *)region identifier:(NSString *)identifier;
- (BOOL)isEnablingRegionMonitoringSuccessfulForCircularMapOverlay:(MKCircle *)overlay identifier:(NSString *)identifier;
- (void)clearOutOldRegionsFromLocationManager;

@end

@interface TAKLocationControllerTests ()

@property (nonatomic, strong) TAKLocationController *locationController;

@end

@implementation TAKLocationControllerTests

#pragma mark - Set-up and tear-down

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

#pragma mark - Location controller lifecycle methods

- (void)testLocationControllerInitialization
{
    STAssertNotNil(self.locationController, @"Cannot create an instance of the location controller");
}

#pragma mark - Properties

- (void)testLocationControllerPropertiesExist
{
    objc_property_t locationManagerProperty = class_getProperty([self.locationController class], "locationManager");
    objc_property_t lastKnownLocationProperty = class_getProperty([self.locationController class], "lastKnownLocation");
    objc_property_t isLocationManagerCurrentlyActiveProperty = class_getProperty([self.locationController class],
                                                                                 "isLocationManagerCurrentlyActive");
    // objc_property_t isRegionMonitoringDesiredProperty = class_getProperty([self.locationController class],
    //                                                                              "isRegionMonitoringDesired");
    
    STAssertTrue(locationManagerProperty != NULL, @"LocationController needs a locationManager property");
    STAssertTrue(lastKnownLocationProperty != NULL, @"LocationController needs a lastKnownLocation property");
    STAssertTrue(isLocationManagerCurrentlyActiveProperty != NULL,
                 @"LocationController needs an isLocationManagerCurrentlyActive property");
    // STAssertTrue(isRegionMonitoringDesiredProperty != NULL,
    //              @"LocationController needs an isRegionMonitoringDesired property");
}

#pragma mark - Location manager

- (void)testEnableLocationManager // Tests both the condition when the location services are enabled and disabled on the device
{
    BOOL areLocationServicesSupported = [CLLocationManager locationServicesEnabled];
    BOOL isLocationManagerAuthorized;
    
    if (([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
        && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)
        && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted)) {
        // NSLog(@"Cannot enable location manager because location services are not enabled.");
        isLocationManagerAuthorized = NO;
    } else {
        isLocationManagerAuthorized = YES;
    }
    
    BOOL isLocationManagerAuthorizedAndLocationServicesSupported
        = areLocationServicesSupported && isLocationManagerAuthorized;
    
    BOOL isLocationManagerEnablingSuccessful = [self.locationController enableLocationManager];
    
    STAssertEquals(isLocationManagerAuthorizedAndLocationServicesSupported, isLocationManagerEnablingSuccessful,
                   @"Cannot start location monitoring when location services are enabled / "
                   @"Can start location monitoring when location services are disabled");
}

#pragma mark - Region monitoring (geofencing)

- (void)testEnableRegionMonitoringForRegion
{
    BOOL isRegionMonitoringSupported = [CLLocationManager regionMonitoringAvailable];
    BOOL isLocationManagerAuthorized;
    
    if (([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
        && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)
        && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted)) {
        // NSLog(@"Cannot start region monitoring because location services are not enabled.");
        isLocationManagerAuthorized = NO;
    } else {
        isLocationManagerAuthorized = YES;
    }
    
    BOOL isRegionMonitoringSupportedAndLocationManagerAuthorized
         = isRegionMonitoringSupported && isLocationManagerAuthorized;
    
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(60, 60)
                                                               radius:150
                                                           identifier:@"test region 1 id"];
    
    BOOL isRegionMonitoringEnablingSuccessful =
        [self.locationController enableRegionMonitoringForRegion:region identifier:region.identifier];
    
    STAssertEquals(isRegionMonitoringSupportedAndLocationManagerAuthorized, isRegionMonitoringEnablingSuccessful,
                   @"Cannot enable region monitoring when the device supports it /"
                   @"Can enable region monitoring when the device does not support it");
                                                 
}

- (void)testDisableRegionMonitoringForRegion
{
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(60, 60)
                                                               radius:150
                                                           identifier:@"test 1 region id"];
    
    [self.locationController enableRegionMonitoringForRegion:region identifier:region.identifier];
    
    BOOL isDisablingOfRegionMonitoringSuccessful =
        [self.locationController disableRegionMonitoringForRegion:region identifier:region.identifier];
    
    STAssertEquals(isDisablingOfRegionMonitoringSuccessful, YES,
                   @"Cannot disable region monitoring");
}

- (void)testDisableRegionMonitoringForRegionWhenItHasNotBeenEnabledYet
{
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(60, 60)
                                                               radius:150
                                                           identifier:@"test region"];
    
    BOOL isDisablingOfRegionMonitoringSuccessful =
        [self.locationController disableRegionMonitoringForRegion:region identifier:region.identifier];
    
    STAssertEquals(isDisablingOfRegionMonitoringSuccessful, YES,
                   @"Cannot disable region monitoring");
}

- (void)testEnableRegionMonitoringForCircularMapOverlay
{
    BOOL isRegionMonitoringSupported = [CLLocationManager regionMonitoringAvailable];
    BOOL isLocationManagerAuthorized;
    
    if (([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
        && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)
        && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted)) {
        // NSLog(@"Cannot start region monitoring because location services are not enabled.");
        isLocationManagerAuthorized = NO;
    } else {
        isLocationManagerAuthorized = YES;
    }
    
    BOOL isRegionMonitoringSupportedAndLocationManagerAuthorized
    = isRegionMonitoringSupported && isLocationManagerAuthorized;
    
    MKCircle *mapOverlayCircle = [[MKCircle alloc] init];
    
    BOOL isRegionMonitoringEnablingSuccessful =
    [self.locationController enableRegionMonitoringForCircularMapOverlay:mapOverlayCircle identifier:@"overlayID"];
    
    STAssertEquals(isRegionMonitoringSupportedAndLocationManagerAuthorized, isRegionMonitoringEnablingSuccessful,
                   @"Cannot enable region monitoring when the device supports it /"
                   @"Can enable region monitoring when the device does not support it");
    
}

- (void)testDisableRegionMonitoringForCircularMapOverlay
{
    MKCircle *mapOverlayCircle = [[MKCircle alloc] init];
    
    [self.locationController enableRegionMonitoringForCircularMapOverlay:mapOverlayCircle identifier:@"overlayID"];
    
    BOOL isDisablingOfRegionMonitoringSuccessful =
    [self.locationController disableRegionMonitoringForCircularMapOverlay:mapOverlayCircle identifier:@"overlayID"];
    
    STAssertEquals(isDisablingOfRegionMonitoringSuccessful, YES,
                   @"Cannot disable region monitoring");
}

- (void)testDisableRegionMonitoringForCircularMapOverlayWhenItHasNotBeenEnabledYet
{
    MKCircle *mapOverlayCircle = [[MKCircle alloc] init];
    
    BOOL isDisablingOfRegionMonitoringSuccessful =
    [self.locationController disableRegionMonitoringForCircularMapOverlay:mapOverlayCircle identifier:@"overlayID"];
    
    STAssertEquals(isDisablingOfRegionMonitoringSuccessful, YES,
                   @"Cannot disable region monitoring");
}

@end
