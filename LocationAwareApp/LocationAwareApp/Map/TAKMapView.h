//
//  TAKMapView.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/23/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "TAKAppDelegate.h"

@interface TAKMapView : MKMapView <MKMapViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong) NSMutableDictionary *mapProperties;
@property BOOL isLocationAlreadyKnown;

- (void)moveCenterPointToLocation:(CLLocation *)location animated:(BOOL)animated;
- (void)moveCenterPointToCurrentLocationAnimated:(BOOL)animated;
- (void)readMapPropertiesFromPlistFile;
- (void)writeMapPropertiesToPlistFile;
- (void)performLocalSearchWithString:(NSString *)searchString;
- (void)refreshMapAnnotations;

@end
