//
//  TAKGeocoderTests.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/24/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <objc/runtime.h>
#import "TAKGeocoderTests.h"
#import "TAKGeocoder.h"

@interface TAKGeocoderTests ()

@property TAKGeocoder *geocoder;

@end

@implementation TAKGeocoderTests

#pragma mark - Set-up and tear-down

- (void)setUp
{
    [super setUp];
    
    // Set-up code here.
    self.geocoder = [[TAKGeocoder alloc] init];
}

- (void)tearDown
{
    // Tear-down code here.
    self.geocoder = nil;
    
    [super tearDown];
}

#pragma mark - Location controller lifecycle methods

- (void)testLocationControllerInitialization
{
    STAssertNotNil(self.geocoder, @"Cannot create an instance of the geocoder");
}

#pragma mark - Geocoder

- (void)testReverseGeocodeLocation
{
    // Aleksanterinkatu 52, Helsinki, Finland
    CLLocation *location = [[CLLocation alloc] initWithLatitude:60.168824 longitude:24.942422];
    NSDictionary *geocodedPlacemarkAddressDictionary = [self.geocoder reverseGeocodeLocation:location];
    
    STAssertNotNil(geocodedPlacemarkAddressDictionary, @"Geocoder should be able to find an address");
}

- (void)testForwardGeocodeAddress
{
    // Aleksanterinkatu 52, Helsinki, Finland
    NSString *address = @"Aleksanterinkatu 52, Helsinki, Finland";
    CLLocation *geocodedPlacemarkLocation = [self.geocoder forwardGeocodeAddress:address];
    
    STAssertNotNil(geocodedPlacemarkLocation,
                   @"Geocoder should be able to find a location based on an address");
}

@end
