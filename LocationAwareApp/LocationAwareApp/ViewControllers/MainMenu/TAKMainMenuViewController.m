//
//  TAKMainMenuViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/25/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKMainMenuViewController.h"
#import "TAKAppDelegate.h"
#import "TAKSettingsViewController.h"
#import "TAKGoogleViewController.h"

@interface TAKMainMenuViewController ()

@property (copy, nonatomic) NSArray *titleArray;

@end

@implementation TAKMainMenuViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        
        [self generateTitleArray];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"Nearby Places";
    
    // UIBarButtonItem *privacyUIBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Privacy" style:UIBarButtonItemStyleBordered target:self action:@selector(presentPrivacyViewController)];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Privacy" style:UIBarButtonItemStyleBordered target:self action:@selector(presentPrivacyViewController)];
    
    // UIButton *help = [UIButton buttonWithType:UIButtonTypeInfoLight];
	// [help addTarget:self action:@selector(presentHelpViewController) forControlEvents:UIControlEventTouchUpInside];
	// UIBarButtonItem *helpUIBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:help];
    // UIBarButtonItem *helpUIBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Help" style:UIBarButtonItemStyleBordered target:self action:@selector(presentHelpViewController)];
    
    NSString *path = [[NSBundle mainBundle] pathForResource:@"SettingsGearCropped17" ofType:@"png"];
    UIImage *settingsImage = [[UIImage alloc] initWithContentsOfFile:path];
    UIBarButtonItem *settingsUIBarButtonItem
        = [[UIBarButtonItem alloc] initWithImage:settingsImage
                                           style:UIBarButtonItemStyleBordered
                                          target:self
                                          action:@selector(presentSettingsViewController)];
    
    NSString *helpPath = [[NSBundle mainBundle] pathForResource:@"Help2" ofType:@"png"];
    UIImage *helpImage = [[UIImage alloc] initWithContentsOfFile:helpPath];
    UIBarButtonItem *helpItem = [[UIBarButtonItem alloc] initWithImage:helpImage
                                                                            style:UIBarButtonItemStyleBordered
                                                                           target:self
                                                                           action:@selector(presentHelpViewController)];
    
    // self.navigationItem.rightBarButtonItems = @[helpUIBarButtonItem, settingsUIBarButtonItem]; // [[UIBarButtonItem alloc] initWithTitle:@"Settings" style:UIBarButtonItemStyleBordered target:self action:@selector(presentSettingsViewController)];
    self.navigationItem.leftBarButtonItems = @[settingsUIBarButtonItem, helpItem];
    
    [self setViewBasicProperties];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    self.titleArray = nil;
}

- (void)dealloc
{
    self.titleArray = nil;
}

#pragma mark - Table view contents

- (void)generateTitleArray
{
    TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSUInteger currentInfoSource = appDelegate.currentInformationSource;
    
    switch (currentInfoSource) {
        case TAKInformationSourceTypeApple: {
            self.titleArray = @[@"Athletics", @"Colleges", @"Concert Halls", @"Convention Centers",
                                @"Event Spaces", @"Food", @"Government Buildings", @"Historic Sites", @"Hospitals",
                                @"Hotels", @"Libraries", @"Monuments", @"Landmarks", @"Movie Theaters", @"Museums",
                                @"Neighbourhoods", @"Nightlife", @"Non-Profits", @"Offices", @"Parking", @"Parks",
                                @"Post Offices", @"Recidences", @"Scenic Lookouts", @"Schools", @"Services", @"Shops",
                                @"Ski Areas", @"Tech Startups", @"Sports", @"Transport", @"Travel", @"Universities"];
            NSLog(@"Generated a title array (Apple), %i", currentInfoSource);
            break;
        }
            
        case TAKInformationSourceTypeFoursquare: {
            self.titleArray = @[/* Foursquare specials */
                                @"Everything",
                                @"Trending",
                                /* Normal categories */
                                @"Athletics and Sports", @"Colleges and Universities", @"Concert Halls", @"Convention Centers",
                                @"Event Spaces", @"Food", @"Government Buildings", @"Historic Sites", @"Hospitals",
                                @"Hotels", @"Libraries", @"Monuments and Landmarks", @"Movie Theaters", @"Museums",
                                @"Neighbourhoods", @"Nightlife", @"Non-Profits", @"Offices", @"Parking", @"Parks", @"Post Offices",
                                @"Recidences", @"Scenic Lookouts", @"Schools", @"Shops and Services", @"Ski Areas", @"Tech Startups",
                                @"Travel and Transport"];
            NSLog(@"Generated a title array (Foursquare), %i", currentInfoSource);
            break;
        }
            
        default: { // Google
            self.titleArray = @[@"Accounting", @"Airports", @"Art Galleries", @"Bakeries", @"Banks", @"Cafés",
                                @"Department Stores", @"Finance", @"Food", @"Gyms", @"Hospitals", @"Lawyers",
                                @"Libraries", @"Local Government Offices", @"Movie Theaters", @"Museums",
                                @"Nightclubs", @"Parks", @"Parking", @"Post Offices", @"Restaurants", @"Schools",
                                @"Stores", @"Subway Stations", @"Train Stations", @"Travel Agencies", @"Universities", @"Zoos"];
            NSLog(@"Generated a title array (Google), %i", currentInfoSource);
            break;
        }
    }
    
    // self.titleArray = @[TAK_ARCHITECTURE, TAK_ART_MUSEUMS, TAK_BEACH, TAK_COFFEE, TAK_DINNER, TAK_EVENTS, TAK_LUNCH, TAK_MOVIES, TAK_MUSEUMS, TAK_NIGHTLIFE, TAK_SHOPPING, TAK_SPORTS, TAK_THEATRE, TAK_TOURIST_ATTRACTIONS];// @[@"Recommended", @"Everything", @"Weather",
                        //@"Location-Based Reminder", @"Social Media", @"Photos"];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    if (self.titleArray == nil) {
        [self generateTitleArray];
    }
    return self.titleArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier /* forIndexPath:indexPath */];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.16 alpha:1.0]; // [UIColor colorWithRed:0.2 green:0.5 blue:0.5 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.opaque = NO;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        cell.textLabel.numberOfLines = 1;
    }
    
    @try {
        if (self.titleArray == nil) {
            [self generateTitleArray];
        }
        cell.textLabel.text = [self.titleArray objectAtIndex:indexPath.row];
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
    return cell;
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

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.backgroundColor = [UIColor whiteColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
    TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    NSUInteger currentInfoSource = appDelegate.currentInformationSource;
    
    switch (currentInfoSource) {
        case TAKInformationSourceTypeFoursquare: {
            NSString *categoryName = [[[tableView cellForRowAtIndexPath:indexPath] textLabel] text];
            TAKFoursquareLocalSearchResultsViewController *DVC = [[TAKFoursquareLocalSearchResultsViewController alloc]
                                                                  initWithCategory:categoryName];
            @try {
                DVC.title = [self.titleArray objectAtIndex:indexPath.row];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", [exception description]);
            }
            [self.navigationController pushViewController:DVC animated:YES];
            break;
        }
            
        case TAKInformationSourceTypeApple: {
            TAKLocalSearchResultsViewController *DVC = [[TAKLocalSearchResultsViewController alloc] init];
            @try {
                DVC.title = [self.titleArray objectAtIndex:indexPath.row];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", [exception description]);
            }
            [self.navigationController pushViewController:DVC animated:YES];
            break;
        }
            
        default: {
            @try {
                TAKGoogleViewController *DVC = [[TAKGoogleViewController alloc] initWithCategory:[self.titleArray objectAtIndex:indexPath.row]];
                DVC.title = [self.titleArray objectAtIndex:indexPath.row];
                [self.navigationController pushViewController:DVC animated:YES];
            }
            @catch (NSException *exception) {
                NSLog(@"%@", [exception description]);
            }
            break;
        }
    }
    /*
     <#DetailViewController#> *detailViewController = [[<#DetailViewController#> alloc] initWithNibName:@"<#Nib name#>" bundle:nil];
     // ...
     // Pass the selected object to the new view controller.
     [self.navigationController pushViewController:detailViewController animated:YES];
     */
}

#pragma mark - Present the privacy view controller

- (void)presentPrivacyViewController
{
    
}

#pragma mark - Present the help view controller

- (void)presentHelpViewController
{
    
}

#pragma mark - Present the settings view controller

- (void)presentSettingsViewController
{
    TAKSettingsViewController *settings = [[TAKSettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:settings];
    navigationController.modalTransitionStyle = UIModalTransitionStyleCoverVertical;
    [self presentViewController:navigationController animated:YES completion:NULL];
}

#pragma mark - UI creation

- (void)setViewBasicProperties
{
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    self.view.backgroundColor = [UIColor whiteColor];
    self.view.opaque = YES;
}

@end
