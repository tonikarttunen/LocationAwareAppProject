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

@interface TAKFoursquareLocalSearchResultsViewController ()

// UI
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) TAKMapView *mapView;
@property (nonatomic, strong) TAKSearchResultsTableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

// Foursquare
@property (nonatomic, copy) NSArray *venues;

@end

@implementation TAKFoursquareLocalSearchResultsViewController

- (id)init // WithCoder:(NSCoder *)aDecoder // WithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    // self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    self = [super init /* WithCoder:aDecoder */];
    if (self) {
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
                [foursquareController searchFoursquareContentWithPath:@"venues/search"
                                                     searchParameters:@{@"ll" : locationString,
                                                                        @"radius" : @"2000"}];
            }
        }
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    
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
#if DEBUG
    NSLog(@"The updateUI method was called.");
#endif
    
    @try {
        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (appDelegate && appDelegate.foursquareController && appDelegate.foursquareController.foursquareDataController) {
            self.venues = [appDelegate.foursquareController.foursquareDataController foursquareDataToArray];
            [self.mapView refreshMapAnnotationsWithArray:self.venues informationSource:TAK_INFORMATION_SOURCE_FOURSQUARE];
#if DEBUG
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
#if DEBUG
    NSLog(@"showActivityIndicator was called.");
#endif
}
- (void)removeActivityIndicatorFromView
{
#if DEBUG
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
    self.tableView.informationSourceType = TAK_INFORMATION_SOURCE_FOURSQUARE;
    
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
    self.mapView = [[TAKMapView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT)];
    [self.view addSubview:self.mapView];
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
    NSString *DVCTitle = (NSString *)[[self.tableView.tableViewContents objectAtIndex:indexPath.row] objectForKey:@"Name"];
    TAKDetailViewController *DVC = [[TAKDetailViewController alloc] initWithStyle:UITableViewStylePlain];
    DVC.title = DVCTitle;
    [self.navigationController pushViewController:DVC animated:YES];
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
