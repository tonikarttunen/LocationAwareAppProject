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
        self.category = category;
        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (appDelegate && appDelegate.foursquareController && appDelegate.foursquareController) {
            TAKFoursquareController *foursquareController = appDelegate.foursquareController;
            if ([foursquareController.foursquare isSessionValid]) {
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
                NSString *categoryID = [self foursquareCategoryID];
                if ([categoryID isEqualToString:@"Everything"]) {
                    [foursquareController searchFoursquareContentWithPath:@"venues/search"
                                                         searchParameters:@{@"ll" : locationString,
                                                                            @"radius" : @"2000"}];
                } else if ([categoryID isEqualToString:@"Trending"]) {
                    [foursquareController searchFoursquareContentWithPath:@"venues/trending"
                                                         searchParameters:@{@"ll" : locationString,
                                                               @"radius" : @"2000"}];
                } else {
                    [foursquareController searchFoursquareContentWithPath:@"venues/search"
                                                         searchParameters:@{@"ll" : locationString,
                                                                            @"radius" : @"2000",
                                                                            @"categoryId" : categoryID}];
                }
                NSLog(@"Category: %@, categoryID%@", self.category, categoryID);
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
    _mapView = nil;
    _mapViewContainer = nil;
    _toolbar = nil;
    _segmentedControl = nil;
    _activityIndicatorView = nil;
    _venues = nil;
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
#ifdef DEBUG
            // NSLog(@"\nVenues: %@\n", venues);
#endif
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot update the UI: %@", exception.description);
    }
}

- (void)showActivityIndicator
{
#ifdef DEBUG
    NSLog(@"showActivityIndicator was called.");
#endif
}
- (void)removeActivityIndicatorFromView
{
#ifdef DEBUG
    NSLog(@"removeActivityIndicatorFromView was called.");
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
    self.toolbar.tintColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.5 alpha:1.0];
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
    
    UIImageView *foursquareImagView = [[UIImageView alloc] initWithFrame:CGRectMake(42.0f, self.mapViewContainer.frame.size.height - 44.0f, 236.0f, 60.0f)];
    NSString *path = [[NSBundle mainBundle] pathForResource:@"poweredByFoursquare" ofType:@"png"];
    foursquareImagView.image = [[UIImage alloc] initWithContentsOfFile:path];
    foursquareImagView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin; 
    [self.mapViewContainer addSubview:foursquareImagView];
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
            }
            break;
        }
    }
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

#pragma mark - Convert the name of the selected category to a Foursquare category ID

- (NSString *)foursquareCategoryID
{
    NSString *categoryName = self.category;
    if (!categoryName) {
        return @"Everything";
    }
    
    if ([categoryName isEqualToString:@"Athletics & Sports"]) {
        return @"4f4528bc4b90abdf24c9de85";
    } else if ([categoryName isEqualToString:@"Colleges & Universities"]) {
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
    } else if ([categoryName isEqualToString:@"Monuments & Landmarks"]) {
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
    } else if ([categoryName isEqualToString:@"Shops & Services"]) {
        return @"4d4b7105d754a06378d81259";
    } else if ([categoryName isEqualToString:@"Ski Areas"]) {
        return @"4bf58dd8d48988d1e9941735";
    } else if ([categoryName isEqualToString:@"Tech Startups"]) {
        return @"4bf58dd8d48988d125941735";
    } else if ([categoryName isEqualToString:@"Travel & Transport"]) {
        return @"4d4b7105d754a06379d81259";
    } else if ([categoryName isEqualToString:@"Trending"]) {
        return @"Trending";
    } else {
        return @"Everything";
    }
}

@end
