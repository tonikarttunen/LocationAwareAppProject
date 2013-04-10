//
//  TAKFoursquareController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/9/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKAppDelegate.h"
#import "TAKFoursquareController.h"
#import "TAKFoursquareLocalSearchResultsViewController.h"
#import "TAKFoursquareAuthorizationView.h"
#import "APIConstants.h"

#define TAK_VENUE_ID                @"venueID"
#define TAK_PRIVACY_SETTING_VALUE   @"broadcast"
#define TAK_ADD_CHECK_IN            @"checkins/add"
#define TAK_HTTP_GET                @"GET"
#define TAK_HTTP_POST               @"POST"

@interface TAKFoursquareController ()

@property (nonatomic, strong, readwrite) BZFoursquare *foursquare;
@property (nonatomic, strong) BZFoursquareRequest *foursquareRequest;
@property (nonatomic, copy, readwrite) NSDictionary *foursquareResponse;
@property (nonatomic, copy, readwrite) NSDictionary *foursquareMeta;
@property (nonatomic, copy, readwrite) NSArray *foursquareNotifications;
@property (nonatomic, strong, readwrite) TAKFoursquareDataController *foursquareDataController;

@end

//enum {
//    TAK_BZFoursquareAuthenticationSection = 0,
//    TAK_BZFoursquareEndpointsSection,
//    TAK_BZFoursquareResponsesSection,
//    TAK_BZFoursquareSectionCount
//};
//
//enum {
//    TAK_BZFoursquareAccessTokenRow = 0,
//    TAK_BZFoursquareAuthenticationRowCount
//};
//
//enum {
//    TAK_BZFoursquareSearchVenuesRow = 0,
//    TAK_BZFoursquareCheckInRow,
//    TAK_BZFoursquareAddPhotoRow,
//    TAK_BZFoursquareEndpointsRowCount
//};
//
//enum {
//    TAK_BZFoursquareMetaRow = 0,
//    TAK_BZFoursquareNotificationsRow,
//    TAK_BZFoursquareResponseRow,
//    TAK_BZFoursquareResponsesRowCount
//};

@implementation TAKFoursquareController

- (id)init
{
    self = [super init];
    if (self) {
        self.foursquare = [[BZFoursquare alloc] initWithClientID:TAK_FOURSQUARE_API_KEY callbackURL:TAK_FOURSQUARE_API_REDIRECT_URL];
        self.foursquare.locale = @"en";
        // NSLog(@"LOCALE: %@", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]);
        self.foursquare.version = @"20111119";
        self.foursquare.sessionDelegate = self;
    }
    return self;
}

- (void)dealloc
{
    _foursquare.sessionDelegate = nil;
    [self cancelFoursquareRequest];
    _foursquare = nil;
    _foursquareResponse = nil;
    _foursquareMeta = nil;
    _foursquareNotifications = nil;
    _foursquareDataController = nil;
}

#pragma mark - Request handling

- (void)cancelFoursquareRequest {
    if (self.foursquareRequest != nil) {
        self.foursquareRequest.delegate = nil;
        [self.foursquareRequest cancel];
        self.foursquareRequest = nil;
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    }
}

- (void)deleteOldFoursquareRequestData {
    [self cancelFoursquareRequest];
    self.foursquareMeta = nil;
    self.foursquareResponse = nil;
    self.foursquareNotifications = nil;
}

- (void)searchFoursquareContentWithPath:(NSString *)path
                       searchParameters:(NSDictionary *)searchParameters
{
    if ((path == nil) || (searchParameters == nil)) {
        NSLog(@"The search path or the search parameter dictionary is nil.");
        return;
    }

    [self deleteOldFoursquareRequestData];
    
    self.foursquareRequest = [self.foursquare requestWithPath:path
                                                   HTTPMethod:TAK_HTTP_GET
                                                   parameters:searchParameters
                                                     delegate:self];
    [self.foursquareRequest start];

#warning Potentially incomplete implementation
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)checkInToFoursquareVenueWithID:(NSString *)venueID
                   privacySettingValue:(NSString *)privacySettingValue
{
    if ((venueID == nil) || (privacySettingValue == nil)) {
        NSLog(@"The venue ID or the privacy setting value is nil.");
        return;
    }
    
    [self deleteOldFoursquareRequestData];
    
    NSDictionary *checkInParameters = @{TAK_VENUE_ID : venueID,
                                        TAK_PRIVACY_SETTING_VALUE : privacySettingValue};
    
    self.foursquareRequest = [self.foursquare requestWithPath:TAK_ADD_CHECK_IN
                                                   HTTPMethod:TAK_HTTP_POST
                                                   parameters:checkInParameters
                                                     delegate:self];
    [self.foursquareRequest start];
    
#warning Potentially incomplete implementation
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

#pragma mark - BZFoursquareSessionDelegate methods

//- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
//    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:TAK_BZFoursquareAccessTokenRow inSection:TAK_BZFoursquareAuthenticationSection];
//    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
//    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
//}

- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare
{
    @try {
        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (appDelegate && [appDelegate respondsToSelector:@selector(handleSuccessfulFoursquareAuthorization)]
            && appDelegate.locationController) {
            [appDelegate handleSuccessfulFoursquareAuthorization];
            NSLog(@"Foursquare authorization was successful.");
            
            CLLocation *location;
            NSString *locationString;
            if (appDelegate.locationController.lastKnownLocation != nil) {
                location = appDelegate.locationController.lastKnownLocation;
                double latitude = (double)location.coordinate.latitude;
                double longitude = (double)location.coordinate.longitude;
                locationString = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
            } else {
                locationString = @"60.168824,24.942422"; // Aleksanterinkatu 52, Helsinki, Finland
            }
            
            [self searchFoursquareContentWithPath:@"venues/search"
                                 searchParameters:[NSDictionary dictionaryWithObjectsAndKeys:locationString, @"ll", nil]];
        } else {
            NSLog(@"TAKAppDelegate does not respond to selector \"handleSuccessfulFoursquareAuthorization\"");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot update the Foursquare view. %@.", exception.description);
    }
}

- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo
{
    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authorization Failed" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//    [alertView show];
}


//- (void)checkInToFoursquarePlace {
//    [self prepareForFoursquareRequest];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"4d341a00306160fcf0fc6a88", @"venueId", @"public", @"broadcast", nil];
//    self.foursquareRequest = [self.foursquare requestWithPath:@"checkins/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
//    [self.foursquareRequest start];
//    [self updateView];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//}
//
//- (void)uploadPhotoToFoursquare {
//    [self prepareForFoursquareRequest];
//    NSURL *photoURL = [[NSBundle mainBundle] URLForResource:@"Icon" withExtension:@"png"];
//    NSData *photoData = [NSData dataWithContentsOfURL:photoURL];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:photoData, @"photo.jpg", @"4d341a00306160fcf0fc6a88", @"venueId", nil];
//    self.foursquareRequest = [self.foursquare requestWithPath:@"photos/add" HTTPMethod:@"POST" parameters:parameters delegate:self];
//    [self.foursquareRequest start];
//    [self updateView];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//}


#pragma mark - BZFoursquareRequestDelegate methods

- (void)requestDidStartLoading:(BZFoursquareRequest *)request
{
    NSLog(@"FoursquareRequest: didStartLoading.");
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
}

- (void)requestDidFinishLoading:(BZFoursquareRequest *)request
{
    NSLog(@"FoursquareRequest: didFinishLoading.");
    self.foursquareResponse = request.response;
    self.foursquareNotifications = request.notifications;
    self.foursquareMeta = request.meta;
    self.foursquareRequest = nil;
    
    self.foursquareDataController = [[TAKFoursquareDataController alloc] initWithFoursquareData:self.foursquareResponse];
    
    @try {
        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        
        if ((appDelegate == nil) || (appDelegate.window == nil)
            || (appDelegate.window.rootViewController == nil)) {
            return;
        }
        
        UINavigationController *navigationController = (UINavigationController *)appDelegate.window.rootViewController;
        
        if (navigationController == nil) {
            return;
        }
        
        TAKFoursquareLocalSearchResultsViewController *foursquareViewController = [navigationController.viewControllers objectAtIndex:1];
        
        if (foursquareViewController == nil) {
            return;
        } else if ([foursquareViewController respondsToSelector:@selector(updateUI)]) {
            [foursquareViewController updateUI];
        }
#if DEBUG
        // NSLog(@"Response: %@\nMeta: %@\nNotifications: %@",
        //      self.foursquareResponse, self.foursquareMeta, self.foursquareNotifications);
#endif
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot update the Foursquare view. %@.", exception.description);
    }
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
    
}

- (void)request:(BZFoursquareRequest *)request didFailWithError:(NSError *)error
{
    NSLog(@"FoursquareRequest: didFailWithError.");
    self.foursquareResponse = request.response;
    self.foursquareNotifications = request.notifications;
    self.foursquareMeta = request.meta;
    self.foursquareRequest = nil;
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
}

@end
