//
//  TAKAppDelegate.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/20/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "TAKLocationController.h"
#import "TAKFoursquareController.h"

@class TAKMainMenuViewController;

@interface TAKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) TAKMainMenuViewController *mainMenuViewController;
@property (strong, nonatomic) TAKLocationController *locationController;
@property (strong, nonatomic) TAKFoursquareController *foursquareController;
@property (setter = setRegionMonitoringActive:) BOOL isRegionMonitoringActive;
@property NSUInteger currentInformationSource;

- (BOOL)handleSuccessfulFoursquareAuthorization;

@end
