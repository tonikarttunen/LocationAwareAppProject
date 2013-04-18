//
//  TAKMapView.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/23/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKMapView.h"
#import "Constants.h"
#import "TAKDetailViewController.h"
#import "UIView+FindNextViewController.h"

#define TAK_MAP_ANNOTATION_IDENTIFIER   @"TAK_MAP_ANNOTATION_IDENTIFIER"

@interface TAKMapView ()

// @property (nonatomic, strong) NSMutableArray *mapItems;

@end

@implementation TAKMapView

#pragma mark - Lifecycle methods

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _informationSourceType = 0;
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
        _mapItems = [NSMutableArray new];
    }
    return self;
}

- (void)dealloc
{
    self.delegate = nil;
    _mapProperties = nil;
    _mapItems = nil;
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
        } else { // The location is unknown; the code below sets the location to Helsinki downtown
            currentUserLocation = [[CLLocation alloc] initWithLatitude:60.168824 longitude:24.942422];
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
            CLLocation *lastLocation;
            if (myAppDelegate != nil) {
                lastLocation = myAppDelegate.locationController.lastKnownLocation;
            }
            
            if (self.userLocation.location != nil) { // Use the location that was provided my the MapKit
                currentUserLocation = self.userLocation.location;
            } else if (lastLocation != nil) { // Use the last known location (if available)
                currentUserLocation = lastLocation;
            } else { // The location is unknown; the code below sets the location to Helsinki downtown 
                currentUserLocation = [[CLLocation alloc] initWithLatitude:60.168824 longitude:24.942422];
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

#pragma mark - Refresh the map annotations

- (void)refreshMapAnnotationsWithArray:(NSArray *)array informationSource:(NSUInteger)informationSource
{
    @try {
        if ((self.annotations != nil) && (self.annotations.count > 0)) {
            [self removeAnnotations:self.annotations];
            NSLog(@"ARRAY: %@", array);
            self.mapItems = (NSMutableArray *)array;
            NSLog(@"SELF.MAPITEMS: %@", self.mapItems);
        }

        if ((array != nil) && (array.count > 0)) {
            for (int i = 0; i < array.count; i++) {
                MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
                
                switch (informationSource) {
                    case TAKInformationSourceTypeApple: {
                        MKMapItem *mapItem = [array objectAtIndex:i];
                        MKPlacemark *placemark = mapItem.placemark;
                        annotation.coordinate = placemark.coordinate;
                        annotation.title = mapItem.name;
                        NSLog(@"Annotation title: %@", annotation.title);
                        annotation.subtitle = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
                        [self addAnnotation:annotation];
                        break;
                    }
                        
                    case TAKInformationSourceTypeFoursquare: {
                        NSArray *locationData = [[array objectAtIndex:i] objectForKey:TAK_FOURSQUARE_LOCATION];
                        NSArray *basicInformation = [[array objectAtIndex:i] objectForKey:TAK_FOURSQUARE_BASIC_INFORMATION];
                        
                        CLLocationDegrees latitude = (CLLocationDegrees)[[[locationData objectAtIndex:0] objectAtIndex:1] doubleValue];
                        CLLocationDegrees longtitude = (CLLocationDegrees)[[[locationData objectAtIndex:1] objectAtIndex:1] doubleValue];
                        annotation.coordinate = CLLocationCoordinate2DMake(latitude, longtitude);
                        annotation.title = (NSString *)[[basicInformation objectAtIndex:0] objectAtIndex:1];
                        annotation.subtitle = (NSString *)[[locationData objectAtIndex:3] objectAtIndex:1];
                        [self addAnnotation:annotation];
                        break;
                    }
                        
                    default:
                        break;
                }
#ifdef DEBUG
                NSLog(@"Annotation title: %@, subtitle: %@, lat: %f, long: %f",
                      annotation.title, annotation.subtitle,
                      annotation.coordinate.latitude, annotation.coordinate.longitude);
#endif
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

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    @try {
        NSMutableArray *detailViewContents = [NSMutableArray new];
        NSDictionary *dictionary;
        
        switch (self.informationSourceType) {
            case TAKInformationSourceTypeApple: {
                MKMapItem *mapItem;
                NSLog(@"SELF.MAPITEMS: %@", self.mapItems);
                for (int i = 0; i < self.mapItems.count; i++) {
                    id obj = [self.mapItems objectAtIndex:i];
                    if (([obj isKindOfClass:[MKMapItem class]]) && ([view.annotation.title isEqual:[obj name]])) {
                        mapItem = (MKMapItem *)obj;
                        
                        NSString *name = mapItem.name;
                        NSString *address = ABCreateStringWithAddressDictionary(mapItem.placemark.addressDictionary, YES);
                        NSString *phone = mapItem.phoneNumber;
                        NSURL *url = mapItem.url;
                        NSString *latitude = [[NSString alloc] initWithFormat:@"%f", mapItem.placemark.coordinate.latitude];
                        NSString *longitude = [[NSString alloc] initWithFormat:@"%f", mapItem.placemark.coordinate.longitude];
                        if (name != nil) {
                            [detailViewContents addObject:@[@"Name", name]];
                        }
                        if (address != nil) {
                            [detailViewContents addObject:@[@"Address", address]];
                        }
                        if (phone != nil) {
                            [detailViewContents addObject:@[@"Phone", phone]];
                        }
                        if (url != nil) {
                            [detailViewContents addObject:@[@"URL", url]];
                        }
                        if (latitude != nil) {
                            [detailViewContents addObject:@[@"Latitude", latitude]];
                        }
                        if (longitude != nil) {
                            [detailViewContents addObject:@[@"Longitude", longitude]];
                        }
                        break;
                    }
                }
                NSLog(@"DETAIL VIEW CONTENTS: %@", detailViewContents);
                break;
            }
                
            case TAKInformationSourceTypeFoursquare: {
                for (int i = 0; i < self.mapItems.count; i++) {
                    id obj = [self.mapItems objectAtIndex:i];
                    if ([obj isKindOfClass:[NSDictionary class]]) {
                        NSArray *basicInformation = [obj objectForKey:TAK_FOURSQUARE_BASIC_INFORMATION];
                        NSString *annotationTitle = (NSString *)[[basicInformation objectAtIndex:0] objectAtIndex:1];
                        if ([view.annotation.title isEqual:annotationTitle]) {
                            dictionary = (NSDictionary *)obj;
                            break;
                        }
                    }
                }
                break;
            }
                
            default:
                break;
        }
        
        TAKDetailViewController *DVC;
        switch (self.informationSourceType) {
            case TAKInformationSourceTypeFoursquare: {
                DVC = [[TAKDetailViewController alloc] initWithStyle:UITableViewStyleGrouped
                                          tableViewContentDictionary:dictionary
                                               informationSourceType:TAKInformationSourceTypeFoursquare];
                break;
            }
            default: {
                DVC = [[TAKDetailViewController alloc] initWithStyle:UITableViewStylePlain
                                                   tableViewContents:(NSArray *)detailViewContents
                                               informationSourceType:self.informationSourceType];
                break;
            }
        }
        DVC.title = view.annotation.title;
        UIViewController *viewController = [self findParentViewController];
        [viewController.navigationController pushViewController:DVC animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot present TAKDetailViewController: %@", exception.description);
    }
}

/*
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
        rightButton.accessibilityHint = annotation.title;
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

@end
