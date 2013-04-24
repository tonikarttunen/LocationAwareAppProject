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
#define TAK_GOOGLE_PLACE_PHOTOS_BASE_URL  @"https://maps.googleapis.com/maps/api/place/photo?"
// #define TAK_IMAGE_VIEW_TAG 50

@interface TAKDetailViewController ()

@property (nonatomic, copy) NSArray *tableViewContents; // Apple
@property (nonatomic, strong) NSMutableDictionary *tableViewContentDictionary; // Foursquare and Google
@property (nonatomic, copy) NSString *referenceID; // Google
@property (nonatomic, strong) NSMutableDictionary *searchResponse; // Google
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView; // Google

@property (nonatomic, strong) UIToolbar *toolbar;
@property (nonatomic, strong) UISegmentedControl *segmentedControl;
@property (nonatomic, strong) UISegmentedControl *mapTypeSegmentedControl;
@property (nonatomic, strong) UIView *mapViewContainer;
@property (nonatomic, strong) UITableView *tableView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIImageView *imageView;

#ifndef TAK_GOOGLE
@property (nonatomic, strong) TAKMapView *mapView;
#else
@property (nonatomic, strong) GMSMapView *mapView;
#endif

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
//#ifdef DEBUG
//        NSLog(@" Google Places reference ID: %@", _referenceID);
//#endif
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
    
    // NSLog(@"Detail view information source type: %i", self.informationSourceType);
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
    _mapTypeSegmentedControl = nil;
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
            return 3;
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
            return array.count;
        }
            
        default: { // Google
            switch (section) {
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
        // cell.textLabel.tag = 5;
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.opaque = NO;
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        cell.detailTextLabel.numberOfLines = 1;
        
        // cell.detailTextLabel.tag = 6;
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
                break;
            }
                
            case TAKInformationSourceTypeGoogle: {
                switch (indexPath.section) {
                    case 0: {
                        if (indexPath.row == 0) {
                            cell.textLabel.text = @"Name";
                            NSString *name = self.title;
                            if (name) {
                                cell.detailTextLabel.text = name;
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        } else if (indexPath.row == 1) {
                            cell.textLabel.text = @"Website";
                            NSString *website = [self.tableViewContentDictionary objectForKey:@"website"];
                            if (website) {
                                cell.detailTextLabel.text = website;
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        } else if (indexPath.row == 2) {
                            cell.textLabel.text = @"Phone Number";
                            NSString *phone = [self.tableViewContentDictionary objectForKey:@"formatted_phone_number"];
                            if (phone) {
                                cell.detailTextLabel.text = phone;
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        } else {
                            cell.textLabel.text = @"Rating";
                            NSString *rating = [self.tableViewContentDictionary objectForKey:@"rating"];
                            if (rating) {
                                cell.detailTextLabel.text = rating;
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        }
                        break;
                    }
                        
                    case 1: {
                        if (indexPath.row == 0) {
                            cell.textLabel.text = @"Address";
                            NSString *address = [self.tableViewContentDictionary objectForKey:@"vicinity"];
                            if (address) {
                                cell.detailTextLabel.text = address;
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        } else if (indexPath.row == 1) {
                            cell.textLabel.text = @"Latitude";
                            NSString *coordinate = [[[[self.tableViewContentDictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] stringValue];
                            if (coordinate) {
                                cell.detailTextLabel.text = coordinate;
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        } else {
                            cell.textLabel.text = @"Longitude";
                            NSString *coordinate = [[[[self.tableViewContentDictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] stringValue];
                            if (coordinate) {
                                cell.detailTextLabel.text = coordinate;
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        }
                        break;
                    }
                        
                    default: {
                        NSArray *reviews = [self.tableViewContentDictionary objectForKey:@"reviews"];
//                        if ((reviews == nil) || ([reviews isKindOfClass:[NSNull class]]) || (reviews.count < 1)) {
//                            break;
//                        }
                        
                        NSDictionary *review1 = [reviews objectAtIndex:0];
//                        if ((review1 == nil) || ([review1 isKindOfClass:[NSNull class]]) || (review1.count < 1)) {
//                            break;
//                        }
                        
                        if (indexPath.row == 0) {
                            cell.textLabel.text = @"Author name";
                            NSString *author = [review1 objectForKey:@"author_name"];
                            if (author) {
                                cell.detailTextLabel.text = author;
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        } else if (indexPath.row == 1) {
                            cell.detailTextLabel.numberOfLines = 0;
                            cell.textLabel.text = @"Rating";
                            // NSString *rating = [[[[review1 objectForKey:@"aspects"] objectAtIndex:0] objectForKey:@"rating"] stringValue];
                            
                            NSMutableArray *ratings = [NSMutableArray new];
                            for (int i = 0; i < [[review1 objectForKey:@"aspects"] count]; i++) {
                                
                                NSString *type = [[[review1 objectForKey:@"aspects"] objectAtIndex:i] objectForKey:@"type"];
                                NSString *rating = [[[[review1 objectForKey:@"aspects"] objectAtIndex:i] objectForKey:@"rating"] stringValue];
                                
                                if (type && rating) {
                                    [ratings addObject:type];
                                    [ratings addObject:@": "];
                                    [ratings addObject:rating];
                                    if (i != ([[review1 objectForKey:@"aspects"] count] - 1)) {
                                        [ratings addObject:@", "];
                                    }
                                }
                            }
                            
                            if (ratings && (ratings.count > 0)) {
                                cell.detailTextLabel.text = [ratings componentsJoinedByString:@""];
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        } else {
                            cell.detailTextLabel.numberOfLines = 0;
                            cell.textLabel.text = @"Text";
                            NSString *text = [review1 objectForKey:@"text"];
                            if (text && (![text isEqualToString:@""])) {
                                cell.detailTextLabel.text = text;
                            } else {
                                cell.detailTextLabel.text = @"N/A";
                            }
                        }
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
                    return @"Basic Information";
                    
                case 1:
                    return @"Location";
                    
                default:
                    return @"Review";
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
        case TAKInformationSourceTypeGoogle: {
            @try {
                if ((indexPath.section == 2) && (indexPath.row == 1)) {
                    NSString *cellText;
                    NSDictionary *review1 = [[self.tableViewContentDictionary objectForKey:@"reviews"] objectAtIndex:0];
                    
                    NSMutableArray *ratings = [NSMutableArray new];
                    for (int i = 0; i < [[review1 objectForKey:@"aspects"] count]; i++) {
                        
                        NSString *type = [[[review1 objectForKey:@"aspects"] objectAtIndex:i] objectForKey:@"type"];
                        NSString *rating = [[[[review1 objectForKey:@"aspects"] objectAtIndex:i] objectForKey:@"rating"] stringValue];
                        
                        if (type && rating) {
                            [ratings addObject:type];
                            [ratings addObject:@": "];
                            [ratings addObject:rating];
                            if (i != ([[review1 objectForKey:@"aspects"] count] - 1)) {
                                [ratings addObject:@", "];
                            }
                        }
                    }
                    
                    if (ratings && (ratings.count > 0)) {
                        cellText = [ratings componentsJoinedByString:@""];
                    } else {
                        return 60.0f;
                    }
                    
                    CGSize labelSize = [cellText sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]
                                            constrainedToSize:CGSizeMake(self.view.bounds.size.width - 45.0f, MAXFLOAT)
                                                lineBreakMode:NSLineBreakByWordWrapping];
                    
                    // NSLog(@"CELL TEXT: %@, label height: %f", cellText, labelSize.height);
                    
                    if ((labelSize.height + 48.0f) < 60.0f) {
                        return 60.0f;
                    } else {
                        return labelSize.height + 48.0f;
                    }
                } else if ((indexPath.section == 2) && (indexPath.row == 2)) {
                    NSDictionary *review1 = [[self.tableViewContentDictionary objectForKey:@"reviews"] objectAtIndex:0];
                    NSString *cellText = [review1 objectForKey:@"text"];
                    
                    CGSize labelSize = [cellText sizeWithFont:[UIFont fontWithName:@"HelveticaNeue-Light" size:16.0]
                                            constrainedToSize:CGSizeMake(self.view.bounds.size.width - 45.0f, MAXFLOAT)
                                                lineBreakMode:NSLineBreakByWordWrapping];
                    
                    // NSLog(@"CELL TEXT: %@, label height: %f", cellText, labelSize.height);
                    
                    if ((labelSize.height + 48.0f) < 60.0f) {
                        return 60.0f;
                    } else {
                    return labelSize.height + 48.0f;
                    }
                } else {
                    return 60.0f;
                }
            }
            @catch (NSException *exception) {
                NSLog(@"%@", exception.description);
                return 60.0f;
            }
        }
            
        default:
            return 60.0f;
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
        // Download the data asynchronously
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *requestData = [NSData dataWithContentsOfURL:requestURL];
            [self performSelectorOnMainThread:@selector(handleFoursquarePhotoRequestData:) withObject:requestData waitUntilDone:YES];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot download the Foursquare venue photo: %@", exception.description);
    }
}

- (void)handleFoursquarePhotoRequestData:(NSData *)data
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
    
    if ((error == nil) && ([data length] > 0))
    {
        UIImage *image = [UIImage imageWithData:data];
        // [self.imageView removeFromSuperview];
        
        self.imageView = [[UIImageView alloc] initWithImage:image];
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
}

- (void)sendFoursquarePhotoRequest
{
    @try {
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
    
    if (!data) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Complete the Request" message:@"" delegate:self cancelButtonTitle:@"Dismiss" otherButtonTitles:nil];
        [alert show];
        [self showNoPhotosLabel];
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
        [self showNoPhotosLabel];
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
    
    NSLog(@"Google Places JSON response: %@\n\n", response);
    
    if ([response isKindOfClass:[NSNull class]]) {
        return;
    }
    
    self.searchResponse = response;
    
    @try {
        NSDictionary *searchResult = [self.searchResponse objectForKey:@"result"];
        
        if (self.tableView != nil) {
            self.tableViewContentDictionary = (NSMutableDictionary *)searchResult;
            // NSLog(@"searchResult: %@", searchResult);
            [self.tableView reloadData];
            
            NSArray *photos = [searchResult objectForKey:@"photos"];
            if (photos && (![photos isKindOfClass:[NSNull class]]) && (photos.count > 0)) {
                NSDictionary *photo1 = [photos objectAtIndex:0];
                if (!photo1) {
                    [self showNoPhotosLabel];
                } else {
                    NSString *photoReference = [photo1 objectForKey:@"photo_reference"];
                    if (photoReference && (![photoReference isEqualToString:@""])) {
                        [self retrieveGooglePlacesPhotoWithPhotoReference:photoReference];
                    }
                }
            } else {
                [self showNoPhotosLabel];
            }
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
        NSString *searchURLString = [NSString stringWithFormat:@"%@key=%@&reference=%@&sensor=true",
                                     TAK_GOOGLE_PLACE_DETAILS_BASE_URL,
                                     TAK_GOOGLE_PLACES_API_KEY,
                                     self.referenceID];
        NSString *searchURLStringWithPercentEscapes = [searchURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *searchURL = [NSURL URLWithString:searchURLStringWithPercentEscapes];
        
//#ifdef DEBUG
//        NSLog(@"Google Places search URL: %@", searchURL);
//#endif
        
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

#pragma mark - Google Places photos

- (void)retrieveGooglePlacesPhotoWithPhotoReference:(NSString *)reference
{
    @try {
        NSString *searchURLString = [NSString stringWithFormat:@"%@key=%@&photoreference=%@&sensor=true&maxheight=800&maxwidth=800",
                                     TAK_GOOGLE_PLACE_PHOTOS_BASE_URL,
                                     TAK_GOOGLE_PLACES_API_KEY,
                                     reference];
        NSString *searchURLStringWithPercentEscapes = [searchURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSURL *searchURL = [NSURL URLWithString:searchURLStringWithPercentEscapes];
        
//#ifdef DEBUG
//        NSLog(@"Google Places search URL: %@", searchURL);
//#endif
        
        // Download the data asynchronously
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            NSData *requestData = [NSData dataWithContentsOfURL:searchURL];
            [self performSelectorOnMainThread:@selector(handlePhotoRequestData:) withObject:requestData waitUntilDone:YES];
        });
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
        [self.activityIndicatorView stopAnimating];
        self.activityIndicatorView.hidden = YES;
    }
}

- (void)handlePhotoRequestData:(NSData *)data
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
    
    if ((error == nil) && ([data length] > 0))
    {
        UIImage *image = [UIImage imageWithData:data];
        // [self.imageView removeFromSuperview];
        
        self.imageView = [[UIImageView alloc] initWithImage:image];
        CGFloat imageHeight = image.size.height;
        CGFloat imageWidth = image.size.width;
        CGFloat imageHeightInUI = 320.0f * imageHeight / imageWidth;
        self.imageView.frame = CGRectMake(0.0f, 0.0f, 320.0f, imageHeightInUI);
        [self.activityIndicatorView stopAnimating];
        [self.activityIndicatorView removeFromSuperview];
        [self.scrollView addSubview:self.imageView];
        // [self.tableView reloadData];
        self.scrollView.contentSize = CGSizeMake(320.0f, imageHeightInUI);
        // NSLog(@"Image: %@, self.imageView.frame: %@, contentSize: %@", image, NSStringFromCGRect(self.imageView.frame), NSStringFromCGSize(self.scrollView.contentSize));
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

- (void)generateMapTypeSegmentedControl
{
    NSArray *segmentedControlItems;
    if (self.informationSourceType == TAKInformationSourceTypeGoogle) {
        segmentedControlItems = @[@"Standard", @"Hybrid", @"Satellite", @"Terrain"];
    } else {
        segmentedControlItems = @[@"Standard", @"Hybrid", @"Satellite"];
    }
    self.mapTypeSegmentedControl = [[UISegmentedControl alloc] initWithItems:segmentedControlItems];
    self.mapTypeSegmentedControl.frame = CGRectMake(60.0f, self.mapViewContainer.bounds.size.height -  31.0f - 6.0f, self.view.bounds.size.width - 60.0f - 6.0f, TAK_SEGMENTED_CONTROL_HEIGHT);
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
    [self.mapViewContainer addSubview:self.mapTypeSegmentedControl];
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
}

- (void)generateMapView
{
    self.mapViewContainer = [[UIView alloc] initWithFrame:CGRectMake(0.0f, TAK_STANDARD_TOOLBAR_HEIGHT, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT)];
    self.mapViewContainer.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:self.mapViewContainer];
    
#ifdef TAK_GOOGLE
    @try {
        CLLocationDegrees latitude = (CLLocationDegrees)[[[[self.tableViewContentDictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
        CLLocationDegrees longitude = (CLLocationDegrees)[[[[self.tableViewContentDictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
        GMSCameraPosition *camera = [GMSCameraPosition cameraWithLatitude:latitude
                                                                longitude:longitude
                                                                     zoom:12.0];
        self.mapView = [[GMSMapView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, self.view.bounds.size.width, self.view.bounds.size.height - TAK_STANDARD_TOOLBAR_HEIGHT)];
        self.mapView.camera = camera;
        self.mapView.myLocationEnabled = YES;
        self.mapView.trafficEnabled = YES;
        self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        // self.mapView.delegate = self;
        [self.mapViewContainer addSubview:self.mapView];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
#else
    self.mapView = [[TAKMapView alloc] initWithFrame:self.mapViewContainer.bounds];
    self.mapView.informationSourceType = TAKInformationSourceTypeFoursquare;
    [self.mapViewContainer addSubview:self.mapView];
#endif
    
    [self generateMapTypeSegmentedControl];
    
    if (self.informationSourceType == TAKInformationSourceTypeFoursquare) {
        UIImageView *foursquareImageView = [[UIImageView alloc] initWithFrame:CGRectMake(/* (self.mapViewContainer.frame.size.width -236.0f) / 2.0f*/ 69.0f, self.mapViewContainer.frame.size.height - 44.0f - 42.0f, 236.0f, 60.0f)];
        NSString *path = [[NSBundle mainBundle] pathForResource:@"poweredByFoursquare" ofType:@"png"];
        foursquareImageView.image = [[UIImage alloc] initWithContentsOfFile:path];
        foursquareImageView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin | UIViewAutoresizingFlexibleTopMargin;
        [self.mapViewContainer addSubview:foursquareImageView];
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
#ifndef TAK_GOOGLE
                [self.mapView addAnnotation:annotation];
                [self.mapView selectAnnotation:annotation animated:YES];
#endif
            }
            @catch (NSException *exception) {
                NSLog(@"Cannot add an annotation to the map: %@", exception.description);
            }
            
            break;
        }
            
        case TAKInformationSourceTypeFoursquare: {
#ifndef TAK_GOOGLE
            NSArray *array = @[self.tableViewContentDictionary];
            [self.mapView refreshMapAnnotationsWithArray:array informationSource:TAKInformationSourceTypeFoursquare];
#endif
            break;
        }
            
        default: { // Google
#ifdef TAK_GOOGLE
            GMSMarker *marker = [[GMSMarker alloc] init];
            CLLocationDegrees latitude = (CLLocationDegrees)[[[[self.tableViewContentDictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lat"] doubleValue];
            CLLocationDegrees longitude = (CLLocationDegrees)[[[[self.tableViewContentDictionary objectForKey:@"geometry"] objectForKey:@"location"] objectForKey:@"lng"] doubleValue];
            marker.position = CLLocationCoordinate2DMake(latitude, longitude);
            marker.title = self.title;
            marker.snippet = (NSString*)[self.tableViewContentDictionary objectForKey:@"vicinity"];
            marker.map = self.mapView;
            // marker.animated = YES; 
            NSLog(@"Annotation title: %@, subtitle: %@, lat: %f, long: %f", marker.title, marker.snippet, latitude, longitude);
#endif
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
                // self.mapTypeSegmentedControl.hidden = YES;
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
            // self.mapTypeSegmentedControl.hidden = NO;
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
                // self.mapTypeSegmentedControl.hidden = YES;
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

- (void)mapTypeSegmentedControlValueChanged:(id)sender
{
    switch (self.mapTypeSegmentedControl.selectedSegmentIndex) {
        case 0: {
            if (self.informationSourceType == TAKInformationSourceTypeGoogle) {
                self.mapView.mapType = kGMSTypeNormal;
            } else {
                self.mapView.mapType = MKMapTypeStandard;
            }
            NSLog(@"Standard");
            break;
        }
            
        case 1: {
            if (self.informationSourceType == TAKInformationSourceTypeGoogle) {
                self.mapView.mapType = kGMSTypeHybrid;
            } else {
                self.mapView.mapType = MKMapTypeHybrid;
            }
            NSLog(@"Hybrid");
            break;
        }
            
        case 2: {
            if (self.informationSourceType == TAKInformationSourceTypeGoogle) {
                self.mapView.mapType = kGMSTypeSatellite;
            } else {
                self.mapView.mapType = MKMapTypeSatellite;
            }
            NSLog(@"Satellite");
            break;
        }
            
        case 3: {
            if (self.informationSourceType == TAKInformationSourceTypeGoogle) {
                self.mapView.mapType = kGMSTypeTerrain;
            }
            NSLog(@"Terrain");
            break;
        }
            
        default:
            NSLog(@"Unknown maptype");
            break;
    }
    
    NSLog(@"map type: %i", self.mapView.mapType);
}

@end
