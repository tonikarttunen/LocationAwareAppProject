//
//  TAKMapView.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/23/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKMapView.h"

@implementation TAKMapView

#pragma mark - Lifecycle methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.mapProperties = [NSMutableDictionary new];
        [self readMapPropertiesFromPlistFile];
        self.isLocationAlreadyKnown = NO;
        self.showsUserLocation = YES;
        self.userTrackingMode = MKUserTrackingModeNone;
        self.delegate = self;
        self.backgroundColor = [UIColor whiteColor];
        self.opaque = YES;
        [self moveCenterPointToCurrentLocationAnimated:YES];
    }
    return self;
}

- (void)dealloc
{
    self.mapProperties = nil;
}

#pragma mark - Custom drawing

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Map

- (void)moveCenterPointToCurrentLocationAnimated:(BOOL)animated
{
    @try {
        CLLocation *currentUserLocation;
        
        TAKAppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
        CLLocation *lastLocation = myAppDelegate.locationController.lastKnownLocation;
        if (self.userLocation.location != nil) { // Use the location that was provided my the MapKit
            currentUserLocation = self.userLocation.location;
            self.isLocationAlreadyKnown = YES;
        } else if (lastLocation != nil) { // Use the last known location (if available)
            currentUserLocation = lastLocation;
            self.isLocationAlreadyKnown = YES;
        } else { // The location is unknown; the code below sets the location to San Francisco
            currentUserLocation = [[CLLocation alloc] initWithLatitude:37.781516 longitude:-122.404955];
        }
        
        // Zoom to the current location
        MKCoordinateSpan coordinateSpan;
        double mapKilometers = 3.0;
        double mapScalingFactor = ABS(cos(M_PI * 2 * currentUserLocation.coordinate.latitude / 360.0));
        double kilometersPerOneDegreeOfLatitude = 111.0; // Approximately; http://en.wikipedia.org/wiki/Longitude
        coordinateSpan.latitudeDelta = 3.0 / kilometersPerOneDegreeOfLatitude;
        coordinateSpan.longitudeDelta = mapKilometers / (mapScalingFactor * kilometersPerOneDegreeOfLatitude);
        MKCoordinateRegion mapRegion;
        mapRegion.center = currentUserLocation.coordinate;
        mapRegion.span = coordinateSpan;
        [self setRegion:mapRegion animated:animated];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

#warning - TODO: Test whether this method works
- (void)moveCenterPointToLocation:(CLLocation *)location animated:(BOOL)animated
{
    @try {
        CLLocation *currentUserLocation;
        if (location != nil) {
            currentUserLocation = location;
        } else {
            TAKAppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
            CLLocation *lastLocation = myAppDelegate.locationController.lastKnownLocation;
            if (self.userLocation.location != nil) { // Use the location that was provided my the MapKit
                currentUserLocation = self.userLocation.location;
            } else if (lastLocation != nil) { // Use the last known location (if available)
                currentUserLocation = lastLocation;
            } else { // The location is unknown; the code below sets the location to San Francisco
                currentUserLocation = [[CLLocation alloc] initWithLatitude:37.781516 longitude:-122.404955];
            }
        }
        
        // Zoom to the current location
        MKCoordinateSpan coordinateSpan;
        double mapKilometers = 3.0;
        double mapScalingFactor = ABS(cos(M_PI * 2 * currentUserLocation.coordinate.latitude / 360.0));
        double kilometersPerOneDegreeOfLatitude = 111.0; // Approximately; http://en.wikipedia.org/wiki/Longitude
        coordinateSpan.latitudeDelta = 3.0 / kilometersPerOneDegreeOfLatitude;
        coordinateSpan.longitudeDelta = mapKilometers / (mapScalingFactor * kilometersPerOneDegreeOfLatitude);
        MKCoordinateRegion mapRegion;
        mapRegion.center = currentUserLocation.coordinate;
        mapRegion.span = coordinateSpan;
        [self setRegion:mapRegion animated:animated];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

- (BOOL)setDefaultMapProperties
{
    @try {
        if (!self.mapProperties) {
            self.mapProperties = [NSMutableDictionary new];
        }
        [self.mapProperties setObject:@"Standard" forKey:@"mapType"];
        [self.mapProperties setObject:@"None" forKey:@"userTrackingMode"];
        self.mapType = MKMapTypeStandard;
        self.userTrackingMode = MKUserTrackingModeNone;
        return YES;
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        return NO;
    }
}

#pragma mark - Read from and write to the MapPropertyList file

- (void)readMapPropertiesFromPlistFile
{
    @try {
        NSString *mapPropertyListFilePath = [[NSBundle mainBundle] pathForResource:@"MapPropertyList" ofType:@"plist"];
        self.mapProperties = [[NSMutableDictionary alloc] initWithContentsOfFile:mapPropertyListFilePath];
        
        // The plist file cannot be read or it does not contain a dictionary
        if (!self.mapProperties) {
            [self setDefaultMapProperties];
            return;
        }
        
        NSString *mapTypeProperty = [self.mapProperties objectForKey:@"mapType"];
        if ([mapTypeProperty isEqualToString:@"Standard"]) {
            self.mapType = MKMapTypeStandard;
        } else if ([mapTypeProperty isEqualToString:@"Satellite"]) {
            self.mapType = MKMapTypeSatellite;
        } else {
            self.mapType = MKMapTypeHybrid;
        }
        
        NSString *userTrackingModeProperty = [self.mapProperties objectForKey:@"userTrackingMode"];
        if ([userTrackingModeProperty isEqualToString:@"None"]) {
            self.userTrackingMode = MKUserTrackingModeNone;
        } else if ([userTrackingModeProperty isEqualToString:@"Follow"]) {
            self.userTrackingMode = MKUserTrackingModeFollow;
        } else {
            self.userTrackingMode = MKUserTrackingModeFollowWithHeading;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        [self setDefaultMapProperties];
    }
}

- (void)writeMapPropertiesToPlistFile
{
    @try {
        NSError *error;
        NSString *mapPropertyListFilePath = [[NSBundle mainBundle] pathForResource:@"MapPropertyList" ofType:@"plist"];
        NSFileManager *myFileManager = [NSFileManager defaultManager];
        
        if ([myFileManager isWritableFileAtPath:mapPropertyListFilePath]) {
            NSMutableDictionary *mapPropertyDictionary = [[NSMutableDictionary alloc] initWithContentsOfFile:mapPropertyListFilePath];
            if (!mapPropertyDictionary) {
                mapPropertyDictionary = [NSMutableDictionary new];
            }
            [mapPropertyDictionary setObject:[self.mapProperties objectForKey:@"mapType"] forKey:@"mapType"];
            [mapPropertyDictionary setObject:[self.mapProperties objectForKey:@"userTrackingMode"] forKey:@"userTrackingMode"];
            [mapPropertyDictionary writeToFile:mapPropertyListFilePath atomically:YES];
            [myFileManager setAttributes:[NSDictionary dictionaryWithObject:[NSDate date] forKey:NSFileModificationDate] ofItemAtPath:mapPropertyListFilePath error:&error];
            
            if (error != nil) {
                NSLog(@"%@", error.description);
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

#pragma mark - Map view delegate methods

/*
 - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
 {
 
 }
 
 - (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)annotationView didChangeDragState:(MKAnnotationViewDragState)newState fromOldState:(MKAnnotationViewDragState)oldState
 {
 
 }
 
 - (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
 {
 
 }
 
 - (void)mapView:(MKMapView *)mapView didAddOverlayViews:(NSArray *)overlayViews
 {
 
 }
 */
- (void)mapView:(MKMapView *)mapView didChangeUserTrackingMode:(MKUserTrackingMode)mode animated:(BOOL)animated
{
    
}
/*
 - (void)mapView:(MKMapView *)mapView didDeselectAnnotationView:(MKAnnotationView *)view
 {
 
 }
 
 - (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
 {
 
 }
 
 - (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
 {
 
 }
 
 - (void)mapView:(MKMapView *)mapView didUpdateUserLocation:(MKUserLocation *)userLocation
 {
 
 }
 
 - (void)mapView:(MKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
 {
 
 }
 
 - (void)mapView:(MKMapView *)mapView regionWillChangeAnimated:(BOOL)animated
 {
 
 }
 */
/*
 - (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
 {
 
 }
 
 - (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay
 {
 
 }
 */
/*
 - (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
 {
 
 }
 
 - (void)mapViewDidFinishLoadingMap:(MKMapView *)mapView
 {
 
 }
 
 - (void)mapViewDidStopLocatingUser:(MKMapView *)mapView
 {
 
 }
 
 - (void)mapViewWillStartLoadingMap:(MKMapView *)mapView
 {
 
 }
 
 - (void)mapViewWillStartLocatingUser:(MKMapView *)mapView
 {
 
 }
 */

@end
