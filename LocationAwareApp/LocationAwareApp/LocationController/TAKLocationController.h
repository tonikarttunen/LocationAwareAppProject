//
//  TAKLocationController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/21/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface TAKLocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocation *lastKnownLocation;
@property (setter = setLocationManagerCurrentlyActive:) BOOL isLocationManagerCurrentlyActive;
@property (setter = setRegionMonitoringDesired:) BOOL isRegionMonitoringDesired;

- (BOOL)enableLocationManager;
- (BOOL)disableLocationManager;

- (BOOL)enableRegionMonitoringForRegion:(CLRegion *)region identifier:(NSString *)identifier;
- (BOOL)disableRegionMonitoringForRegion:(CLRegion *)region identifier:(NSString *)identifier;

- (BOOL)enableRegionMonitoringForCircularMapOverlay:(MKCircle *)overlay identifier:(NSString *)identifier;
- (BOOL)disableRegionMonitoringForCircularMapOverlay:(MKCircle *)overlay identifier:(NSString *)identifier;

@end
