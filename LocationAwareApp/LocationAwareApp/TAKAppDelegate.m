//
//  TAKAppDelegate.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/20/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKAppDelegate.h"

// #import "TAKViewController.h"
#import "TAKMainMenuViewController.h"

@implementation TAKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.
    self.mainMenuViewController = [TAKMainMenuViewController new];
    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[TAKViewController alloc] init];
        // self.viewController = [[TAKViewController alloc] initWithNibName:@"TAKViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[TAKViewController alloc] initWithNibName:@"TAKViewController_iPad" bundle:nil];
    }
    */
    self.window.backgroundColor = [UIColor blackColor];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainMenuViewController];
    self.navigationController.navigationBar.tintColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.5 alpha:1.0];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    self.locationController = [[TAKLocationController alloc] init];
    
#warning Read the correct value from NSUserDefaults
    self.isRegionMonitoringActive = NO;
    
    // Region monitoring test
    /*
    CLRegion *region = [[CLRegion alloc] initCircularRegionWithCenter:CLLocationCoordinate2DMake(60, 60) radius:150 identifier:@"Region monitoring test"];
    BOOL success = [self.locationController enableRegionMonitoringForRegion:region identifier:region.identifier];
    NSLog(@"Region monitoring %@", (success ? @"enabled" : @"not supported"));
    if (success) {
        BOOL anotherSuccess = [self.locationController disableRegionMonitoringForRegion:region identifier:region.identifier];
        NSLog(@"Stopping monitoring %@", (anotherSuccess ? @"works" : @"does not work"));
    }
    */
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    if (self.locationController && (!self.isRegionMonitoringActive)) {
        [self.locationController disableLocationManager];
    }
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later. 
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
#warning Save the value of the isRegionMonitoringActive property to NSUserDefaults
    if (self.locationController && (!self.isRegionMonitoringActive)) {
        [self.locationController disableLocationManager];
    }
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    if (self.locationController) {
        [self.locationController enableLocationManager];
    }
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    if (self.locationController) {
        [self.locationController enableLocationManager];
    }
}

- (void)applicationWillTerminate:(UIApplication *)application
{
#warning Save the value of the isRegionMonitoringActive property to NSUserDefaults
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    if (self.locationController && (!self.isRegionMonitoringActive)) {
        [self.locationController disableLocationManager];
    }
}

@end
