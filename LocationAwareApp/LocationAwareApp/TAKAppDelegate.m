//
//  TAKAppDelegate.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/20/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKAppDelegate.h"
#import "TAKMainMenuViewController.h"
#import "TAKFoursquareLocalSearchResultsViewController.h"
#import "BZFoursquare.h"
#ifdef TAK_GOOGLE
#import <GoogleMaps/GoogleMaps.h>
#import "APIConstants.h"
#endif

@implementation TAKAppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    // Override point for customization after application launch.

    /*
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        self.viewController = [[TAKViewController alloc] init];
        // self.viewController = [[TAKViewController alloc] initWithNibName:@"TAKViewController_iPhone" bundle:nil];
    } else {
        self.viewController = [[TAKViewController alloc] initWithNibName:@"TAKViewController_iPad" bundle:nil];
    }
    */
    
#if defined TAK_FOURSQUARE
    NSLog(@"Running the Foursquare version of the app...");
    self.currentInformationSource = TAKInformationSourceTypeFoursquare;
#elif defined TAK_GOOGLE
    NSLog(@"Running the Google version of the app...");
    [GMSServices provideAPIKey:TAK_GOOGLE_MAPS_API_KEY];
    self.currentInformationSource = TAKInformationSourceTypeGoogle;
    // NSLog(@"%@", [GMSServices openSourceLicenseInfo]);
#elif defined TAK_APPLE
    NSLog(@"Running the Apple version of the app...");
    self.currentInformationSource = TAKInformationSourceTypeApple;
#endif
    
//    // Read the value of the location data provider from the standard user defaults
//    NSLog(@"Reading the value of the location data provider from the standard user defaults...");
//    @try {
//        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//        id infoSource = [userDefaults objectForKey:@"InformationSource"];
//        if ((infoSource != nil) && [infoSource isKindOfClass:[NSNumber class]]) { // a previous info source value exists
//            NSUInteger infoSourceValue = (NSUInteger)[infoSource integerValue];
//            self.currentInformationSource = infoSourceValue;
//            NSLog(@"Current information source: %i", self.currentInformationSource);
//        } else {
//            [userDefaults setValue:[NSNumber numberWithInt:0] forKey:@"InformationSource"]; // Apple
//            NSLog(@"The value of the information source did not exist in the standard user defaults."
//                  @" Setting the value as TAKInformationSourceTypeApple.");
//        }
//    }
//    @catch (NSException *exception) {
//        self.currentInformationSource = TAKInformationSourceTypeApple;
//        NSLog(@"%@", exception.description);
//    }
    
    self.mainMenuViewController = [TAKMainMenuViewController new];
    
    self.window.backgroundColor = [UIColor blackColor];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:self.mainMenuViewController];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"NavBar" ofType:@"png"];
    UIImage *navBarImage = [[UIImage alloc] initWithContentsOfFile:path];
    NSString *path2 = [[NSBundle mainBundle] pathForResource:@"TopGradient" ofType:@"png"];
    UIImage *navBarShadowImage = [[UIImage alloc] initWithContentsOfFile:path2];
    [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:0.251 green:0.573 blue:0.8 alpha:1.0]];
    [[UINavigationBar appearance] setBackgroundImage:navBarImage forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:navBarShadowImage];
    [[UIToolbar appearance] setShadowImage:navBarShadowImage forToolbarPosition:UIToolbarPositionAny];
    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    self.locationController = [[TAKLocationController alloc] init];
    self.foursquareController = [[TAKFoursquareController alloc] init];
    
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
    
    // Save the value of the location data provider to the standard user defaults
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger infoSource = (NSInteger)self.currentInformationSource;
        [userDefaults setObject:[NSNumber numberWithInteger:infoSource] forKey:@"InformationSource"];
        [userDefaults synchronize];
        NSLog(@"applicationDidEnterBackground, infoSource: %i", infoSource);
    }
    @catch (NSException *exception) {
        self.currentInformationSource = TAKInformationSourceTypeApple;
        NSLog(@"%@", exception.description);
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

#pragma mark - Foursquare URL callback handling and successful authorization handling

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation {
    @try {
        // UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        // TAKFoursquareLocalSearchResultsViewController *foursquareViewController = [navigationController.viewControllers objectAtIndex:1];
        BZFoursquare *foursquare = self.foursquareController.foursquare;
        return [foursquare handleOpenURL:url];
    }
    @catch (NSException *exception) {
        // NSLog(@"Cannot Open the Foursquare View. %@.", exception.description);
        NSLog(@"Foursquare authorization problem: %@.", exception.description);
        // UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Open the Foursquare View" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Foursquare Authorization Error" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
}

- (BOOL)handleSuccessfulFoursquareAuthorization
{
    @try {
        UINavigationController *navigationController = (UINavigationController *)self.window.rootViewController;
        if (navigationController == nil) {
            return NO;
        }
        if (navigationController.viewControllers.count < 2) {
            NSLog(@"Foursquare view controller does not exist!");
            return NO;
        }
        TAKFoursquareLocalSearchResultsViewController *foursquareViewController = [navigationController.viewControllers objectAtIndex:1];
        if (foursquareViewController == nil) {
            return NO;
        } else if ([foursquareViewController respondsToSelector:@selector(generateInitialUI)]
                   && (foursquareViewController.foursquareAuthorizationView != nil)) {
//            [foursquareViewController.foursquareAuthorizationView removeFromSuperview];
//            [foursquareViewController generateInitialUI];
            [foursquareViewController generateInitialUI];
            return YES;
        } else {
            return NO;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot Open the Foursquare View. %@.", exception.description);
        UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Cannot Open the Foursquare View" message:@"" delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil];
        [alertView show];
        return NO;
    }
}

@end
