//
//  TAKMapController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/23/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import "TAKMapView.h"

@interface TAKMapController : NSObject <MKMapViewDelegate>

@property (nonatomic, strong) TAKMapView *mapView;
@property (nonatomic, strong) NSDictionary *mapProperties;

// - (id)initWithFrame:(CGRect)frame;
- (void)moveCenterPointToLocation:(CLLocation *)location animated:(BOOL)animated;
- (void)moveCenterPointToCurrentLocationAnimated:(BOOL)animated;
- (void)readMapPropertiesFromPlistFile;


@end
