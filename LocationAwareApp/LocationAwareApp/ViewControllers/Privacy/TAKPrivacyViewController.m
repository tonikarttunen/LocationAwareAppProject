//
//  TAKPrivacyViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/23/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKPrivacyViewController.h"
#import "TAKAppDelegate.h"
#import "Constants.h"
#import "TAKPrivacyPolicyViewController.h"

#define TAK_PRIVACY_IMAGE_TAG 15

@interface TAKPrivacyViewController ()

@property (nonatomic, copy) NSDictionary *tableViewContents;
@property (nonatomic, strong) NSIndexPath *checkedIndexPath;

@end

@implementation TAKPrivacyViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        [self generateTableViewContents];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.91 alpha:1.0]];
    self.view.opaque = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(dismissView)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.title = @"Privacy";

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _tableViewContents = nil;
}

- (void)dealloc
{
    _tableViewContents = nil;
    _checkedIndexPath = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
#ifdef TAK_FOURSQUARE
    return 3;
#else
    return 2;
#endif
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
#ifdef TAK_FOURSQUARE
        case 1:
            return 2;
#else
        case 0:
            return 2;
#endif
            
//        case 2:
//            return 1;
            
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier /* forIndexPath:indexPath */];
    
    int obfuscate;
    NSString *accuracy;
    NSLog(@"Reading the saved location accuracy value from the standard user defaults...");
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        obfuscate = [[userDefaults objectForKey:@"Obfuscate"] integerValue];
        NSLog(@"Obfuscate: %i", obfuscate);
        id locationAccuracy = [userDefaults objectForKey:TAK_LOCATION_ACCURACY];
        if ((locationAccuracy != nil) && [locationAccuracy isKindOfClass:[NSString class]]) {
            accuracy = (NSString *)locationAccuracy;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.16 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.opaque = NO;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        cell.textLabel.numberOfLines = 1;
    }
    else {
        [[cell.contentView viewWithTag:TAK_PRIVACY_IMAGE_TAG] removeFromSuperview];
    }
    
    if (self.tableViewContents == nil) {
        [self generateTableViewContents];
    }
    
    @try {
        switch (indexPath.section) {
            case 0: {
#ifdef TAK_FOURSQUARE
                cell.textLabel.text = @"\n";
                [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
                UIImageView *privacyTips = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 7.0f, 280.0f, 311.0f)];
                privacyTips.tag = TAK_PRIVACY_IMAGE_TAG;
                privacyTips.image = [UIImage imageNamed:@"PrivacyTipsCropped3"];
                [cell.contentView addSubview:privacyTips];
                break;
#else
                cell.textLabel.text = [[self.tableViewContents objectForKey:@"Obfuscated Location Data"] objectAtIndex:indexPath.row];
                
                if (obfuscate == 1) {
                    if (indexPath.row == 1) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                } else {
                    if (indexPath.row == 0) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                }
                
                break;
#endif
            }
                
                
//            case 1: {
//                cell.textLabel.text = [[self.tableViewContents objectForKey:@"Location Accuracy"] objectAtIndex:indexPath.row];
//                if ([accuracy isEqualToString:TAK_LOCATION_ACCURACY_BEST]) {
//                    if (indexPath.row == 0) {
//                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                        self.checkedIndexPath = indexPath;
//                    } else {
//                        cell.accessoryType = UITableViewCellAccessoryNone;
//                    }
//                } else if ([accuracy isEqualToString:TAK_LOCATION_ACCURACY_TEN_METERS]) {
//                    if (indexPath.row == 1) {
//                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                        self.checkedIndexPath = indexPath;
//                    } else {
//                        cell.accessoryType = UITableViewCellAccessoryNone;
//                    }
//                } else if ([accuracy isEqualToString:TAK_LOCATION_ACCURACY_HUNDRED_METERS]) {
//                    if (indexPath.row == 2) {
//                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                        self.checkedIndexPath = indexPath;
//                    } else {
//                        cell.accessoryType = UITableViewCellAccessoryNone;
//                    }
//                } else if ([accuracy isEqualToString:TAK_LOCATION_ACCURACY_ONE_KILOMETER]) {
//                    if (indexPath.row == 3) {
//                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                        self.checkedIndexPath = indexPath;
//                    } else {
//                        cell.accessoryType = UITableViewCellAccessoryNone;
//                    }
//                } else {
//                    if (indexPath.row == 4) {
//                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
//                        self.checkedIndexPath = indexPath;
//                    } else {
//                        cell.accessoryType = UITableViewCellAccessoryNone;
//                    }
//                }
//                break;
//            }
                
            case 1: {
#ifdef TAK_FOURSQUARE
                cell.textLabel.text = [[self.tableViewContents objectForKey:@"Obfuscated Location Data"] objectAtIndex:indexPath.row];
                
                if (obfuscate == 1) {
                    if (indexPath.row == 1) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                } else {
                    if (indexPath.row == 0) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                }
#else
                cell.textLabel.text = [self.tableViewContents objectForKey:@"Privacy Policy"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
#endif
                break;
            }
            
#ifdef TAK_FOURSQUARE
            case 2: {
                cell.textLabel.text = [self.tableViewContents objectForKey:@"Privacy Policy"];
                cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
                break;
            }
#endif
                
            default:
                break;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
    return cell;
}

- (void)generateTableViewContents
{
    self.tableViewContents = @{@"Privacy Tips" : @"",
                               /* @"Location Accuracy" : @[@"Best", @"Nearest 10 Meters", @"100 Meters", @"1 Kilometer", @"3 Kilometers"], */
                               @"Obfuscated Location Data" : @[@"No", @"Yes"],
                               @"Privacy Policy" : @"Read Our Privacy Policy"
                               };
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {            
#ifdef TAK_FOURSQUARE
        case 0:
            return @"Privacy Tips";
            
//        case 1:
//            return @"Location Accuracy";
            
        case 1:
            return @"Use Obfuscated Location Data";
#else
        case 0:
            return @"Use Obfuscated Location Data";
#endif
            
        default:
            return @"Privacy Policy";
    }
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
#ifdef TAK_FOURSQUARE
    switch (indexPath.section) {
        case 0:
            return 330.0f;
            
        default:
            return 45.0f;
    }
#else
    return 45.0f;
#endif
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section) {
//        case 1: {
//            if (self.checkedIndexPath != nil) {
//                UITableViewCell *previouslyCheckedCell = [tableView
//                                                          cellForRowAtIndexPath:self.checkedIndexPath];
//                previouslyCheckedCell.accessoryType = UITableViewCellAccessoryNone;
//            }
//            UITableViewCell *tappedCell = [tableView cellForRowAtIndexPath:indexPath];
//            tappedCell.accessoryType = UITableViewCellAccessoryCheckmark;
//            self.checkedIndexPath = indexPath;
//            
//            CLLocationAccuracy accuracy;
//            NSString *accuracyString;
//            if (indexPath.row == 0) {
//                accuracy = kCLLocationAccuracyBest;
//                accuracyString = TAK_LOCATION_ACCURACY_BEST;
//            } else if (indexPath.row == 1) {
//                accuracy = kCLLocationAccuracyNearestTenMeters;
//                accuracyString = TAK_LOCATION_ACCURACY_TEN_METERS;
//            } else if (indexPath.row == 2) {
//                accuracy = kCLLocationAccuracyHundredMeters;
//                accuracyString = TAK_LOCATION_ACCURACY_HUNDRED_METERS;
//            } else if (indexPath.row == 3) {
//                accuracy = kCLLocationAccuracyKilometer;
//                accuracyString = TAK_LOCATION_ACCURACY_ONE_KILOMETER;
//            } else {
//                accuracy = kCLLocationAccuracyThreeKilometers;
//                accuracyString = TAK_LOCATION_ACCURACY_THREE_KILOMETERS;
//            }
//            
//            TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//            appDelegate.locationController.locationManager.desiredAccuracy = accuracy;
//            appDelegate.locationController.locationManager.distanceFilter = (CLLocationDistance)accuracy;
//            NSLog(@"Selected a new location accuracy: %f", appDelegate.locationController.locationManager.desiredAccuracy);
//            
//            // Save the value of the location accuracy to the standard user defaults
//            @try {
//                NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
//                [userDefaults setObject:accuracyString forKey:TAK_LOCATION_ACCURACY];
//                [userDefaults synchronize];
//                NSLog(@"Saved a new location accuracy value to the standard user defaults (dict value): %@, accuracy: %f", accuracyString, accuracy);
//            }
//            @catch (NSException *exception) {
//                NSLog(@"%@", exception.description);
//            }
//
//            break;
//        }
        
            
#ifdef TAK_FOURSQUARE
        case 1: {
#else
        case 0: {
#endif
            if (self.checkedIndexPath != nil) {
                UITableViewCell *previouslyCheckedCell = [tableView
                                                          cellForRowAtIndexPath:self.checkedIndexPath];
                previouslyCheckedCell.accessoryType = UITableViewCellAccessoryNone;
            }
            UITableViewCell *tappedCell = [tableView cellForRowAtIndexPath:indexPath];
            tappedCell.accessoryType = UITableViewCellAccessoryCheckmark;
            self.checkedIndexPath = indexPath;
            
            TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
            if (indexPath.row == 1) {
                appDelegate.locationController.isLocationObfuscated = YES;
                double randomNumberForlocationObfuscation = ((double)rand() / (RAND_MAX)) + 1.0;
                double maximumObfuscationInKilometers = 0.35;
                CLLocationDegrees latitude = appDelegate.locationController.realLocation.coordinate.latitude + ((randomNumberForlocationObfuscation * maximumObfuscationInKilometers) / 110.0); 
                CLLocationDegrees longitude = appDelegate.locationController.realLocation.coordinate.longitude + ((randomNumberForlocationObfuscation * maximumObfuscationInKilometers) / 110.0); 
                appDelegate.locationController.lastKnownLocation = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];
            } else {
                appDelegate.locationController.isLocationObfuscated = NO;
                appDelegate.locationController.lastKnownLocation = appDelegate.locationController.realLocation;
            }
            
            NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
            [userDefaults setObject:[NSNumber numberWithInteger:(NSInteger)indexPath.row] forKey:@"Obfuscate"];
            [userDefaults synchronize];
            NSLog(@"new obfuscation value: %i", (NSInteger)indexPath.row);
            break;
        }
        
#ifdef TAK_FOURSQUARE
        case 2: {
#else
        case 1: {
#endif
            TAKPrivacyPolicyViewController *DVC = [[TAKPrivacyPolicyViewController alloc] initWithStyle:UITableViewStyleGrouped];
            [self.navigationController pushViewController:DVC animated:YES];
            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Done button action

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
