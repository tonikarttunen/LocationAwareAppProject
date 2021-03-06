//
//  TAKFoursquareLocalSearchResultsViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/8/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKAppDelegate.h"
#import "TAKFoursquareLocalSearchResultsViewController.h"
#import "TAKFoursquareController.h"
#import "TAKDetailViewController.h"
#import <QuartzCore/QuartzCore.h>

@interface TAKFoursquareLocalSearchResultsViewController ()

// UI
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UISegmentedControl *mapTypeSegmentedControl;
@property (nonatomic, strong) TAKMapView *mapView;
@property (nonatomic, strong) UIView *mapViewContainer;
@property (nonatomic, strong) TAKSearchResultsTableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;
@property (nonatomic, copy, readwrite) NSString *category;

// Foursquare
@property (nonatomic, copy) NSArray *venues;

@end

@implementation TAKFoursquareLocalSearchResultsViewController

- (id)initWithCategory:(NSString *)category
{
    self = [super init];
    if (self) {
        _category = [category copy];
        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (appDelegate && appDelegate.foursquareController && appDelegate.foursquareController) {
            TAKFoursquareController *foursquareController = appDelegate.foursquareController;
            if ([foursquareController.foursquare isSessionValid]) {
                CLLocation *location;
                NSString *locationString;
                
                double latitude;
                double longitude;
                
                switch (appDelegate.currentLocationType) {
                    case TAKLocationTypeCurrentLocation: {
                        if (appDelegate.locationController.lastKnownLocation != nil) {
                            location = appDelegate.locationController.lastKnownLocation;
                            latitude = (double)location.coordinate.latitude;
                            longitude = (double)location.coordinate.longitude;
                            locationString = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
                        } else {
                            locationString = @"60.168824,24.942422"; // Aleksanterinkatu 52, Helsinki, Finland
                        }
                        break;
                    }
                        
                    case TAKLocationTypeOtaniemi: {
                        latitude = TAK_OTANIEMI_LATITUDE;
                        longitude = TAK_OTANIEMI_LONGITUDE;
                        locationString = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
                        break;
                    }
                        
                    case TAKLocationTypeSchonberg: {
                        latitude = TAK_SCHONBERG_LATITUDE;
                        longitude = TAK_SCHONBERG_LONGITUDE;
                        locationString = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
                        break;
                    }
                        
                    case TAKLocationTypePittsburgh: {
                        latitude = TAK_PITTSBURGH_LATITUDE;
                        longitude = TAK_PITTSBURGH_LONGITUDE;
                        locationString = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
                        break;
                    }
                        
                    default: {
                        latitude = TAK_SUZHOU_LATITUDE;
                        longitude = TAK_SUZHOU_LONGITUDE;
                        locationString = [NSString stringWithFormat:@"%f,%f", latitude, longitude];
                        break;
                    }
                }
                
                NSLog(@"LOCATION STRING: %@", locationString);
                
                NSString *categoryID = [self foursquareCategoryID];
                if ([categoryID isEqualToString:@"Everything"]) {
                    [foursquareController searchFoursquareContentWithPath:@"venues/search"
                                                         searchParameters:@{@"ll" : locationString,
                                                                            @"radius" : @"3000",
                                                                            @"intent" : @"browse"}];
                } else if ([categoryID isEqualToString:@"Trending"]) {
                    [foursquareController searchFoursquareContentWithPath:@"venues/trending"
                                                         searchParameters:@{@"ll" : locationString,
                                                                            @"radius" : @"3000",
                                                                            @"intent" : @"browse"}];
                } else {
                    [foursquareController searchFoursquareContentWithPath:@"venues/search"
                                                         searchParameters:@{@"ll" : locationString,
                                                                            @"radius" : @"3000",
                                                                            @"categoryId" : categoryID,
                                                                            @"intent" : @"browse"}];
                }
                NSLog(@"Category: %@, categoryID%@", _category, categoryID);
            }
        }
    }
    return self;
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
	// Do any additional setup after loading the view.
    self.title = self.category;
    
    TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate && appDelegate.foursquareController && appDelegate.foursquareController.foursquare) {
        BZFoursquare *foursquare = appDelegate.foursquareController.foursquare;
        if (foursquare.isSessionValid) {
            [self generateInitialUI];
        } else {
            [self generateFoursquareAuthorizationUI];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    _toolbar = nil;
    _segmentedControl = nil;
    _mapTypeSegmentedControl = nil;
    _mapView.delegate = nil;
    _mapView = nil;
    _venues = nil;
    _mapViewContainer = nil;
    _activityIndicatorView = nil;
}

#pragma mark - UI

- (void)generateFoursquareAuthorizationUI
{
    self.foursquareAuthorizationView = [[TAKFoursquareAuthorizationView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.foursquareAuthorizationView];
}

- (void)generateInitialUI
{
    [self setViewBasicProperties];
    [self generateToolbar];
    [self generateMapView];
    if (!self.activityIndicatorView) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    }
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
    [self.activityIndicatorView startAnimating];
}

- (void)updateUI
{
#ifdef DEBUG
    NSLog(@"The updateUI method was called.");
#endif
    
    @try {
        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (appDelegate && appDelegate.foursquareController && /* appDelegate.foursquareController.foursquareDataController */ appDelegate.foursquareController.processedFoursquareData) {
            // self.venues = [appDelegate.foursquareController.foursquareDataController foursquareDataToArray];
            self.venues = (NSArray *)appDelegate.foursquareController.processedFoursquareData;
            self.mapView.mapItems = (NSMutableArray *)self.venues;
            [self.mapView refreshMapAnnotationsWithArray:self.venues informationSource:TAKInformationSourceTypeFoursquare];
            
            if (self.tableView != nil) {
                @try {
                    if ((self.venues != nil) && (self.venues.count > 0)) {
                        self.tableView.tableViewContents = (NSMutableArray *)self.venues;
                        [self.tableView reloadData];
                    }
                }
                @catch (NSException *exception) {
                    NSLog(@"Cannot create a table view: %@", exception. description);
                }
            }
            
            if (self.venues.count == 0) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Results" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
                [alert show];
            }
#ifdef DEBUG
            // NSLog(@"\nVenues: %@\n", venues);
#endif
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot update the UI: %@", exception.description);
    }
    
    [self hideActivityIndicator];
}

- (void)showActivityIndicator
{
#ifdef DEBUG
    NSLog(@"showActivityIndicator was called.");
#endif
}
- (void)hideActivityIndicator
{
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
#ifdef DEBUG
    NSLog(@"hideActivityIndicator was called.");
#endif
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
    NSArray *segmentedControlItems = segmentedControlItems = @[@"Standard", @"Hybrid", @"Satellite"];
    
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
    self.tableView.informationSourceType = TAKInformationSourceTypeFoursquare;
    
    @try {
        if ((self.venues != nil) && (self.venues.count > 0)) {
            self.tableView.tableViewContents = (NSMutableArray *)self.venues;
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot create a table view: %@", exception. description);
    }
    [self.view addSubview:self.tableView];
}

- (void)generateMapView
{
    self.mapViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT)];
    self.mapViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapViewContainer];
    
    self.mapView = [[TAKMapView alloc] initWithFrame:self.mapViewContainer.bounds];
    self.mapView.informationSourceType = TAKInformationSourceTypeFoursquare;
    [self.mapViewContainer addSubview:self.mapView];
    
    UIImageView *foursquareImagView = [[UIImageView alloc] initWithFrame:CGRectMake(/* (self.mapViewContainer.frame.size.width -236.0f) / 2.0f*/ 69.0f, self.mapViewContainer.frame.size.height - 44.0f - 42.0f, 236.0f, 60.0f)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"poweredByFoursquare" ofType:@"png"];
    foursquareImagView.image = [[UIImage alloc] initWithContentsOfFile:path];
    foursquareImagView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin; 
    [self.mapViewContainer addSubview:foursquareImagView];
    [self generateMapTypeSegmentedControl];
}

#pragma mark - Segmented control actions

- (void)segmentedControlValueChanged:(id)sender
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: {
            // Swap the view if necessary
            if (self.mapView == nil) {
                [self generateMapView];
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
            self.mapView.mapType = MKMapTypeStandard;
            NSLog(@"Standard");
            break;
        }
            
        case 1: {
            self.mapView.mapType = MKMapTypeHybrid;
            NSLog(@"Hybrid");
            break;
        }
            
        case 2: {
            self.mapView.mapType = MKMapTypeSatellite;
            NSLog(@"Satellite");
            break;
        }
            
        default:
            NSLog(@"Unknown maptype");
            break;
    }
    
    NSLog(@"map type: %i", self.mapView.mapType);
}

#pragma mark - Alert

- (void)showAlertWithText:(NSString *)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Complete the Request"
                                                    message:text delegate:self
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
//    NSMutableArray *detailViewContents = [NSMutableArray new];
    
    @try {
        NSDictionary *dictionary = [self.venues objectAtIndex:indexPath.row];
        
//        for (id key in [dictionary allKeys]) {
//            [detailViewContents addObject:@[(NSString *)key, [dictionary objectForKey:key]]];
//        }
        
        NSString *dvcTitle = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
        // NSString *DVCTitle = (NSString *)[[self.tableView.tableViewContents objectAtIndex:indexPath.row] objectForKey:@"Name"];
        TAKDetailViewController *DVC = [[TAKDetailViewController alloc] initWithStyle:UITableViewStyleGrouped tableViewContentDictionary:dictionary informationSourceType:TAKInformationSourceTypeFoursquare];
        // DVC.informationSourceType = TAKInformationSourceTypeFoursquare;
        DVC.title = dvcTitle;
        [self.navigationController pushViewController:DVC animated:YES];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
}

#pragma mark - Convert the name of the selected category to a Foursquare category ID

- (NSString *)foursquareCategoryID
{
    NSString *categoryName = self.category;
    if (!categoryName) {
        return @"Everything";
    }
    
    if ([categoryName isEqualToString:@"Athletics and Sports"]) {
        return @"4f4528bc4b90abdf24c9de85";
    } else if ([categoryName isEqualToString:@"Colleges and Universities"]) {
        return @"4d4b7105d754a06372d81259";
    } else if ([categoryName isEqualToString:@"Concert Halls"]) {
        return @"5032792091d4c4b30a586d5c";
    } else if ([categoryName isEqualToString:@"Convention Centers"]) {
        return @"4bf58dd8d48988d1ff931735";
    } else if ([categoryName isEqualToString:@"Event Spaces"]) {
        return @"4bf58dd8d48988d171941735";
    } else if ([categoryName isEqualToString:@"Food"]) {
        return @"4d4b7105d754a06374d81259";
    } else if ([categoryName isEqualToString:@"Government Buildings"]) {
        return @"4bf58dd8d48988d126941735";
    } else if ([categoryName isEqualToString:@"Historic Sites"]) {
        return @"4deefb944765f83613cdba6e";
    } else if ([categoryName isEqualToString:@"Hospitals"]) {
        return @"4bf58dd8d48988d196941735";
    } else if ([categoryName isEqualToString:@"Hotels"]) {
        return @"4bf58dd8d48988d1fa931735";
    } else if ([categoryName isEqualToString:@"Libraries"]) {
        return @"4bf58dd8d48988d12f941735";
    } else if ([categoryName isEqualToString:@"Monuments and Landmarks"]) {
        return @"4bf58dd8d48988d12d941735";
    } else if ([categoryName isEqualToString:@"Movie Theaters"]) {
        return @"4bf58dd8d48988d17f941735";
    } else if ([categoryName isEqualToString:@"Museums"]) {
        return @"4bf58dd8d48988d181941735";
    } else if ([categoryName isEqualToString:@"Neighbourhoods"]) {
        return @"4f2a25ac4b909258e854f55f";
    } else if ([categoryName isEqualToString:@"Nightlife"]) {
        return @"4d4b7105d754a06376d81259";
    } else if ([categoryName isEqualToString:@"Non-Profits"]) {
        return @"50328a8e91d4c4b30a586d6c";
    } else if ([categoryName isEqualToString:@"Offices"]) {
        return @"4bf58dd8d48988d124941735";
    } else if ([categoryName isEqualToString:@"Parking"]) {
        return @"4c38df4de52ce0d596b336e1";
    } else if ([categoryName isEqualToString:@"Parks"]) {
        return @"4bf58dd8d48988d163941735";
    } else if ([categoryName isEqualToString:@"Post Offices"]) {
        return @"4bf58dd8d48988d172941735";
    } else if ([categoryName isEqualToString:@"Recidences"]) {
        return @"4e67e38e036454776db1fb3a";
    } else if ([categoryName isEqualToString:@"Scenic Lookouts"]) {
        return @"4bf58dd8d48988d165941735";
    } else if ([categoryName isEqualToString:@"Schools"]) {
        return @"4bf58dd8d48988d13b941735";
    } else if ([categoryName isEqualToString:@"Shops and Services"]) {
        return @"4d4b7105d754a06378d81259";
    } else if ([categoryName isEqualToString:@"Ski Areas"]) {
        return @"4bf58dd8d48988d1e9941735";
    } else if ([categoryName isEqualToString:@"Tech Startups"]) {
        return @"4bf58dd8d48988d125941735";
    } else if ([categoryName isEqualToString:@"Travel and Transport"]) {
        return @"4d4b7105d754a06379d81259";
    } else if ([categoryName isEqualToString:@"Trending"]) {
        return @"Trending";
    } else {
        return @"Everything";
    }
}

@end
