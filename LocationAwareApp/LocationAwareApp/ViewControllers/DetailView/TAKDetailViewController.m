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

#define TAK_GOOGLE_PLACE_DETAILS_BASE_URL @"https://maps.googleapis.com/maps/api/place/details/json?"
#define TAK_IMAGE_VIEW_TAG 50

@interface TAKDetailViewController ()

@property (nonatomic, copy) NSArray *tableViewContents; // Apple
@property (nonatomic, strong) NSMutableDictionary *tableViewContentDictionary; // Foursquare and Google
@property (nonatomic, copy) NSString *referenceID; // Google
@property (nonatomic, strong) NSMutableDictionary *searchResponse; // Google
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView; // Google

@end

@implementation TAKDetailViewController
{
    CGFloat _imageHeight;
    CGFloat _imageWidth;
    CGFloat _rowHeight;
}

// Apple
- (id)  initWithStyle:(UITableViewStyle)style
    tableViewContents:(NSArray *)tableViewContents
informationSourceType:(NSUInteger)informationSourceType
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _imageWidth = 236.0f;
        _imageHeight = 60.0f;
        _rowHeight = 60.0f;
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
    self = [super initWithStyle:style];
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
    self = [super initWithStyle:style];
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
    _tableViewContents = nil;
    _tableViewContentDictionary = nil;
    _foursquareCheckInViewController = nil;
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
            return self.tableViewContentDictionary.count;
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
            } else if (section == 2) {
                array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_STATISTICS];
            } else { // Photo
                return 1;
            }
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
    } else {
        [[cell.contentView viewWithTag:TAK_IMAGE_VIEW_TAG] removeFromSuperview];
    }
    
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
                
                if (indexPath.section != 3) {
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
                } else {
                    // cell.detailTextLabel.text = @"";
                    id obj = [array objectAtIndex:1];
                    UIImageView *imageView = [[UIImageView alloc] initWithImage:(UIImage *)obj];
                    if (isnan(_rowHeight)) {
                        cell.contentView.frame = CGRectMake(0.0f, 0.0f, 300.0f, 60.0f);
                    } else {
                        cell.contentView.frame = CGRectMake(0.0f, 0.0f, 300.0f, _rowHeight);
                        NSLog(@"cell.contentview...height: %f", _rowHeight);
                    }
                    imageView.frame = CGRectMake(0.0f, 0.0f, cell.contentView.frame.size.width, cell.contentView.frame.size.height);
                    imageView.tag = TAK_IMAGE_VIEW_TAG;
                
                    cell.imageView.layer.masksToBounds = YES;
                    cell.imageView.layer.opaque = NO;
                    imageView.layer.cornerRadius = 20;
                    cell.contentView.layer.cornerRadius = 20;
                    cell.contentView.layer.masksToBounds = YES;
                    cell.contentView.layer.opaque = NO;
                    [cell.contentView addSubview:imageView];
                    cell.layer.cornerRadius = 20;
                    cell.layer.masksToBounds = YES;
                    cell.layer.opaque = NO;
                }
                
                
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
                    
                case 2:
                    return TAK_FOURSQUARE_STATISTICS;
                    
                default:
                    return @"Photo";
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
    switch (self.informationSourceType) {
        case TAKInformationSourceTypeFoursquare:
            switch (indexPath.section) {
                case 3: {
                    _rowHeight = (300.0f * _imageHeight / _imageWidth);
                    NSLog(@"ROW HEIGHT: %f", _rowHeight);
                    if (isnan(_rowHeight)) {
                        return 60.0f;
                    } else {
                        return (300.0f * _imageHeight / _imageWidth);
                    }
                }
                    
                default: {
                    return 60.0f;
                }
            }
            break;
            
        default: {
            return 60.0f;
        }
    }
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
                _imageHeight = image.size.height;
                _imageWidth = image.size.width;
                [[self.tableViewContentDictionary objectForKey:@"Image"] replaceObjectAtIndex:1 withObject:image];
                [self.tableView reloadData];
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

@end
