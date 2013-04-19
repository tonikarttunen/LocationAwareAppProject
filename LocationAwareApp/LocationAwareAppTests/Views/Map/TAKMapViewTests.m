//
//  TAKMapViewTests.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/24/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <objc/runtime.h>
#import "TAKMapViewTests.h"
#import "TAKMapView.h"

@interface TAKMapViewTests ()

@property TAKMapView *mapView;

@end

@implementation TAKMapViewTests

#pragma mark - Set-up and tear-down

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.mapView = [[TAKMapView alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    self.mapView = nil;
    
    [super tearDown];
}

#pragma mark - Location controller lifecycle methods

- (void)testLocationControllerInitialization
{
    STAssertNotNil(self.mapView, @"Cannot create an instance of the map view");
}

#pragma mark - Properties

- (void)testLocationControllerPropertiesExist
{
    objc_property_t mapPropertiesDictionaryProperty = class_getProperty([self.mapView class], "mapProperties");
    objc_property_t isLocationAlreadyKnownProperty = class_getProperty([self.mapView class], "isLocationAlreadyKnown");
     
    STAssertTrue(mapPropertiesDictionaryProperty != NULL, @"LocationController needs a locationManager property");
    STAssertTrue(isLocationAlreadyKnownProperty != NULL, @"LocationController needs a lastKnownLocation property");
}

#pragma mark - Map

- (void)testMoveCenterPointToLocation
{
    
}

- (void)testMoveCenterPointToCurrentLocation
{
    
}

- (void)testReadMapPropertiesFromPlistFile
{
    
}

- (void)testWriteMapPropertiesFromFile
{
    
}

@end
