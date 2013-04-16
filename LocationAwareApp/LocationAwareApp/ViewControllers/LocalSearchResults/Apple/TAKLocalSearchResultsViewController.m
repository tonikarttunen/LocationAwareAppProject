//
//  TAKLocalSearchResultsViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/20/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKLocalSearchResultsViewController.h"
#import "TAKDetailViewController.h"

@interface TAKLocalSearchResultsViewController ()

@property (nonatomic, strong) MKLocalSearch *localSearch;
@property (nonatomic, strong) MKLocalSearchResponse *localSearchResponse;
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) TAKMapView *mapView;
@property (nonatomic, strong) TAKSearchResultsTableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

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

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    if (self.tableView != nil) {
        [self.tableView deselectRowAtIndexPath:[self.tableView indexPathForSelectedRow] animated:YES];
    }
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

- (void)generateTableView
{
    self.tableView = [[TAKSearchResultsTableView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT)];
    self.tableView.delegate = self;
    self.tableView.informationSourceType = TAKInformationSourceTypeApple;
    if ((self.localSearchResponse != nil) && (self.localSearchResponse.mapItems.count > 0)) {
        self.tableView.tableViewContents = (NSMutableArray *)self.localSearchResponse.mapItems;
        [self.tableView reloadData];
    }
    [self.view addSubview:self.tableView];
}

- (void)generateMapView
{
    self.mapView = [[TAKMapView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT)];
    self.mapView.informationSourceType = TAKInformationSourceTypeApple;
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
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
        
        if ((error != nil) || (response.mapItems.count == 0)) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"No Search Results"
                                       message:@""
                                      delegate:self
                             cancelButtonTitle:@"Dismiss"
                             otherButtonTitles: nil];
            [alert show];
            NSLog(@"Local search failed: %@", error.description);
            return;
        }
        
#ifdef DEBUG
        NSLog(@"%@", response.mapItems.description);
#endif
        self.localSearchResponse = response;
        
        self.mapView.mapItems = (NSMutableArray *)self.localSearchResponse.mapItems;
#ifdef DEBUG
        NSLog(@"%@", self.mapView.mapItems);
#endif
        [self.mapView refreshMapAnnotationsWithArray:(NSArray *)self.localSearchResponse.mapItems informationSource:TAKInformationSourceTypeApple];
        
        if (self.tableView != nil) {
            self.tableView.tableViewContents = (NSMutableArray *)self.localSearchResponse.mapItems;
            [self.tableView reloadData];
        }
    }];
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    @try {
        MKMapItem *mapItem = [self.tableView.tableViewContents objectAtIndex:indexPath.row];
        NSString *DVCTitle = mapItem.name;
        NSMutableArray *detailViewContents = [NSMutableArray new];
        NSString *address = ABCreateStringWithAddressDictionary(mapItem.placemark.addressDictionary, YES);
        NSString *phone = mapItem.phoneNumber;
        NSURL *url = mapItem.url;
        NSString *latitude = [[NSString alloc] initWithFormat:@"%f", mapItem.placemark.coordinate.latitude];
        NSString *longitude = [[NSString alloc] initWithFormat:@"%f", mapItem.placemark.coordinate.longitude];
        if (DVCTitle != nil) {
            [detailViewContents addObject:@[@"Name", DVCTitle]];
        }
        if (address != nil) {
            [detailViewContents addObject:@[@"Address", address]];
        }
        if (phone != nil) {
            [detailViewContents addObject:@[@"Phone", phone]];
        }
        if (url != nil) {
            [detailViewContents addObject:@[@"URL", url]];
        }
        if (latitude != nil) {
            [detailViewContents addObject:@[@"Latitude", latitude]];
        }
        if (longitude != nil) {
            [detailViewContents addObject:@[@"Longitude", longitude]];
        }
        TAKDetailViewController *DVC = [[TAKDetailViewController alloc] initWithStyle:UITableViewStylePlain
                                                                    tableViewContents:(NSArray *)detailViewContents
                                                                informationSourceType:TAKInformationSourceTypeApple];
        // DVC.informationSourceType = TAKInformationSourceTypeApple;
        DVC.title = DVCTitle;
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

@end
