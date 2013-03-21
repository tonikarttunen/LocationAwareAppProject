//
//  TAKLocationController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/21/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@interface TAKLocationController : NSObject <CLLocationManagerDelegate>

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (setter = setLocationManagerCurrentlyActive:) BOOL isLocationManagerCurrentlyActive;
@property (setter = setRegionMonitoringDesired:) BOOL isRegionMonitoringDerired;

- (BOOL)enableLocationManager;
- (BOOL)enableRegionMonitoringForRegion:(CLRegion *)region;
- (BOOL)disableRegionMonitoringForRegion:(CLRegion *)region;

@end
