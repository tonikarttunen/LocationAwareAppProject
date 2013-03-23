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
// #import "TAKViewController.h"

@class TAKViewController;

@interface TAKAppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;

@property (strong, nonatomic) TAKViewController *viewController;
@property (strong, nonatomic) TAKLocationController *locationController;

@end
