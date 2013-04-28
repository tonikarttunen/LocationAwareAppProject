//
//  TAKLocationController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/21/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKLocationController.h"
#import "TAKAppDelegate.h"
#import "TAKLocalSearchResultsViewController.h"

@interface UIViewController ()

@property (nonatomic, strong) TAKMapView *mapView;

@end

@implementation TAKLocationController

#pragma mark - Lifecycle methods

- (id)init
{
    self = [super init];
    if (self) {
        [self enableLocationManager];
        if (![CLLocationManager regionMonitoringAvailable]) {
            // self.isRegionMonitoringDesired = NO;
        } else {
            // self.isRegionMonitoringDesired = [self isLocationManagerAuthorizedByUser];
        }
    }
    return self;
}

- (void)dealloc
{
    self.locationManager.delegate = nil;
    self.locationManager = nil;
    self.lastKnownLocation = nil;
}

#pragma mark - Location manager

- (BOOL)enableLocationManager
{
    if ([CLLocationManager locationServicesEnabled] && [self isLocationManagerAuthorizedByUser]) {
        if (self.locationManager == nil) {
            self.locationManager = [[CLLocationManager alloc] init];
            self.locationManager.delegate = self;
            
            @try {
                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
                id result = [userDefaults objectForKey:@"Obfuscate"];
                if (result && [result isKindOfClass:[NSNumber class]]) {
                    int resultValue = [result integerValue];
                    NSLog(@"obfuscate: %i", resultValue);
                    if (resultValue == 1) {
                        self.isLocationObfuscated = YES;
                    } else {
                        self.isLocationObfuscated = NO;
                    }
                } else {
                    self.isLocationObfuscated = NO;
                    [userDefaults setValue:[NSNumber numberWithInt:0] forKey:@"Obfuscate"];
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.description);
            }

//            
//            CLLocationAccuracy accuracy;
//            NSLog(@"Reading the saved location accuracy value from the standard user defaults...");
//            @try {
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                id locationAccuracy = [userDefaults objectForKey:TAK_LOCATION_ACCURACY];
//                if ((locationAccuracy != nil) && [locationAccuracy isKindOfClass:[NSString class]]) { // a previously chosen value exists
//                    // accuracy = (CLLocationAccuracy)[locationAccuracy doubleValue];
//                    
//                    if ([locationAccuracy isEqualToString:TAK_LOCATION_ACCURACY_BEST]) {
//                        accuracy = kCLLocationAccuracyBest;
//                    } else if ([locationAccuracy isEqualToString:TAK_LOCATION_ACCURACY_TEN_METERS]) {
//                        accuracy = kCLLocationAccuracyNearestTenMeters;
//                    } else if ([locationAccuracy isEqualToString:TAK_LOCATION_ACCURACY_HUNDRED_METERS]) {
//                        accuracy = kCLLocationAccuracyHundredMeters;
//                    } else if ([locationAccuracy isEqualToString:TAK_LOCATION_ACCURACY_ONE_KILOMETER]) {
//                        accuracy = kCLLocationAccuracyKilometer;
//                    } else if ([locationAccuracy isEqualToString:TAK_LOCATION_ACCURACY_THREE_KILOMETERS]) {
//                        accuracy = kCLLocationAccuracyThreeKilometers;
//                    } else {
//                        accuracy = kCLLocationAccuracyBestForNavigation;
//                    }
//                    
//                    NSLog(@"Current location accuracy: %f, dict value: %@", accuracy, locationAccuracy);
//                    
////                    [userDefaults setValue:TAK_LOCATION_ACCURACY_HUNDRED_METERS forKey:TAK_LOCATION_ACCURACY]; // Current location
////                    [userDefaults synchronize];
//                } else { // The first application launch...
//                    [userDefaults setValue:TAK_LOCATION_ACCURACY_HUNDRED_METERS forKey:TAK_LOCATION_ACCURACY]; // Current location
//                    [userDefaults synchronize];
//                    NSLog(@"The value of the location accuracy did not exist in the standard user defaults."
//                          @" Setting the value as kCLLocationAccuracyHundredMeters.");
//                }
//            }
//            @catch (NSException *exception) {
//                accuracy = kCLLocationAccuracyHundredMeters;
//                NSLog(@"%@", exception.description);
//            }
            
            self.locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters; // accuracy;
            self.locationManager.distanceFilter = kCLLocationAccuracyHundredMeters; // (CLLocationDistance)accuracy;
            self.lastKnownLocation = [[CLLocation alloc] init];
        }
        [self.locationManager startUpdatingLocation];
        self.isLocationManagerCurrentlyActive = YES;
        // self.locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
        return YES;
    } else {
        self.isLocationManagerCurrentlyActive = NO;
        NSLog(@"Location services not enabled.");
        return NO;
    }
}

- (BOOL)disableLocationManager
{
    if (self.locationManager != nil) {
        [self.locationManager stopUpdatingLocation];
        self.isLocationManagerCurrentlyActive = NO;
    }
    return YES;
}

- (BOOL)isLocationManagerAuthorizedByUser
{
    if (([CLLocationManager authorizationStatus] != kCLAuthorizationStatusAuthorized)
        && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusNotDetermined)
        && ([CLLocationManager authorizationStatus] != kCLAuthorizationStatusRestricted)) {
        NSLog(@"Location services are not enabled.");
        return NO;
    }
    return YES;
}

#pragma mark - Region monitoring (geofencing)

- (BOOL)enableRegionMonitoringForRegion:(CLRegion *)region identifier:(NSString *)identifier
{
    if (self.locationManager == nil) {
        BOOL success = [self enableLocationManager];
        if (success) {
            return [self isEnablingRegionMonitoringSuccessfulForRegion:region identifier:identifier];
        } else { // Location services not enabled.
            NSLog(@"Cannot start region monitoring - location services not enabled.");
            return NO;
        }
    } else { // Location manager has already been instantiated
        return [self isEnablingRegionMonitoringSuccessfulForRegion:region identifier:identifier];
    }
}

- (BOOL)isEnablingRegionMonitoringSuccessfulForRegion:(CLRegion *)region identifier:(NSString *)identifier
{
    if (![CLLocationManager regionMonitoringAvailable]) {
        NSLog(@"Region monitoring is not supported on this device.");
        return NO;
    }
    
    if (![self isLocationManagerAuthorizedByUser]) {
        return NO;
    }
    
    // Clear out previously monitored regions
    [self clearOutOldRegionsFromLocationManager];
    
    [self.locationManager startMonitoringForRegion:region];
    
//    TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    if (appDelegate != nil) {
//        appDelegate.isRegionMonitoringActive = YES;
//    }
    
#ifdef DEBUG
    NSLog(@"Region monitoring enabled.");
#endif
    return YES;
}

- (BOOL)enableRegionMonitoringForCircularMapOverlay:(MKCircle *)overlay identifier:(NSString *)identifier
{
    if (self.locationManager == nil) {
        BOOL success = [self enableLocationManager];
        if (success) {
            return [self isEnablingRegionMonitoringSuccessfulForCircularMapOverlay:overlay identifier:identifier];
        } else { // Location services not enabled.
            NSLog(@"Cannot start region monitoring - location services not enabled.");
            return NO;
        }
    } else { // Location manager has already been instantiated
        return [self isEnablingRegionMonitoringSuccessfulForCircularMapOverlay:overlay identifier:identifier];
    }
}

- (BOOL)isEnablingRegionMonitoringSuccessfulForCircularMapOverlay:(MKCircle *)overlay identifier:(NSString *)identifier
{
    if (![CLLocationManager regionMonitoringAvailable]) {
        NSLog(@"Region monitoring is not supported on this device.");
        return NO;
    }
    
    if (![self isLocationManagerAuthorizedByUser]) {
        return NO;
    }
    
    // Clear out previously monitored regions
    [self clearOutOldRegionsFromLocationManager];
    
    CLLocationDegrees regionRadius = overlay.radius;
    if (regionRadius > self.locationManager.maximumRegionMonitoringDistance) {
        regionRadius = self.locationManager.maximumRegionMonitoringDistance;
    }
    
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:overlay.coordinate
                                                               radius:regionRadius
                                                           identifier:identifier];
    [self.locationManager startMonitoringForRegion:region];
    
//    TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//    if (appDelegate != nil) {
//        appDelegate.isRegionMonitoringActive = YES;
//    }
    
#ifdef DEBUG
    NSLog(@"Region monitoring enabled.");
#endif
    return YES;
}

- (BOOL)disableRegionMonitoringForCircularMapOverlay:(MKCircle *)overlay identifier:(NSString *)identifier
{
    if (overlay == nil) {
#ifdef DEBUG
        NSLog(@"Cannot stop region monitoring because the overlay is nil");
#endif
        return NO;
    }
    
    if (identifier == nil) {
#ifdef DEBUG
        NSLog(@"Cannot stop region monitoring because the identifier is nil");
#endif
        return NO;
    }
    
    @try {
        for (CLRegion *monitoredObject in self.locationManager.monitoredRegions) {
            if ([monitoredObject.identifier isEqualToString:identifier]) {
                [self.locationManager stopMonitoringForRegion:monitoredObject];
#ifdef DEBUG
                NSLog(@"Stopped monitoring region: %@", [monitoredObject description]);
#endif
            }
        }
//        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        if (appDelegate != nil) {
//            appDelegate.isRegionMonitoringActive = NO;
//        }
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot stop monitoring region: %@", exception.description);
        return NO;
    }
}

- (void)clearOutOldRegionsFromLocationManager
{
    if (self.locationManager.monitoredRegions.count > 0) {
        @try {
            for (id monitoredObject in self.locationManager.monitoredRegions) {
                [self.locationManager stopMonitoringForRegion:monitoredObject];
            }
            NSLog(@"Cleared out previously monitored regions from self.locationManager "
                  @"successfully");
        }
        @catch (NSException *exception) {
            NSLog(@"Cannot clear out all the previously monitored regions from "
                  @"self.locationManager.monitoredRegions.");
        }
    }
}

- (BOOL)disableRegionMonitoringForRegion:(CLRegion *)region identifier:(NSString *)identifier
{
    if (region == nil) {
#ifdef DEBUG
        NSLog(@"Cannot stop region monitoring because the region is nil");
#endif
        return NO;
    }
    
    if (identifier == nil) {
#ifdef DEBUG
        NSLog(@"Cannot stop region monitoring because the identifier is nil");
#endif
        return NO;
    }

    @try {
        [self.locationManager stopMonitoringForRegion:region];
#ifdef DEBUG
        NSLog(@"Stopped monitoring region: %@", [region description]);
#endif
//        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        if (appDelegate != nil) {
//            appDelegate.isRegionMonitoringActive = NO;
//        }
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot stop monitoring region: %@", exception.description);
        return NO;
    }
}

#pragma mark - Location manager delegate methods

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    if (status == kCLAuthorizationStatusAuthorized) {
        // self.isRegionMonitoringDesired = YES;
        [self enableLocationManager];
    } else {
        // self.isRegionMonitoringDesired = NO;
        [self disableLocationManager];
//        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//        if (appDelegate && appDelegate.isRegionMonitoringActive) {
//            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Location Services Turned Off" message:@"You have set a location-based reminder. Unfortunately, location-based reminders do not work if location services are turned off" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//            [alertView show];
//        }
    }
#ifdef DEBUG
    NSLog(@"Location manager status: %u", status);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didEnterRegion:(CLRegion *)region
{
#ifdef DEBUG
    NSLog(@"Did enter region: %@", [region description]);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didExitRegion:(CLRegion *)region
{
#ifdef DEBUG
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
#ifdef DEBUG
    NSLog(@"Did start monitoring for region: %@", [region description]);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didUpdateHeading:(CLHeading *)newHeading
{
#ifdef DEBUG
    NSLog(@"Did update heading: %@", [newHeading description]);
#endif
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    self.realLocation = [locations lastObject];
    
    if (!self.isLocationObfuscated) {
        self.lastKnownLocation = self.realLocation;
    } else {
        double randomNumberForlocationObfuscation = ((double)rand() / (RAND_MAX)) + 1.0;
        double maximumObfuscationInKilometers = 0.35;
        CLLocationDegrees latitude = self.realLocation.coordinate.latitude + ((randomNumberForlocationObfuscation * maximumObfuscationInKilometers) / 110.0); //   ((0.25f * ((rand() % (2)))) / 111.0f);
        CLLocationDegrees longitude = self.realLocation.coordinate.longitude + ((randomNumberForlocationObfuscation * maximumObfuscationInKilometers) / 110.0); //  ((0.25f * ((rand() % (2)))) / 111.0f);
        self.lastKnownLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
    }
    
    /* 
     * Uncomment this if you want that the centerpoint of the map is always user's location
     * (note: you may need to adjust the distance filter and the desired location accuracy in the init method).
     */ /*
    @try {
        UINavigationController *navigationController = (UINavigationController *)[[[[UIApplication sharedApplication] delegate] window] rootViewController];
        if ((navigationController != nil) && (navigationController.viewControllers != nil) && (navigationController.viewControllers.count > 1)) {
            UIViewController *viewController = (UIViewController *)[navigationController.viewControllers objectAtIndex:1];
            if (viewController && [viewController respondsToSelector:@selector(mapView)]) {
                [[viewController mapView] moveCenterPointToCurrentLocationAnimated:YES];
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    } */
#ifdef DEBUG
    NSLog(@"Real location: lat: %f, long: %f", self.realLocation.coordinate.latitude, self.realLocation.coordinate.longitude);
    NSLog(@"Did update locations: \ntimestamp: %@, \nlatitude: %f, longitude: %f, \naltitude: %f, speed: %f, course: %f",
          self.lastKnownLocation.timestamp, self.lastKnownLocation.coordinate.latitude,
          self.lastKnownLocation.coordinate.longitude, self.lastKnownLocation.altitude,
          self.lastKnownLocation.speed, self.lastKnownLocation.course);
#endif
}

- (void)locationManager:(CLLocationManager *)manager monitoringDidFailForRegion:(CLRegion *)region withError:(NSError *)error
{
    NSLog(@"Region monitoring did fail for region: %@", [error description]);
}

- (void)locationManagerDidPauseLocationUpdates:(CLLocationManager *)manager
{
#ifdef DEBUG
    NSLog(@"Did pause location updates: %@", [manager description]);
#endif
}

- (void)locationManagerDidResumeLocationUpdates:(CLLocationManager *)manager
{
#ifdef DEBUG
    NSLog(@"Did resume location updates: %@", [manager description]);
#endif
}

@end
