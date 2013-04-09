//
//  TAKLocalSearchResultsViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/20/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKLocalSearchResultsViewController.h"

@interface TAKLocalSearchResultsViewController ()

@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) MKLocalSearchResponse *localSearchResponse;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) TAKMapView *mapView;
@property (nonatomic, strong) TAKSearchResultsTableView *tableView;

@end

@implementation TAKLocalSearchResultsViewController

- (id)init
{
    self = [super init];
    if (self) {
        self.localSearchResponse = [[MKLocalSearchResponse alloc] init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    [self generateInitialUI];
    
    if (self.title != nil) {
        [self performLocalSearchWithString:self.title];
    }
    
//    TAKGeocoder *geo = [[TAKGeocoder alloc] init];
//    
//    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.781516 longitude:-122.404955];
//    [geo reverseGeocodeLocation:location];
//    
//    NSString *address = @"Aleksanterinkatu 52, Helsinki, Finland";
//    [geo forwardGeocodeAddress:address];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.mapView = nil;
    if (self.localSearch.isSearching) {
        [self.localSearch cancel];
    }
    self.localSearch = nil;
    self.localSearchResponse = nil;
    self.toolbar = nil;
    self.segmentedControl = nil;
}

#pragma mark - UI

- (void)generateInitialUI
{
    [self setViewBasicProperties];
    [self generateToolbar];
    [self generateMapView];
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
    self.tableView.informationSourceType = TAK_INFORMATION_SOURCE_APPLE;
    if ((self.localSearchResponse != nil) && (self.localSearchResponse.mapItems.count > 0)) {
        self.tableView.tableViewContents = (NSMutableArray *)self.localSearchResponse.mapItems;
        [self.tableView reloadData];
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

#pragma mark - Local search (Apple MKLocalSearch)

- (void)performLocalSearchWithString:(NSString *)searchString
{
    NSLog(@"Search string: %@", searchString);
    if (self.localSearch.searching) {
        [self.localSearch cancel];
    }
    
    MKLocalSearchRequest *localSearchRequest = [MKLocalSearchRequest new];
    NSLog(@"Region: lat. %f, long. %f.",
          self.mapView.region.center.latitude,
          self.mapView.region.center.longitude);
    localSearchRequest.region = self.mapView.region;
    localSearchRequest.naturalLanguageQuery = searchString;
    
    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    self.localSearch = [[MKLocalSearch alloc] initWithRequest:localSearchRequest];
    
    [self.localSearch startWithCompletionHandler:^(MKLocalSearchResponse *response, NSError *error) {
        [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:NO];
        
        if (error != nil) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Local Search Failed"
                                       message:error.description
                                      delegate:self
                             cancelButtonTitle:@"Dismiss"
                             otherButtonTitles: nil];
            [alert show];
            NSLog(@"Local search failed: %@", error.description);
            return;
        }
        
        if (response.mapItems.count == 0) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Search Results"
                                                            message:nil
                                                           delegate:self
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles: nil];
            [alert show];
#if DEBUG
            NSLog(@"No local search results for place: lat. %f, long. %f.",
                  self.mapView.region.center.latitude,
                  self.mapView.region.center.longitude);
#endif
            return;
        }
#if DEBUG
        NSLog(@"%@", response.mapItems.description);
#endif
        self.localSearchResponse = response;
        
        [self.mapView refreshMapAnnotationsWithArray:self.localSearchResponse.mapItems];
        
        if (self.tableView != nil) {
            self.tableView.tableViewContents = (NSMutableArray *)self.localSearchResponse.mapItems;
            [self.tableView reloadData];
        }
        
    }];
}


@end
