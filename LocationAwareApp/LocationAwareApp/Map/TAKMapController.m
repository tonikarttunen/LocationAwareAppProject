//
//  TAKMapController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/23/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKMapController.h"
#import "TAKAppDelegate.h"

@implementation TAKMapController

#pragma mark - Lifecycle methods

- (id)init
{
    self = [super init];
    if (self) {
        // self.mapView = [[TAKMapView alloc] init];
        // self.mapView.delegate = self;
        // [self readPreviousMapPropertiesFromPlistFile];
        // [self moveCenterPointToCurrentLocationAnimated:YES];
        
        
    }
    return self;
}

- (void)dealloc
{
    self.mapView = nil;
    self.mapProperties = nil;
}

#pragma mark - Map

- (void)moveCenterPointToCurrentLocationAnimated:(BOOL)animated
{
    @try {
        CLLocation *currentUserLocation;
        
        TAKAppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
        CLLocation *lastLocation = myAppDelegate.locationController.lastKnownLocation;
        if (self.mapView.userLocation.location != nil) { // Use the location that was provided my the MapKit
            currentUserLocation = self.mapView.userLocation.location;
        } else if (lastLocation != nil) { // Use the last known location (if available)
            currentUserLocation = lastLocation;
        } else { // The location is unknown; the code below sets the location to San Francisco
            currentUserLocation = [[CLLocation alloc] initWithLatitude:37.781516 longitude:-122.404955];
        }
        
        // Zoom to the current user location
        MKCoordinateSpan coordinateSpan;
        double mapKilometers = 3.0;
        double mapScalingFactor = ABS(cos(M_PI * 2 * currentUserLocation.coordinate.latitude / 360.0));
        double kilometersPerOneDegreeOfLatitude = 111.0; // Approximately; http://en.wikipedia.org/wiki/Longitude
        coordinateSpan.latitudeDelta = 3.0 / kilometersPerOneDegreeOfLatitude;
        coordinateSpan.longitudeDelta = mapKilometers / (mapScalingFactor * kilometersPerOneDegreeOfLatitude);
        MKCoordinateRegion mapRegion;
        mapRegion.center = currentUserLocation.coordinate;
        mapRegion.span = coordinateSpan;
        [self.mapView setRegion:mapRegion animated:animated];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

- (void)moveCenterPointToLocation:(CLLocation *)location animated:(BOOL)animated
{
    CLLocation *currentUserLocation;
    if (location != nil) {
        currentUserLocation = location;
    } else {
        TAKAppDelegate *myAppDelegate = [[UIApplication sharedApplication] delegate];
        CLLocation *lastLocation = myAppDelegate.locationController.lastKnownLocation;
        if (self.mapView.userLocation.location != nil) { // Use the location that was provided my the MapKit
            currentUserLocation = self.mapView.userLocation.location;
        } else if (lastLocation != nil) { // Use the last known location (if available)
            currentUserLocation = lastLocation;
        } else { // The location is unknown; the code below sets the location to San Francisco
            currentUserLocation = [[CLLocation alloc] initWithLatitude:37.781516 longitude:-122.404955];
        }
    }
    
    // Zoom to the current user location
    MKCoordinateSpan coordinateSpan;
    double mapKilometers = 3.0;
    double mapScalingFactor = ABS(cos(M_PI * 2 * currentUserLocation.coordinate.latitude / 360.0));
    double kilometersPerOneDegreeOfLatitude = 111.0; // Approximately; http://en.wikipedia.org/wiki/Longitude
    coordinateSpan.latitudeDelta = 3.0 / kilometersPerOneDegreeOfLatitude;
    coordinateSpan.longitudeDelta = mapKilometers / (mapScalingFactor * kilometersPerOneDegreeOfLatitude);
    MKCoordinateRegion mapRegion;
    mapRegion.center = currentUserLocation.coordinate;
    mapRegion.span = coordinateSpan;
    [self.mapView setRegion:mapRegion animated:animated];
}

#pragma mark - Read from and write to the MapPropertyList file

- (void)readMapPropertiesFromPlistFile
{
    @try {
        NSString *mapPropertyListFilePath = [[NSBundle mainBundle] pathForResource:@"MapPropertyList" ofType:@"plist"];
        self.mapProperties = [[NSDictionary alloc] initWithContentsOfFile:mapPropertyListFilePath];
        
        NSString *mapTypeProperty = [self.mapProperties objectForKey:@"currentMapType"];
        if ([mapTypeProperty isEqualToString:@"Standard"]) {
            self.mapView.mapType = MKMapTypeStandard;
        } else if ([mapTypeProperty isEqualToString:@"Satellite"]) {
            self.mapView.mapType = MKMapTypeSatellite;
        } else {
            self.mapView.mapType = MKMapTypeHybrid;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        self.mapView.mapType = MKMapTypeStandard;
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
