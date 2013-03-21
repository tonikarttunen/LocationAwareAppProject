//
//  TAKLocationController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/21/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKLocationController.h"

@implementation TAKLocationController

- (id)init
{
    self = [super init];
    if (self) {
        [self enableLocationManager];
    }
    return self;
}

- (BOOL)enableLocationManager
{
    if ([CLLocationManager locationServicesEnabled]) {
        self.locationManager = [[CLLocationManager alloc] init];
        self.locationManager.delegate = self;
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
        self.locationManager.distanceFilter = 5;
        [self.locationManager startUpdatingLocation];
        self.isLocationManagerCurrentlyActive = YES;
        return YES;
    } else {
        self.isLocationManagerCurrentlyActive = NO;
        NSLog(@"Location services not enabled.");
        return NO;
    }
}

- (BOOL)enableRegionMonitoringForRegion:(CLRegion *)region
{
    if (self.locationManager == nil) {
        BOOL success = [self enableLocationManager];
        if (success) {
            if ([CLLocationManager regionMonitoringAvailable]) {
                [self.locationManager startMonitoringForRegion:region];
#if DEBUG
                NSLog(@"Region monitoring enabled.");
#endif
                return YES;
            } else {
                NSLog(@"Region monitoring is not supported on this device.");
                return NO;
            }
        } else { // Location services not enabled.
            return NO;
        }
    } else { // Location manager has already been instantiated
        if ([CLLocationManager regionMonitoringAvailable]) {
            [self.locationManager startMonitoringForRegion:region];
#if DEBUG
            NSLog(@"Region monitoring enabled.");
#endif
            return YES;
        } else {
            NSLog(@"Region monitoring is not supported on this device.");
            return NO;
        }
    }
}

- (BOOL)disableRegionMonitoringForRegion:(CLRegion *)region
{
    if (region == nil) {
#if DEBUG
        NSLog(@"Cannot stop region monitoring because the region is nil");
#endif
        return NO;
    } else {
        [self.locationManager stopMonitoringForRegion:region];
#if DEBUG
        NSLog(@"Stopped monitoring region: %@", [region description]);
#endif
        return YES;
    }
}

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
#if DEBUG
    NSLog(@"Location manager status: %u", status);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
#if DEBUG
    NSLog(@"Did enter region: %@", [region description]);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
#if DEBUG
    NSLog(@"Did exit region: %@", [region description]);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Location manager did fail with error: %@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager didFinishDeferredUpdatesWithError:(NSError *)error
{
    NSLog(@"Location manager did finish deferred updates with error: %@", [error description]);
}

- (void)locationManager:(CLLocationManager *)manager didStartMonitoringForRegion:(CLRegion *)region
{
#if DEBUG
    NSLog(@"Did start monitoring for region: %@", [region description]);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
#if DEBUG
    NSLog(@"Did update heading: %@", [newHeading description]);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{    
    CLLocation *location = [locations lastObject];
    
#if DEBUG
    NSLog(@"Did update locations: \ntimestamp: %@, \nlatitude: %f, longitude: %f, \naltitude: %f, speed: %f, course: %f",
          location.timestamp, location.coordinate.latitude, location.coordinate.longitude,
          location.altitude, location.speed, location.course);
#endif
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Monitoring did fail for region: %@", [error description]);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
#if DEBUG
    NSLog(@"Did pause location updates: %@", [manager description]);
#endif
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
#if DEBUG
    NSLog(@"Did resume location updates: %@", [manager description]);
#endif
}

@end
