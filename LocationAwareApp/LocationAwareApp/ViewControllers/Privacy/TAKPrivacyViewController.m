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
    return 4;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 1:
            return 5;
            
        case 2:
            return 2;
            
        default:
            return 1;
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier /* forIndexPath:indexPath */];
    
    NSString *accuracy;
    NSLog(@"Reading the saved location accuracy value from the standard user defaults...");
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
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
    
    if (self.tableViewContents == nil) {
        [self generateTableViewContents];
    }
    
    @try {
        switch (indexPath.section) {
            case 0: {
                cell.textLabel.text = @"\n";
                break;
            }
                
            case 1: {
                cell.textLabel.text = [[self.tableViewContents objectForKey:@"Location Accuracy"] objectAtIndex:indexPath.row];
                if ([accuracy isEqualToString:TAK_LOCATION_ACCURACY_BEST]) {
                    if (indexPath.row == 0) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                } else if ([accuracy isEqualToString:TAK_LOCATION_ACCURACY_TEN_METERS]) {
                    if (indexPath.row == 1) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                } else if ([accuracy isEqualToString:TAK_LOCATION_ACCURACY_HUNDRED_METERS]) {
                    if (indexPath.row == 2) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                } else if ([accuracy isEqualToString:TAK_LOCATION_ACCURACY_ONE_KILOMETER]) {
                    if (indexPath.row == 3) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                } else {
                    if (indexPath.row == 4) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                }
                break;
            }
                
            case 2: {
                cell.textLabel.text = [[self.tableViewContents objectForKey:@"Obfuscated Location Data"] objectAtIndex:indexPath.row];
                break;
            }
                
            case 3: {
                cell.textLabel.text = [self.tableViewContents objectForKey:@"Privacy Policy"];
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

- (void)generateTableViewContents
{
    self.tableViewContents = @{@"Privacy Tips" : @"",
                               @"Location Accuracy" : @[@"Best", @"Nearest 10 Meters", @"100 Meters", @"1 Kilometer", @"3 Kilometers"],
                               @"Obfuscated Location Data" : @[@"Yes", @"No"],
                               @"Privacy Policy" : @"Read Our Privacy Policy"
                               };
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Privacy Tips";
            
        case 1:
            return @"Location Accuracy";
            
        case 2:
            return @"Provide Obfuscated Location Data";
            
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.tableView deselectRowAtIndexPath:indexPath animated:NO];
    
    switch (indexPath.section) {
        case 1: {
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

            break;
        }
            
        default:
            break;
    }
}

#pragma mark - Done button action

- (void)dismissView
{
    //    void (^reloadTableViewContents) (void) = ^{
    //        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    //        UINavigationController *navigationController = (UINavigationController *)appDelegate.window.rootViewController;
    //        if ((navigationController != nil) && (navigationController.viewControllers.count > 0)) {
    //            [self dismissViewControllerAnimated:YES completion:NULL];
    //            TAKMainMenuViewController *mainMenu = [navigationController.viewControllers objectAtIndex:0];
    //            if (mainMenu) {
    //                [mainMenu generateTitleArray];
    //                [mainMenu.tableView reloadData];
    //                NSLog(@"RELOADED THE DATA");
    //            } else {
    //                return;
    //            }
    //        } else {
    //            return;
    //        }
    //    };
    
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
