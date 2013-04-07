//
//  TAKMapView.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/23/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKMapView.h"

#define TAK_MAP_ANNOTATION_IDENTIFIER   @"TAK_MAP_ANNOTATION_IDENTIFIER"

//@interface TAKMapView ()
//
//@property (nonatomic, strong) MKLocalSearch *localSearch;
//@property (nonatomic, strong) MKLocalSearchResponse *localSearchResponse;
//
//@end

@implementation TAKMapView

#pragma mark - Lifecycle methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        // self.localSearchResponse = [[MKLocalSearchResponse alloc] init];
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
    self.delegate = nil;
    self.mapProperties = nil;
//    if (self.localSearch.isSearching) {
//        [self.localSearch cancel];
//    }
//    self.localSearch = nil;
//    self.localSearchResponse = nil;
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
        CLLocation *lastLocation;
        if (myAppDelegate != nil) {
            lastLocation = myAppDelegate.locationController.lastKnownLocation;
        }
        
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
        double mapKilometers = 10.0;
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
            CLLocation *lastLocation;
            if (myAppDelegate != nil) {
                lastLocation = myAppDelegate.locationController.lastKnownLocation;
            }
            
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

- (void)refreshMapAnnotationsWithArray:(NSArray *)array
{
    @try {
        if ((self.annotations != nil) && (self.annotations.count > 0)) {
            [self removeAnnotations:self.annotations];
        }

        if ((array != nil) && (array.count > 0)) {
            for (int i = 0; i < array.count; i++) {
                MKMapItem *mapItem = [array objectAtIndex:i];
                MKPlacemark *placemark = mapItem.placemark;
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                annotation.coordinate = placemark.coordinate;
                annotation.title = mapItem.name;
                NSLog(@"Annotation title: %@", annotation.title);
                annotation.subtitle = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
                [self addAnnotation:annotation];
                
                if (i == 0) {
                    [self selectAnnotation:annotation animated:YES];
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot refresh map annotations: %@. %@.", exception.description, exception.reason);
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
*/

//- (void)mapView:(MKMapView *)mapView didAddAnnotationViews:(NSArray *)views
//{
//    [mapView selectAnnotation:[[mapView annotations] lastObject] animated:NO];
//}

/*
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
*/
- (void)mapView:(MKMapView *)mapView didFailToLocateUserWithError:(NSError *)error
{
#ifdef DEBUG
    NSLog(@"Map view did fail locating the user with error: %@.", [error description]);
#endif
}

- (void)mapViewDidFailLoadingMap:(MKMapView *)mapView withError:(NSError *)error
{
#warning TODO: Show a message to the user
//    UIAlertView *mapAlert = [[UIAlertView alloc] initWithTitle:@"Cannot Load Map Data" message:[error description] delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
//    [mapAlert show];
    
#ifdef DEBUG
    NSLog(@"Cannot Load Map Data: %@", [error description]);
#endif
}

/*
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

//- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id < MKAnnotation >)annotation
//{
//    MKPinAnnotationView *pinAnnotationView;
//    
////    if (annotation != mapView.userLocation) {
////        pinAnnotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TAK_MAP_ANNOTATION_IDENTIFIER];
////        if (!pinAnnotationView) {
////            pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TAK_MAP_ANNOTATION_IDENTIFIER];
////            
////        }
////    }
//    
//    if ([annotation isKindOfClass:[MKUserLocation class]]) {
//        return nil;
//    }
//    
//    if (!pinAnnotationView) {
//        pinAnnotationView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:TAK_MAP_ANNOTATION_IDENTIFIER];
//        pinAnnotationView.pinColor = MKPinAnnotationColorGreen;
//        pinAnnotationView.animatesDrop = YES;
//        pinAnnotationView.canShowCallout = YES;
//        
//        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
//        pinAnnotationView.rightCalloutAccessoryView = rightButton;
//    } else {
//        pinAnnotationView.annotation = annotation;
//    }
//    
//    return pinAnnotationView;
//}

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation {
    MKPinAnnotationView *pinView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:TAK_MAP_ANNOTATION_IDENTIFIER];
    if (!pinView) {
        if ([annotation isKindOfClass:[MKUserLocation class]]) {
            return nil;
        }
        pinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                  reuseIdentifier:TAK_MAP_ANNOTATION_IDENTIFIER];
        pinView.pinColor = MKPinAnnotationColorRed;
        pinView.animatesDrop = YES;
        pinView.canShowCallout = YES;
        
        UIButton *rightButton = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        // rightButton.accessibilityHint = [@"More information about " stringByAppendingString:annotation.title];
//        if ([annotation.title isEqual: MANHATTAN_OFFICE]) {
//            rightButton.accessibilityHint = @"View more information about the New York office";
//        }
//        else if ([annotation.title isEqual: COPENHAGEN_OFFICE]) {
//            rightButton.accessibilityHint = @"View more information about the Copenhagen office";
//        }
//        else {
//            rightButton.accessibilityHint = @"View more information about the London office";
//        }
        pinView.rightCalloutAccessoryView = rightButton;
    } else {
        pinView.annotation = annotation;
    }
    return pinView;
}

/*
 - (MKOverlayView *)mapView:(MKMapView *)mapView viewForOverlay:(id < MKOverlay >)overlay
 {
 
 }
 */
/*
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

#pragma mark - Local search
/*
- (void)performLocalSearchWithString:(NSString *)searchString
{
    NSLog(@"Search string: %@", searchString);
//    if (self.localSearch) {
//        [self.localSearch cancel];
//    }
    
    MKLocalSearchRequest *localSearchRequest = [MKLocalSearchRequest new];
    NSLog(@"Region: lat. %f, long. %f.",
          self.region.center.latitude,
          self.region.center.longitude);
    localSearchRequest.region = self.region;
    localSearchRequest.naturalLanguageQuery = searchString;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:localSearchRequest];
    
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (error != nil) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Search Failed"
//                                       message:error.description
//                                      delegate:self
//                             cancelButtonTitle:@"Dismiss"
//                             otherButtonTitles: nil];
//            [alert show];
            NSLog(@"Local search failed: %@", error.description);
            return;
        }
        
        if (response.mapItems.count == 0) {
//            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Search Results"
//                                                            message:nil
//                                                           delegate:self
//                                                  cancelButtonTitle:@"OK"
//                                                  otherButtonTitles: nil];
//            [alert show];
#if DEBUG
            NSLog(@"No local search results for place: lat. %f, long. %f.",
                  self.region.center.latitude,
                  self.region.center.longitude);
#endif
            return;
        }
        NSLog(@"%@", response.mapItems.description);
        self.localSearchResponse = response;
        [self refreshMapAnnotations];
    }];
}
*/

@end
