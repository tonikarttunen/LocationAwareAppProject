//
//  TAKSettingsViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/14/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKSettingsViewController.h"
#import "Constants.h"
#import "TAKAppDelegate.h"
#import "TAKMainMenuViewController.h"

@interface TAKSettingsViewController ()

// @property NSUInteger currentInformationSource;
@property (nonatomic, copy) NSArray *informationSources;
@property (nonatomic, strong) NSIndexPath* checkedIndexPath;

@end

@implementation TAKSettingsViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization        
        [self generateTableViewContentArray];
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // self.tableView.allowsSelection = NO;
    [self.tableView setBackgroundView:nil];
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:0.91 alpha:1.0]];
    self.view.opaque = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(dismissView)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.title = @"Settings";
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _informationSources = nil;
}

- (void)dealloc
{
    _informationSources = nil;
    _checkedIndexPath = nil;
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
    return 3;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier /* forIndexPath:indexPath */];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.16 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.opaque = NO;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        cell.textLabel.numberOfLines = 1;
        
//        UIView *selectedCellBackgroundView = [[UIView alloc] init];
//        selectedCellBackgroundView.backgroundColor = [UIColor colorWithWhite:0.9 alpha:1.0];
//        cell.selectedBackgroundView = selectedCellBackgroundView;
        
        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        NSUInteger currentInformationSource = appDelegate.currentInformationSource;
        
        switch (currentInformationSource) {
            case TAKInformationSourceTypeApple: {
                if (indexPath.row == 0) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    self.checkedIndexPath = indexPath;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            }
                
            case TAKInformationSourceTypeFoursquare: {
                if (indexPath.row == 1) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    self.checkedIndexPath = indexPath;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            }
                
            default: {
                if (indexPath.row == 2) {
                    cell.accessoryType = UITableViewCellAccessoryCheckmark;
                    self.checkedIndexPath = indexPath;
                } else {
                    cell.accessoryType = UITableViewCellAccessoryNone;
                }
                break;
            }
        }
    }
    
    if (self.informationSources == nil) {
        [self generateTableViewContentArray];
    }
    
    cell.textLabel.text = (NSString *)[self.informationSources objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)generateTableViewContentArray
{
    self.informationSources = @[@"Apple", @"Foursquare", @"Google"];
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @"Location Data Provider";
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
    
    if (self.checkedIndexPath != nil) {
        UITableViewCell *previouslyCheckedCell = [tableView
                                                  cellForRowAtIndexPath:self.checkedIndexPath];
        previouslyCheckedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *tappedCell = [tableView cellForRowAtIndexPath:indexPath];
    tappedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
    
    TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    appDelegate.currentInformationSource = (NSUInteger)indexPath.row;
    NSLog(@"Selected a new infosource, infoSource: %i", appDelegate.currentInformationSource);
    
    // Save the value of the location data provider to the standard user defaults
    @try {
        NSUserDefaults *userDefaults = [NSUserDefaults standardUserDefaults];
        NSInteger infoSource = (NSInteger)appDelegate.currentInformationSource;
        [userDefaults setObject:[NSNumber numberWithInteger:infoSource] forKey:@"InformationSource"];
        [userDefaults synchronize];
        NSLog(@"Saved a new infosource to the standard user defaults, infoSource: %i", infoSource);
    }
    @catch (NSException *exception) {
        appDelegate.currentInformationSource = TAKInformationSourceTypeApple;
        NSLog(@"%@", exception.description);
    }
}

#pragma mark - Done button action

- (void)dismissView
{
    void (^reloadTableViewContents) (void) = ^{
        TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
        UINavigationController *navigationController = (UINavigationController *)appDelegate.window.rootViewController;
        if ((navigationController != nil) && (navigationController.viewControllers.count > 0)) {
            [self dismissViewControllerAnimated:YES completion:NULL];
            TAKMainMenuViewController *mainMenu = [navigationController.viewControllers objectAtIndex:0];
            if (mainMenu) {
                [mainMenu generateTitleArray];
                [mainMenu.tableView reloadData];
                NSLog(@"RELOADED THE DATA");
            } else {
                return;
            }
        } else {
            return;
        }
    };
    
    [self dismissViewControllerAnimated:YES completion:reloadTableViewContents];
}

@end
