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

@interface TAKFoursquareLocalSearchResultsViewController ()

// UI
@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) TAKMapView *mapView;
@property (nonatomic, strong) TAKSearchResultsTableView *tableView;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

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
                [foursquareController searchFoursquareContentWithPath:@"venues/search"
                                                     searchParameters:@{@"ll" : @"40.7,-74"}];
            }
        }
        
        // Custom initialization
//        self.foursquare = [[BZFoursquare alloc] initWithClientID:TAK_FOURSQUARE_API_KEY callbackURL:TAK_FOURSQUARE_API_REDIRECT_URL];
//        self.foursquare.locale = @"en";
//        // NSLog(@"LOCALE: %@", [[NSLocale currentLocale] objectForKey:NSLocaleLanguageCode]);
//        self.foursquare.version = @"20111119";
//        self.foursquare.sessionDelegate = self;
    }
    return self;
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
//    _foursquare.sessionDelegate = nil;
//    [self cancelFoursquareRequest];
//    _foursquare = nil;
//    _foursquareResponse = nil;
//    _foursquareMeta = nil;
//    _foursquareNotifications = nil;
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
    self.tableView.informationSourceType = TAK_INFORMATION_SOURCE_FOURSQUARE;
//    if ((self.localSearchResponse != nil) && (self.localSearchResponse.mapItems.count > 0)) {
//        self.tableView.tableViewContents = (NSMutableArray *)self.localSearchResponse.mapItems;
//        [self.tableView reloadData];
//    }
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

#pragma mark - Fousquare

//- (void)updateView {
//    if ([self isViewLoaded] && (self.tableView != nil) ) {
//        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
//        [self.tableView reloadData];
//        if (indexPath) {
//            [self.tableView selectRowAtIndexPath:indexPath animated:NO scrollPosition:UITableViewScrollPositionNone];
//        }
//    }
//}
//
//- (void)cancelFoursquareRequest {
//    if (self.foursquareRequest != nil) {
//        self.foursquareRequest.delegate = nil;
//        [self.foursquareRequest cancel];
//        self.foursquareRequest = nil;
//        [UIApplication sharedApplication].networkActivityIndicatorVisible = NO;
//    }
//}
//
//- (void)prepareForFoursquareRequest {
//    [self cancelFoursquareRequest];
//    self.foursquareMeta = nil;
//    self.foursquareResponse = nil;
//    self.foursquareNotifications = nil;
//}
//
//- (void)searchFoursquareVenues {
//    [self prepareForFoursquareRequest];
//    NSDictionary *parameters = [NSDictionary dictionaryWithObjectsAndKeys:@"40.7,-74", @"ll", nil];
//    self.foursquareRequest = [self.foursquare requestWithPath:@"venues/search" HTTPMethod:@"GET" parameters:parameters delegate:self];
//    [self.foursquareRequest start];
//    [self updateView];
//    [UIApplication sharedApplication].networkActivityIndicatorVisible = YES;
//}
//
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

//#pragma mark - BZFoursquareSessionDelegate
//
////- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare {
////    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:TAK_BZFoursquareAccessTokenRow inSection:TAK_BZFoursquareAuthenticationSection];
////    NSArray *indexPaths = [NSArray arrayWithObject:indexPath];
////    [self.tableView reloadRowsAtIndexPaths:indexPaths withRowAnimation:UITableViewRowAnimationNone];
////}
//
//- (void)foursquareDidAuthorize:(BZFoursquare *)foursquare
//{
//    [self.foursquareAuthorizationView removeFromSuperview];
//    [self generateInitialUI];
//}
//- (void)foursquareDidNotAuthorize:(BZFoursquare *)foursquare error:(NSDictionary *)errorInfo
//{
//    NSLog(@"%s: %@", __PRETTY_FUNCTION__, errorInfo);
//    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"Authorization Failed" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
//    [alertView show];
//}

@end
