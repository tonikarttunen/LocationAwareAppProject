//
//  TAKDetailViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/10/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKDetailViewController.h"
#import "Constants.h"
#import "TAKFoursquareCheckInViewController.h"
#import <QuartzCore/QuartzCore.h>
#import "APIConstants.h"
#import "TAKAppDelegate.h"
#import "TAKMapView.h"

#define TAK_GOOGLE_PLACE_DETAILS_BASE_URL @"https://maps.googleapis.com/maps/api/place/details/json?"
#define TAK_IMAGE_VIEW_TAG 50

@interface TAKDetailViewController ()

@property (nonatomic, copy) NSArray *tableViewContents; // Apple
@property (nonatomic, strong) NSMutableDictionary *tableViewContentDictionary; // Foursquare and Google
@property (nonatomic, copy) NSString *referenceID; // Google
@property (nonatomic, strong) NSMutableDictionary *searchResponse; // Google
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView; // Google

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) TAKMapView *mapView;
@property (nonatomic, strong) UIView *mapViewContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

@end

@implementation TAKDetailViewController
//{
//    CGFloat _imageHeight;
//    CGFloat _imageWidth;
//    CGFloat _rowHeight;
//}

// Apple
- (id)  initWithStyle:(UITableViewStyle)style
    tableViewContents:(NSArray *)tableViewContents
informationSourceType:(NSUInteger)informationSourceType
{
    self = [super init];
    if (self) {
        // Custom initialization
//        _imageWidth = 236.0f;
//        _imageHeight = 60.0f;
//        _rowHeight = 60.0f;
        _informationSourceType = informationSourceType;
        _tableViewContents = [tableViewContents copy];
        NSLog(@"%@", _tableViewContents);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

// Foursquare
- (id)           initWithStyle:(UITableViewStyle)style
    tableViewContentDictionary:(NSDictionary *)tableViewContentDictionary
         informationSourceType:(NSUInteger)informationSourceType
{
    self = [super init];
    if (self) {
        // Custom initialization
        _informationSourceType = informationSourceType;
        _tableViewContentDictionary = (NSMutableDictionary *)tableViewContentDictionary;
        NSLog(@"%@", _tableViewContentDictionary);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
        [self sendFoursquarePhotoRequest];
    }
    return self;
}

// Google
- (id)           initWithStyle:(UITableViewStyle)style
    tableViewContentDictionary:(NSDictionary *)tableViewContentDictionary
         informationSourceType:(NSUInteger)informationSourceType
                   referenceID:(NSString *)referenceID
{
    self = [super init];
    if (self) {
        // Custom initialization
        _referenceID = [referenceID copy];
        _informationSourceType = informationSourceType;
        _tableViewContentDictionary = (NSMutableDictionary *)tableViewContentDictionary;
        NSLog(@"%@", _tableViewContentDictionary);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
#ifdef DEBUG
        NSLog(@" Google Places reference ID: %@", _referenceID);
#endif
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self generateInitialUI];
    
    self.tableView.allowsSelection = NO;
    switch (self.informationSourceType) {
        case TAKInformationSourceTypeFoursquare: {
            [self.tableView setBackgroundView:nil];
            [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.91 alpha:1.0]];
            break;
        }
            
        case TAKInformationSourceTypeGoogle: {
            [self.tableView setBackgroundView:nil];
            [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.91 alpha:1.0]];
            
            if (!self.activityIndicatorView) {
                self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
            }
            self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
            [self.activityIndicatorView startAnimating];
            
            break;
        }
            
        default: { // Apple
            self.tableView.backgroundColor = [UIColor whiteColor];
            break;
        }
    }
    
    self.view.opaque = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if (self.informationSourceType == TAKInformationSourceTypeGoogle) {
        [self searchPlaceDetails];
    }
    
    NSLog(@"Detail view information source type: %i", self.informationSourceType);
    if (self.informationSourceType == TAKInformationSourceTypeFoursquare) {
        UIBarButtonItem *checkInButton = [[UIBarButtonItem alloc] initWithTitle:@"Check In" style:UIBarButtonItemStyleBordered target:self action:@selector(presentFoursquareCheckInViewController)];
        self.navigationItem.rightBarButtonItem = checkInButton;
    }
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
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
    _mapView.delegate = nil;
    _mapView = nil;
    _mapViewContainer = nil;
    _activityIndicatorView = nil;
    _tableViewContents = nil;
    _tableViewContentDictionary = nil;
    _foursquareCheckInViewController = nil;
    _scrollView = nil;
    _imageView = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    switch (self.informationSourceType) {
        case TAKInformationSourceTypeApple: {
            return 1;
        }
            
        case TAKInformationSourceTypeFoursquare: {
            return self.tableViewContentDictionary.count - 1;
            break;
        }
            
        default: { // Google
            return 5;
        }
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (self.informationSourceType) {
        case TAKInformationSourceTypeApple: {
            return self.tableViewContents.count;
        }
            
        case TAKInformationSourceTypeFoursquare: {
            NSArray *array;
            if (section == 0) {
                array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_BASIC_INFORMATION];
            } else if (section == 1) {
                array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_LOCATION];
            } else {
                array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_STATISTICS];
            }
//            else { // Photo
//                return 1;
//            }
            return array.count;
        }
            
        default: { // Google
#warning Incomplete implementation
            switch (section) {
                case 0:
                    return 2;
                    
                case 1:
                    return 3;
                    
                // reviews
                    
                    
                default:
                    return 3;
            }
        }
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier /* forIndexPath:indexPath */];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
//        [[cell.contentView viewWithTag:5] removeFromSuperview];
//        [[cell.contentView viewWithTag:6] removeFromSuperview];
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.16 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.opaque = NO;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        cell.textLabel.numberOfLines = 1;
        cell.textLabel.tag = 5;
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.opaque = NO;
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        cell.detailTextLabel.numberOfLines = 1;
        cell.detailTextLabel.tag = 6;
    }
//    else {
//        [[cell.contentView viewWithTag:TAK_IMAGE_VIEW_TAG] removeFromSuperview];
//    }
    
    @try {
        switch (self.informationSourceType) {
            case TAKInformationSourceTypeApple: {
                if (self.tableViewContents.count > 0) {
                    cell.textLabel.text = [[self.tableViewContents objectAtIndex:indexPath.row] objectAtIndex:0];
                    id obj = [[self.tableViewContents objectAtIndex:indexPath.row] objectAtIndex:1];
                    if ([obj isKindOfClass:[NSURL class]]) {
                        cell.detailTextLabel.text = [obj absoluteString];
                    } else {
                        if (([cell.textLabel.text isEqualToString:@"Latitude"])
                            || ([cell.textLabel.text isEqualToString:@"Longitude"])) {
                            cell.detailTextLabel.text = [NSString stringWithFormat:@"%@°", (NSString *)obj];
                        } else {
                            cell.detailTextLabel.text = (NSString *)obj;
                        }
                    }
                }
                break;
            }
                
            case TAKInformationSourceTypeFoursquare: {
                NSArray *array;
                if (indexPath.section == 0) {
                    array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_BASIC_INFORMATION];
                } else if (indexPath.section == 1) {
                    array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_LOCATION];
                } else if (indexPath.section == 2) {
                    array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_STATISTICS];
                } else {
                    array = [self.tableViewContentDictionary objectForKey:@"Image"];
                }
                
//                if (indexPath.section != 3) {
                cell.textLabel.text = (NSString *)[[array objectAtIndex:indexPath.row] objectAtIndex:0];
                id obj = [[array objectAtIndex:indexPath.row] objectAtIndex:1];
                if ([obj isKindOfClass:[NSNumber class]]) {
                    if (([cell.textLabel.text isEqualToString:@"Latitude"])
                        || ([cell.textLabel.text isEqualToString:@"Longitude"])) {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@°", (NSString *)[obj stringValue]];
                    } else if ([cell.textLabel.text isEqualToString:@"Distance"]) {
                        cell.detailTextLabel.text = [NSString stringWithFormat:@"%@m", (NSString *)[obj stringValue]];
                    } else {
                        cell.detailTextLabel.text = (NSString *)[obj stringValue];
                    }
                } else {
                    cell.detailTextLabel.text = (NSString *)obj;
                }
//                } else {
//                    // cell.detailTextLabel.text = @"";
//                    id obj = [array objectAtIndex:1];
//                    UIImageView *imageView = [[UIImageView alloc] initWithImage:(UIImage *)obj];
//                    if (isnan(_rowHeight)) {
//                        cell.contentView.frame = CGRectMake(0.0f, 0.0f, 300.0f, 60.0f);
//                    } else {
//                        cell.contentView.frame = CGRectMake(0.0f, 0.0f, 300.0f, _rowHeight);
//                        NSLog(@"cell.contentview...height: %f", _rowHeight);
//                    }
//                    imageView.frame = CGRectMake(0.0f, 0.0f, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
//                    imageView.tag = TAK_IMAGE_VIEW_TAG;
//                
//                    cell.imageView.layer.masksToBounds = YES;
//                    cell.imageView.layer.opaque = NO;
//                    imageView.layer.cornerRadius = 20;
//                    cell.contentView.layer.cornerRadius = 20;
//                    cell.contentView.layer.masksToBounds = YES;
//                    cell.contentView.layer.opaque = NO;
//                    [cell.contentView addSubview:imageView];
//                    cell.layer.cornerRadius = 20;
//                    cell.layer.masksToBounds = YES;
//                    cell.layer.opaque = NO;
//                }
                
                
                break;
            }
                
            case TAKInformationSourceTypeGoogle: {
// #warning Incomplete implementation
                switch (indexPath.section) {
                    case 0: {
                        if (indexPath.row == 1) {
                            cell.textLabel.text = @"Copyright text";
                        } else {
                            cell.textLabel.text = @" ";
                        }
                        break;
                    }
                        
                    case 1: {
                        if (indexPath.row == 0) {
                            cell.textLabel.text = @"Name";
                            cell.detailTextLabel.text = self.title;
                        } else if (indexPath.row == 1) {
                            cell.textLabel.text = @"Website";
                            cell.detailTextLabel.text = [self.tableViewContentDictionary objectForKey:@"website"];
                        } else if (indexPath.row == 2) {
                            cell.textLabel.text = @"Phone Number";
                            cell.detailTextLabel.text = [self.tableViewContentDictionary objectForKey:@"formatted_phone_number"];
                        } else {
                            cell.textLabel.text = @"Rating";
                            cell.detailTextLabel.text = [self.tableViewContentDictionary objectForKey:@"rating"];
                        }
                        break;
                    }
                        
                    case 2: {
                        if (indexPath.row == 0) {
                            cell.textLabel.text = @"Address";
                            cell.detailTextLabel.text = [self.tableViewContentDictionary objectForKey:@"vicinity"];
                        } else if (indexPath.row == 1) {
                            cell.textLabel.text = @"Latitude";
                            cell.detailTextLabel.text = [[[[self.tableViewContentDictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] stringValue];
                        } else {
                            cell.textLabel.text = @"Longitude";
                            cell.detailTextLabel.text = [[[[self.tableViewContentDictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] stringValue];
                        }
                        break;
                    }
                        
                    default: {
                        cell.textLabel.text = @" ";
                        cell.detailTextLabel.text = @" ";
                        break;
                    }
                }
                break;
            }
                
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
    
//    if (indexPath.row == 0 || indexPath.row == [tableView numberOfRowsInSection:indexPath.section]-1) {
//        UIView *view = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 200, 44)];
//        view.layer.cornerRadius = 4;
//        view.backgroundColor = [UIColor redColor];
//        cell.backgroundView = view;
//        //cell.backgroundColor = [UIColor clearColor];
//    }
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{    
    switch (self.informationSourceType) {
        case TAKInformationSourceTypeApple: {
            return @"";
        }
        
        case TAKInformationSourceTypeFoursquare: {
            switch (section) {
                case 0:
                    return TAK_FOURSQUARE_BASIC_INFORMATION;
                    
                case 1:
                    return TAK_FOURSQUARE_LOCATION;
                    
                default:
                    return TAK_FOURSQUARE_STATISTICS;
                    
//                default:
//                    return @"Photo";
            }
        }
            
        default: {
            switch (section) {
                case 0:
                    return @"Photo";
                
                case 1:
                    return @"Basic Information";
                    
                case 2:
                    return @"Location";
                    
                case 3:
                    return @"Opening Hours";
                    
                default:
                    return @"";
            }
        }
    }
}

//- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
//    
//    NSString *sectionTitle;
//    
//    if (self.informationSourceType != TAKInformationSourceTypeFoursquare) {
//        return nil;
//    }
//    switch (section) {
//        case 0:
//            sectionTitle = TAK_FOURSQUARE_BASIC_INFORMATION;
//            break;
//            
//        case 1:
//            sectionTitle = TAK_FOURSQUARE_LOCATION;
//            break;
//            
//        default:
//            sectionTitle = TAK_FOURSQUARE_STATISTICS;
//            break;
//    }
//    
//    UILabel *headerTitleLabel = [[UILabel alloc] init];
//    headerTitleLabel.text = sectionTitle;
//    headerTitleLabel.frame = CGRectMake(17.0f, 0.0f, 284.0f - 17.0f, 21.0f);
//    headerTitleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18];
//    headerTitleLabel.textColor = [UIColor blackColor];
//    
//    headerTitleLabel.backgroundColor = [UIColor clearColor];
//    
//    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 270.0f, 100.0f)];
//    [headerView addSubview:headerTitleLabel];
//    
//    return headerView;
//}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0f;
    
//    switch (self.informationSourceType) {
//        case TAKInformationSourceTypeFoursquare:
//            switch (indexPath.section) {
//                case 3: {
//                    _rowHeight = (300.0f * _imageHeight / _imageWidth);
//                    NSLog(@"ROW HEIGHT: %f", _rowHeight);
//                    if (isnan(_rowHeight)) {
//                        return 60.0f;
//                    } else {
//                        return (300.0f * _imageHeight / _imageWidth);
//                    }
//                }
//                    
//                default: {
//                    return 60.0f;
//                }
//            }
//            break;
//            
//        default: {
//            return 60.0f;
//        }
//    }
}

#pragma mark - Foursquare check-in

- (void)presentFoursquareCheckInViewController
{
    NSArray *array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_BASIC_INFORMATION];
    NSString *venueID = (NSString *)[[array objectAtIndex:1] objectAtIndex:1];
#ifdef DEBUG
    NSLog(@"Foursquare venue ID: %@", venueID);
#endif
    self.foursquareCheckInViewController = [[TAKFoursquareCheckInViewController alloc] initWithStyle:UITableViewStyleGrouped foursquareVenueID:venueID];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:self.foursquareCheckInViewController];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navigationController animated:YES completion:NULL];
}

//- (void)updateCheckInCount
//{
//    @try {
//        NSArray *array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_STATISTICS];
//        
//        int checkIns = [[[array objectAtIndex:0] objectAtIndex:1] integerValue];
//        checkIns += 1;
//        int users = [[[array objectAtIndex:1] objectAtIndex:1] integerValue];
//        users += 1;
//        
//        NSLog(@"New checkInsCount: %i", checkIns);
//        
//        [[[self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_STATISTICS] objectAtIndex:0] replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:checkIns]];
//        [[[self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_STATISTICS] objectAtIndex:1] replaceObjectAtIndex:1 withObject:[NSNumber numberWithInt:users]];
//        
//        [self.tableView reloadData];
//        NSLog(@"RELOADED THE DATA");
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Cannot update the table view after a Foursquare check-in");
//    }
//}

#pragma mark - Foursquare photos

- (void)sendFoursquarePhotoContentRequestWithURLString:(NSString *)URLString
{
    @try {
        NSArray *array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_BASIC_INFORMATION];
        NSString *venueID = (NSString *)[[array objectAtIndex:1] objectAtIndex:1];
#ifdef DEBUG
        NSLog(@"Foursquare venue ID: %@", venueID);
#endif
        NSString *requestURLString = [URLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *requestURL = [NSURL URLWithString:requestURLString];
#ifdef DEBUG
        NSLog(@"Foursquare photo request URL: %@", requestURL);
#endif
        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestURL];
        [urlRequest setHTTPMethod:@"GET"];
        [urlRequest setTimeoutInterval:30.0f];

        NSOperationQueue *queue = [[NSOperationQueue alloc] init];

        [NSURLConnection sendAsynchronousRequest:urlRequest
                                           queue:queue
                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
        {
            if ((error == nil) && ([data length] > 0))
            {
                UIImage *image = [UIImage imageWithData:data];
                // [self.imageView removeFromSuperview];
                
                self.imageView = [[UIImageView alloc] initWithImage:image];
//                _imageHeight = image.size.height;
//                _imageWidth = image.size.width;
                [[self.tableViewContentDictionary objectForKey:@"Image"] replaceObjectAtIndex:1 withObject:image];
                CGFloat imageHeight = image.size.height;
                CGFloat imageWidth = image.size.width;
                CGFloat imageHeightInUI = 320.0f * imageHeight / imageWidth;
                self.imageView.frame = CGRectMake(0.0f, 0.0f, 320.0f, imageHeightInUI);
                [self.activityIndicatorView stopAnimating];
                [self.activityIndicatorView removeFromSuperview];
                [self.scrollView addSubview:self.imageView];
                // [self.tableView reloadData];
                self.scrollView.contentSize = CGSizeMake(320.0f, imageHeightInUI);
                NSLog(@"Image: %@, self.imageView.frame: %@, contentSize: %@", image, NSStringFromCGRect(self.imageView.frame), NSStringFromCGSize(self.scrollView.contentSize));
            }
        }];
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot download the Foursquare venue photo: %@", exception.description);
    }
}

- (void)sendFoursquarePhotoRequest
{
    @try {
//        NSArray *array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_BASIC_INFORMATION];
//        NSString *venueID = (NSString *)[[array objectAtIndex:1] objectAtIndex:1];
//#ifdef DEBUG
//        NSLog(@"Foursquare venue ID: %@", venueID);
//#endif
//        NSString *requestURLString = [NSString stringWithFormat:@"https://api.foursquare.com/v2/venues/%@/photos?group=venue&limit=1&oauth_token=%@&v=20130420", venueID, TAK_FOURSQUARE_API_KEY];
//        NSURL *requestURL = [NSURL URLWithString:requestURLString];
//#ifdef DEBUG
//        NSLog(@"Foursquare photo request URL: %@", requestURL);
//#endif
//        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:requestURL];
//        [urlRequest setHTTPMethod:@"GET"];
//        [urlRequest setTimeoutInterval:30.0f];
//        
//        NSOperationQueue *queue = [[NSOperationQueue alloc] init];
//        
//        [NSURLConnection sendAsynchronousRequest:urlRequest
//                                           queue:queue
//                               completionHandler:^(NSURLResponse *response, NSData *data, NSError *error)
//        {
//            if ((error == nil) && ([data length] > 0))
//            {
//                id responseJSON = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
//                
//                if (error) {
//                    NSLog(@"An error occurred while downloading the image: %@", error.description);
//                }
//                
//                if ([responseJSON isKindOfClass:[NSNull class]]) {
//                    NSLog(@"No data!");
//                }
//                
//                if ([responseJSON isKindOfClass:[NSDictionary class]]) {
//                    NSDictionary *response = [responseJSON objectForKey:@"response"];
//                    NSLog(@"response: %@", response);
//                    
//                }
//            }
//        }];
        
        
        ////
        
        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        if (appDelegate && appDelegate.foursquareController && appDelegate.foursquareController.foursquare) {
            NSArray *array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_BASIC_INFORMATION];
            NSString *venueID = (NSString *)[[array objectAtIndex:1] objectAtIndex:1];
#ifdef DEBUG
            NSLog(@"Foursquare venue ID: %@", venueID);
#endif
            [appDelegate.foursquareController searchFoursquarePhotosWithID:venueID limit:@"1" group:@"venue"];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot download the Foursquare venue photo: %@", exception.description);
    }
}

- (void)showNoPhotosLabel
{
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(10.0f, 135.0f, 300.0f, 40.0f)];
    label.text = @"No Photos Available";
    label.textColor = [UIColor colorWithWhite:0.2 alpha:1.0];
    label.font = [UIFont fontWithName:@"Helvetica-NeueBold" size:36.0f];
    label.textAlignment = NSTextAlignmentCenter;
    [self.scrollView addSubview:label];
}

#pragma mark - Google Places: place details

- (void)handleRequestData:(NSData *)data
{
    NSError *error;
    
    id response = [NSJSONSerialization JSONObjectWithData:data options:kNilOptions error:&error];
    
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
        NSDictionary *searchResult = [self.searchResponse objectForKey:@"result"];
        
        if (self.tableView != nil) {
            self.tableViewContentDictionary = (NSMutableDictionary *)searchResult;
            NSLog(@"searchResult: %@", searchResult);
            [self.tableView reloadData];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
    [self.activityIndicatorView stopAnimating];
    self.activityIndicatorView.hidden = YES;
}

- (void)searchPlaceDetails
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
//        if ((parameters == nil) || (parameters.count == 0)) {
//            NSLog(@"No parameters were given!");
//            return;
//        }
        
//        double latitude = [[parameters objectForKey:@"Latitude"] doubleValue];
//        double longitude = [[parameters objectForKey:@"Longitude"] doubleValue];
//        int radius = [[parameters objectForKey:@"Radius"] integerValue];
//        NSString *types = [parameters objectForKey:@"Types"];
        // NSString *openNow = [parameters objectForKey:@"Open Now"];
        
        NSString *searchURLString = [NSString stringWithFormat:@"%@key=%@&reference=%@&sensor=true",
                                     TAK_GOOGLE_PLACE_DETAILS_BASE_URL,
                                     TAK_GOOGLE_PLACES_API_KEY,
                                     self.referenceID];
        NSString *searchURLStringWithPercentEscapes = [searchURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *searchURL = [NSURL URLWithString:searchURLStringWithPercentEscapes];
        
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

#pragma mark - UI

- (void)generateInitialUI
{
    // [self setViewBasicProperties];
    [self generateScrollView];
    [self generateToolbar];
    [self generateTableView];
    
    if (self.informationSourceType == TAKInformationSourceTypeGoogle) {
        if (!self.activityIndicatorView) {
            self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
        }
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
}

//- (void)setViewBasicProperties
//{
//    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
//    self.view.backgroundColor = [UIColor whiteColor];
//    self.view.opaque = YES;
//}

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
    NSArray *segmentedControlItems;
    if (self.informationSourceType == TAKInformationSourceTypeApple) {
        segmentedControlItems = @[@"Info", @"Map"];
    } else {
        segmentedControlItems = @[@"Info", @"Map", @"Photo"];
    }
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
    self.tableView = [[UITableView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT) style:((self.informationSourceType == TAKInformationSourceTypeApple) ? UITableViewStylePlain : UITableViewStyleGrouped)];
    self.tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    self.tableView.dataSource = self;
    self.tableView.delegate = self;
    
//    @try {
//        if ((self.venues != nil) && (self.venues.count > 0)) {
//            self.tableView.tableViewContents = (NSMutableArray *)self.venues;
//            [self.tableView reloadData];
//        }
//    }
//    @catch (NSException *exception) {
//        NSLog(@"Cannot create a table view: %@", exception. description);
//    }
    [self.view addSubview:self.tableView];
}

- (void)generateScrollView
{
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - (TAK_STANDARD_TOOLBAR_HEIGHT * 2))];
    self.scrollView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:1.0];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.scrollView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    if (self.informationSourceType == TAKInformationSourceTypeFoursquare) {
        self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        self.activityIndicatorView.frame = CGRectMake(150.0f, 135.0f, 20.0f, 20.0f);
        [self.scrollView addSubview:self.activityIndicatorView];
        [self.activityIndicatorView startAnimating];
    }
    
//    [self.view addSubview:self.scrollView];
    
//    NSArray *array = [self.tableViewContentDictionary objectForKey:@"Image"];
//    UIImage *image = [array objectAtIndex:1];
//    UIImageView *imageView = [[UIImageView alloc] initWithImage:image];
//    CGFloat imageHeight = image.size.height;
//    CGFloat imageWidth = image.size.width;
//    CGFloat imageHeightInUI = self.view.bounds.size.width * imageHeight / imageWidth;
//    imageView.frame = CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, imageHeightInUI);
//    imageView.opaque = YES;
//    [self.scrollView addSubview:self.imageView];
    
    //                    imageView.tag = TAK_IMAGE_VIEW_TAG;
    //
    //                    cell.imageView.layer.masksToBounds = YES;
    //                    cell.imageView.layer.opaque = NO;
    //                    imageView.layer.cornerRadius = 20;
    //                    cell.contentView.layer.cornerRadius = 20;
    //                    cell.contentView.layer.masksToBounds = YES;
    //                    cell.contentView.layer.opaque = NO;
    //                    [cell.contentView addSubview:imageView];
    //                    cell.layer.cornerRadius = 20;
    //                    cell.layer.masksToBounds = YES;
    //                    cell.layer.opaque = NO;
    
    
//    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width, imageHeightInUI);
}

- (void)generateMapView
{
    self.mapViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT)];
    self.mapViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapViewContainer];
    
    self.mapView = [[TAKMapView alloc] initWithFrame:self.mapViewContainer.bounds];
    self.mapView.informationSourceType = TAKInformationSourceTypeFoursquare;
    [self.mapViewContainer addSubview:self.mapView];
    
    if (self.informationSourceType == TAKInformationSourceTypeFoursquare) {
        UIImageView *foursquareImagView = [[UIImageView alloc] initWithFrame:CGRectMake((self.mapViewContainer.frame.size.width -236.0f) / 2.0f, self.mapViewContainer.frame.size.height - 44.0f, 236.0f, 60.0f)];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"poweredByFoursquare" ofType:@"png"];
        foursquareImagView.image = [[UIImage alloc] initWithContentsOfFile:path];
        foursquareImagView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.mapViewContainer addSubview:foursquareImagView];
    }
    
    switch (self.informationSourceType) {
        case TAKInformationSourceTypeApple: {
            MKPointAnnotation *annotation = [[MKPointAnnotation alloc] init];
            annotation.title = self.title;
            
            @try {
                annotation.subtitle = [[self.tableViewContents objectAtIndex:1] objectAtIndex:1];
                CLLocationDegrees latitude;
                CLLocationDegrees longitude;
                
                for (int i = 0; i < self.tableViewContents.count; i++) {
                    id obj = [[self.tableViewContents objectAtIndex:i] objectAtIndex:0];
                    if ([obj isKindOfClass:[NSURL class]]) {
                        continue;
                    } else {
                        if ([(NSString *)obj isEqualToString:@"Latitude"]) {
                            latitude = (CLLocationDegrees)[[[self.tableViewContents objectAtIndex:i] objectAtIndex:1] doubleValue];
                        } else if ([(NSString *)obj isEqualToString:@"Longitude"]) {
                            longitude = (CLLocationDegrees)[[[self.tableViewContents objectAtIndex:i] objectAtIndex:1] doubleValue];
                        }
                    }
                }
                annotation.coordinate = CLLocationCoordinate2DMake(latitude, longitude);
                
                [self.mapView addAnnotation:annotation];
                [self.mapView selectAnnotation:annotation animated:YES];
            }
            @catch (NSException *exception) {
                NSLog(@"Cannot add an annotation to the map: %@", exception.description);
            }
            
            break;
        }
            
        case TAKInformationSourceTypeFoursquare: {
            NSArray *array = @[self.tableViewContentDictionary];
            [self.mapView refreshMapAnnotationsWithArray:array informationSource:TAKInformationSourceTypeFoursquare];
            break;
        }
            
        default: { // Google
#warning Incomplete implementation
            
            break;
        }
    }
}

#pragma mark - Segmented control actions

- (void)segmentedControlValueChanged:(id)sender
{
    switch (self.segmentedControl.selectedSegmentIndex) {
        case 0: {
            // Swap the view if necessary
            if (self.tableView == nil) {
                [self generateTableView];
            }
            if (self.mapView != nil) {
                self.mapView.hidden = YES;
                self.mapViewContainer.hidden = YES;
            }
            if (self.scrollView != nil) {
                self.scrollView.hidden = YES;
            }
            self.tableView.hidden = NO;
            break;
        }
        case 1: {
            // Swap the view if necessary
            if (self.mapView == nil) {
                [self generateMapView];
            }
            if (self.tableView != nil) {
                self.tableView.hidden = YES;
            }
            if (self.scrollView) {
                self.scrollView.hidden = YES;
            }
            self.mapView.hidden = NO;
            self.mapViewContainer.hidden = NO;
            break;
        }
        default: {
            // Swap the view if necessary
            if (self.scrollView == nil) {
                [self generateScrollView];
            }
            if (self.mapView != nil) {
                self.mapView.hidden = YES;
                self.mapViewContainer.hidden = YES;
            }
            if (self.tableView != nil) {
                self.tableView.hidden = YES;
            }
            [self.view addSubview:self.scrollView];
            self.scrollView.hidden = NO;
            break;
        }
    }
}


@end
