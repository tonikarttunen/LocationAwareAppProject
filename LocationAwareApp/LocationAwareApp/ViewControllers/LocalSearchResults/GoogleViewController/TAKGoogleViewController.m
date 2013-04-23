//
//  TAKGooglePlacesController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/18/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//


#import "TAKGoogleViewController.h"
#import <CoreLocation/CoreLocation.h>
#import "TAKAppDelegate.h"
#import "APIConstants.h"
// #import "TAKMapView.h"
#import "TAKSearchResultsTableView.h"
#import "TAKDetailViewController.h"
//#import <GoogleMaps/GoogleMaps.h>
//#ifdef TAK_GOOGLE
//#import <GoogleMaps/GoogleMaps.h>
//#endif

#define TAK_GOOGLE_PLACES_BASE_URL @"https://maps.googleapis.com/maps/api/place/nearbysearch/json?"

@interface TAKGoogleViewController ()

@property (nonatomic, strong) NSMutableDictionary *searchResponse;
@property (nonatomic, copy) NSString *category;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UISegmentedControl *mapTypeSegmentedControl;
@property (nonatomic, strong) GMSMapView *mapView;
@property (nonatomic, strong) TAKSearchResultsTableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

// - (void)searchNearbyGooglePlacesWithParameters:(NSDictionary *)parameters;

@end

@implementation TAKGoogleViewController

- (id)initWithCategory:(NSString *)category
{
    self = [super init];
    if (self) {
        _category = [category copy];
        
//        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//
//        CLLocation *location;
//        double latitude;
//        double longitude;
//        if (appDelegate && appDelegate.locationController.lastKnownLocation != nil) {
//            location = appDelegate.locationController.lastKnownLocation;
//            latitude = (double)location.coordinate.latitude;
//            longitude = (double)location.coordinate.longitude;
//        } else { // Aleksanterinkatu 52, Helsinki, Finland
//            latitude = 60.168824;
//            longitude = 24.942422;
//        }
//
//        [self searchNearbyGooglePlacesWithParameters:@{
//             @"Types" : [self googlePlaceTypeWithHumanReadableString:category],
//             @"Latitude" : [NSNumber numberWithDouble:latitude],
//             @"Longitude" : [NSNumber numberWithDouble:longitude],
//             @"Radius" : [NSNumber numberWithInt:3000]
//         }];
    }
    return self;
}

- (void)dealloc
{
    _searchResponse = nil;
    _category = nil;
    _toolbar = nil;
    _segmentedControl = nil;
    _mapTypeSegmentedControl = nil;
    _mapView.delegate = nil;
    _mapView = nil;
    _activityIndicatorView = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.tableView != nil) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = self.category;
    
    TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    
    CLLocation *location;
    double latitude;
    double longitude;
    
    switch (appDelegate.currentLocationType) {
        case TAKLocationTypeCurrentLocation: {
            if (appDelegate.locationController.lastKnownLocation != nil) {
                location = appDelegate.locationController.lastKnownLocation;
                latitude = (double)location.coordinate.latitude;
                longitude = (double)location.coordinate.longitude;
            } else { // Aleksanterinkatu 52, Helsinki, Finland
                latitude = 60.168824;
                longitude = 24.942422;
            }
            break;
        }
            
        case TAKLocationTypeOtaniemi: {
            latitude = TAK_OTANIEMI_LATITUDE;
            longitude = TAK_OTANIEMI_LONGITUDE;
            break;
        }
            
        case TAKLocationTypeSchonberg: {
            latitude = TAK_SCHONBERG_LATITUDE;
            longitude = TAK_SCHONBERG_LONGITUDE;
            break;
        }
            
        case TAKLocationTypePittsburgh: {
            latitude = TAK_PITTSBURGH_LATITUDE;
            longitude = TAK_PITTSBURGH_LONGITUDE;
            break;
        }
            
        default: {
            latitude = TAK_SUZHOU_LATITUDE;
            longitude = TAK_SUZHOU_LONGITUDE;
            break;
        }
    }
    
    [self searchNearbyGooglePlacesWithParameters:@{
         @"Types" : [self googlePlaceTypeWithHumanReadableString:self.category],
         @"Latitude" : [NSNumber numberWithDouble:latitude],
         @"Longitude" : [NSNumber numberWithDouble:longitude],
         @"Radius" : [NSNumber numberWithInt:3000]
     }];
    
    [self generateInitialUIWithLatitude:latitude longitude:longitude];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - UI

- (void)generateInitialUIWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
    [self setViewBasicProperties];
    [self generateToolbar];
    [self generateMapViewWithLatitude:latitude longitude:longitude];
    if (!self.activityIndicatorView) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}

- (void)setViewBasicProperties
{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.opaque = YES;
}

- (void)generateToolbar
{
    self.toolbar = [[UIToolbar alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, TAK_STANDARD_TOOLBAR_HEIGHT)];
    self.toolbar.tintColor = [UIColor colorWithRed:0.325 green:0.325 blue:0.325 alpha:1];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"ToolbarBackground" ofType:@"png"];
    UIImage *toolbarImage = [[UIImage alloc] initWithContentsOfFile:path];
    [self.toolbar setBackgroundImage:toolbarImage forToolbarPosition:UIToolbarPositionAny barMetrics:UIBarMetricsDefault];
    self.toolbar.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    self.toolbar.barStyle = UIBarStyleDefault;
    [self.view addSubview:self.toolbar];
    
    [self generateSegmentedControl];
    
    UIBarButtonItem *segmentedControlItem = [[UIBarButtonItem alloc] initWithCustomView:self.segmentedControl];
    UIBarButtonItem *flexibleSpaceItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:NULL];
    NSArray *toolbarItems = [[NSArray alloc] initWithObjects:flexibleSpaceItem, segmentedControlItem, flexibleSpaceItem, nil];
    [self.toolbar setItems:toolbarItems animated:NO];
}

- (void)generateSegmentedControl
{
    NSArray *segmentedControlItems = @[@"Map", @"List"];
    self.segmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
    self.segmentedControl.frame = CGRectMake(0.0f, 0.0f, TAK_SEGMENTED_CONTROL_WIDTH, TAK_SEGMENTED_CONTROL_HEIGHT);
    self.segmentedControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.segmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.segmentedControl.selectedSegmentIndex = 0;
    self.segmentedControl.momentary = NO;
    self.segmentedControl.tintColor = [UIColor colorWithWhite:0.39 alpha:1.0];
    [self.segmentedControl addTarget:self action:@selector(segmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont boldSystemFontOfSize:14.0f], UITextAttributeFont,
                                [UIColor colorWithWhite:0.88 alpha:1.0], UITextAttributeTextColor,
                                nil]; // 0.84
    [self.segmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [self.segmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
}

- (void)generateMapTypeSegmentedControl
{
    NSArray *segmentedControlItems = segmentedControlItems = @[@"Standard", @"Hybrid", @"Satellite", @"Terrain"];
    
    self.mapTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
    self.mapTypeSegmentedControl.frame = CGRectMake(60.0f, self.view.bounds.size.height -  31.0f - 6.0f, self.view.bounds.size.width - 60.0f - 6.0f, TAK_SEGMENTED_CONTROL_HEIGHT);
    self.mapTypeSegmentedControl.autoresizingMask = UIViewAutoresizingFlexibleTopMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    self.mapTypeSegmentedControl.segmentedControlStyle = UISegmentedControlStyleBar;
    self.mapTypeSegmentedControl.selectedSegmentIndex = 0;
    self.mapTypeSegmentedControl.momentary = NO;
    self.mapTypeSegmentedControl.tintColor = [UIColor colorWithWhite:0.39 alpha:1.0];
    [self.mapTypeSegmentedControl addTarget:self action:@selector(mapTypeSegmentedControlValueChanged:) forControlEvents:UIControlEventValueChanged];
    NSDictionary *attributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                [UIFont systemFontOfSize:12.0f], UITextAttributeFont,
                                [UIColor colorWithWhite:0.88 alpha:1.0], UITextAttributeTextColor,
                                nil]; // 0.84
    [self.mapTypeSegmentedControl setTitleTextAttributes:attributes forState:UIControlStateNormal];
    NSDictionary *highlightedAttributes = [NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor];
    [self.mapTypeSegmentedControl setTitleTextAttributes:highlightedAttributes forState:UIControlStateHighlighted];
    [self.view addSubview:self.mapTypeSegmentedControl];
}

- (void)generateTableView
{
    self.tableView = [[TAKSearchResultsTableView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT)];
    self.tableView.delegate = self;
    self.tableView.informationSourceType = TAKInformationSourceTypeGoogle;
    
    if ((self.searchResponse != nil) && (self.searchResponse.count > 0)) {
        self.tableView.tableViewContents = (NSMutableArray *)[self.searchResponse objectForKey:@"results"];
        [self.tableView reloadData];
    }
    
    [self.view addSubview:self.tableView];
}

- (void)generateMapViewWithLatitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude
{
#ifdef TAK_GOOGLE
    GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                            longitude:longitude
                                                                 zoom:11.9];
    self.mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT)];
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.mapView.camera = camera;
    self.mapView.myLocationEnabled = YES;
    self.mapView.delegate = self;
    [self.view addSubview:self.mapView];
    [self generateMapTypeSegmentedControl];
#endif
}

#pragma mark - Segmented control actions

- (void)segmentedControlValueChanged:(id)sender
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: {
            // Swap the view if necessary
            if (self.mapView == nil) {
                TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
                
                CLLocation *location;
                double latitude;
                double longitude;
                
                switch (appDelegate.currentLocationType) {
                    case TAKLocationTypeCurrentLocation: {
                        if (appDelegate.locationController.lastKnownLocation != nil) {
                            location = appDelegate.locationController.lastKnownLocation;
                            latitude = (double)location.coordinate.latitude;
                            longitude = (double)location.coordinate.longitude;
                        } else { // Aleksanterinkatu 52, Helsinki, Finland
                            latitude = 60.168824;
                            longitude = 24.942422;
                        }
                        break;
                    }
                        
                    case TAKLocationTypeOtaniemi: {
                        latitude = TAK_OTANIEMI_LATITUDE;
                        longitude = TAK_OTANIEMI_LONGITUDE;
                        break;
                    }
                        
                    case TAKLocationTypeSchonberg: {
                        latitude = TAK_SCHONBERG_LATITUDE;
                        longitude = TAK_SCHONBERG_LONGITUDE;
                        break;
                    }
                        
                    case TAKLocationTypePittsburgh: {
                        latitude = TAK_PITTSBURGH_LATITUDE;
                        longitude = TAK_PITTSBURGH_LONGITUDE;
                        break;
                    }
                        
                    default: {
                        latitude = TAK_SUZHOU_LATITUDE;
                        longitude = TAK_SUZHOU_LONGITUDE;
                        break;
                    }
                }
                
                [self generateMapViewWithLatitude:latitude longitude:longitude];
            }
            self.mapView.hidden = NO;
            self.mapTypeSegmentedControl.hidden = NO;
            if (self.tableView != nil) {
                self.tableView.hidden = YES;
            }
            break;
        }
        default: {
            // Swap the view if necessary
            if (self.tableView == nil) {
                [self generateTableView];
            }
            self.tableView.hidden = NO;
            if (self.mapView != nil) {
                self.mapView.hidden = YES;
                self.mapTypeSegmentedControl.hidden = YES;
            }
            break;
        }
    }
}

- (void)mapTypeSegmentedControlValueChanged:(id)sender
{
    switch (self.mapTypeSegmentedControl.selectedSegmentIndex) {
        case 0: {
            self.mapView.mapType = kGMSTypeNormal;
            NSLog(@"Standard");
            break;
        }
            
        case 1: {
            self.mapView.mapType = kGMSTypeHybrid;
            NSLog(@"Hybrid");
            break;
        }
            
        case 2: {
            self.mapView.mapType = kGMSTypeSatellite;
            NSLog(@"Satellite");
            break;
        }
            
        default:
            self.mapView.mapType = kGMSTypeTerrain;
            NSLog(@"Terrain");
            break;
    }
    
    NSLog(@"map type: %i", self.mapView.mapType);
}

#pragma mark - Google Places search

- (void)handleRequestData:(NSData *)data
{
    NSError *error;
    
    if (!data) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Complete the Request" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        if (self.activityIndicatorView) {
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
        }
        return;
    }
    
    id response;
    @try {
        response = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Complete the Request" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        if (self.activityIndicatorView) {
            [self.activityIndicatorView stopAnimating];
            self.activityIndicatorView.hidden = YES;
        }
        return;
    }
    
    if (error) {
        NSLog(@"Error: %@", [error localizedDescription]);
        [[[UIAlertView alloc] initWithTitle:@"Error" message:[error localizedDescription] delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
        return;
    }
    
    NSLog(@"Google Places JSON response: %@", response);
    
    if ([response isKindOfClass:[NSNull class]]) {
        return;
    }
    
    self.searchResponse = response;
    
    @try {
        NSArray *searchResults = [self.searchResponse objectForKey:@"results"];
        
        if (self.tableView != nil) {
            self.tableView.tableViewContents = (NSMutableArray *)searchResults;
            [self.tableView reloadData];
        }
        
        if ((searchResults == nil) || (searchResults.count < 1)) {
            UIAlertView * alert = [[UIAlertView alloc] initWithTitle:@"No Results" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
            [alert show];
        } else {
            if (searchResults.count > 0) {
                for (int i = 0; i < searchResults.count; i++) {
                    NSDictionary *placeInformation = [searchResults objectAtIndex:i];
                    
                    GMSMarker *marker = [[GMSMarker alloc] init];
                    CLLocationDegrees latitude = (CLLocationDegrees)[[[[placeInformation objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
                    CLLocationDegrees longitude = (CLLocationDegrees)[[[[placeInformation objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
                    marker.position = CLLocationCoordinate2DMake(latitude, longitude);
                    marker.title = (NSString *)[placeInformation objectForKey:@"name"];
                    marker.snippet = (NSString*)[placeInformation objectForKey:@"vicinity"];
                    marker.map = self.mapView;
                    // marker.animated = YES;
                    NSLog(@"Annotation title: %@, subtitle: %@, lat: %f, long: %f", marker.title, marker.snippet, latitude, longitude);
                }
            }
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

- (void)searchNearbyGooglePlacesWithParameters:(NSDictionary *)parameters
{
    //
    // Documentation: https://developers.google.com/places/documentation/search
    // URL format: https://maps.googleapis.com/maps/api/place/nearbysearch/output?parameters
    // Required: key, location, radius, sensor
    // Optional: keyword, language, minprice and maxprice, name, opennow, rankby (prominence | distance),
    //           types, pagetoken, zagatselected (only for Places API enterpise customers)
    // Supported types: https://developers.google.com/places/documentation/supported_types
    //
    
    @try {
        if ((parameters == nil) || (parameters.count == 0)) {
            NSLog(@"No parameters were given!");
            return;
        }
        
        double latitude = [[parameters objectForKey:@"Latitude"] doubleValue];
        double longitude = [[parameters objectForKey:@"Longitude"] doubleValue];
        int radius = [[parameters objectForKey:@"Radius"] integerValue];
        NSString *types = [parameters objectForKey:@"Types"];
        // NSString *openNow = [parameters objectForKey:@"Open Now"];
        
        NSString *searchURLString = [NSString stringWithFormat:@"%@key=%@&location=%f,%f&radius=%i&types=%@&sensor=true",
                                     TAK_GOOGLE_PLACES_BASE_URL,
                                     TAK_GOOGLE_PLACES_API_KEY,
                                     latitude,
                                     longitude,
                                     radius,
                                     types];
        NSString *searchURLStringWithPercentEscapes = [searchURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL * searchURL = [NSURL URLWithString:searchURLStringWithPercentEscapes];
        
#ifdef DEBUG
        NSLog(@"Google Places search URL: %@", searchURL);
#endif
        
        // Download the data asynchronously
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *requestData = [NSData dataWithContentsOfURL:searchURL];
            [self performSelectorOnMainThread:@selector(handleRequestData:) withObject:requestData waitUntilDone:YES];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        NSDictionary *placeInformation = [self.tableView.tableViewContents objectAtIndex:indexPath.row];
        TAKDetailViewController *DVC = [[TAKDetailViewController alloc] initWithStyle:UITableViewStyleGrouped tableViewContentDictionary:[NSMutableDictionary new] informationSourceType:TAKInformationSourceTypeGoogle referenceID:(NSString *)[placeInformation objectForKey:@"reference"]];
        DVC.title = (NSString *)[placeInformation objectForKey:@"name"];
        
        [self.navigationController pushViewController:DVC animated:YES];
        [tableView deselectRowAtIndexPath:indexPath animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

- (NSString *)googlePlaceTypeWithHumanReadableString:(NSString *)string
{
    if ([string isEqualToString:@"Accounting"]) {
        return @"accounting";
    } else if ([string isEqualToString:@"Airports"]) {
        return @"airport";
    } else if ([string isEqualToString:@"Art Galleries"]) {
        return @"art_gallery";
    } else if ([string isEqualToString:@"Bakeries"]) {
        return @"bakery";
    } else if ([string isEqualToString:@"Banks"]) {
        return @"bank";
    } else if ([string isEqualToString:@"Cafés"]) {
        return @"cafe";
    } else if ([string isEqualToString:@"Department Stores"]) {
        return @"department_store";
    } else if ([string isEqualToString:@"Finance"]) {
        return @"finance";
    } else if ([string isEqualToString:@"Food"]) {
        return @"food";
    } else if ([string isEqualToString:@"Gyms"]) {
        return @"gym";
    } else if ([string isEqualToString:@"Hospitals"]) {
        return @"hospital";
    } else if ([string isEqualToString:@"Lawyers"]) {
        return @"lawyer";
    } else if ([string isEqualToString:@"Libraries"]) {
        return @"library";
    } else if ([string isEqualToString:@"Local Government Offices"]) {
        return @"local_government_office";
    } else if ([string isEqualToString:@"Movie Theaters"]) {
        return @"movie_theater";
    } else if ([string isEqualToString:@"Museums"]) {
        return @"museum";
    } else if ([string isEqualToString:@"Nightclubs"]) {
        return @"nightclub";
    } else if ([string isEqualToString:@"Parks"]) {
        return @"park";
    } else if ([string isEqualToString:@"Parking"]) {
        return @"parking";
    } else if ([string isEqualToString:@"Post Offices"]) {
        return @"post_office";
    } else if ([string isEqualToString:@"Restaurants"]) {
        return @"restaurant";
    } else if ([string isEqualToString:@"Schools"]) {
        return @"school";
    } else if ([string isEqualToString:@"Stores"]) {
            return @"store";
    } else if ([string isEqualToString:@"Subway Stations"]) {
        return @"subway_station";
    } else if ([string isEqualToString:@"Train Stations"]) {
        return @"train_station";
    } else if ([string isEqualToString:@"Travel Agencies"]) {
        return @"travel_agency";
    } else if ([string isEqualToString:@"Universities"]) {
        return @"university";
    } else {
        return @"zoo";
    }
}

#pragma mark - Google MapView delegate methods

- (void)mapView:(GMSMapView *)mapView
didTapInfoWindowOfMarker:(GMSMarker *)marker
{
    @try {
        NSArray *searchResults = [self.searchResponse objectForKey:@"results"];
        TAKDetailViewController *DVC;
        
        for (int i = 0; i < searchResults.count; i++) {
            NSDictionary *placeInformation = [searchResults objectAtIndex:i];
            NSString *placeName = (NSString *)[placeInformation objectForKey:@"name"];
            if ([placeName isEqualToString:marker.title]) {
                DVC = [[TAKDetailViewController alloc] initWithStyle:UITableViewStyleGrouped tableViewContentDictionary:[NSMutableDictionary new] informationSourceType:TAKInformationSourceTypeGoogle referenceID:(NSString *)[placeInformation objectForKey:@"reference"]];
                DVC.title = (NSString *)[placeInformation objectForKey:@"name"];
                break;
            }
        }
        
        [self.navigationController pushViewController:DVC animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"An error occurred while trying to present the detail view controller: %@", exception.description);
    }
}

@end
