//
//  TAKFoursquareCheckInViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/14/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKFoursquareCheckInViewController.h"
#import "TAKAppDelegate.h"
#import "TAKDetailViewController.h"
#import "TAKFoursquareController.h"
#import <QuartzCore/QuartzCore.h>

#define TAK_PRIVACY_IMAGE_TAG 15

@interface TAKFoursquareCheckInViewController ()

@property (nonatomic, strong) NSIndexPath* checkedIndexPath;
@property NSUInteger currentFoursquarePrivacySetting;
@property (nonatomic, copy) NSString *venueID;
@property (nonatomic, strong) UILabel *activityIndicatorLabel;
@property (setter = setCheckInSuccessful:) BOOL isCheckInSuccessful;

typedef enum TAKFoursquarePrivacySetting : NSUInteger {
    TAKFoursquarePrivacySettingPrivate,
    TAKFoursquarePrivacySettingPublic
} TAKFoursquarePrivacySetting;

@end

@implementation TAKFoursquareCheckInViewController

- (id)initWithStyle:(UITableViewStyle)style foursquareVenueID:(NSString *)venueID
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _currentFoursquarePrivacySetting = TAKFoursquarePrivacySettingPrivate;
        self.venueID = venueID;
        NSLog(@"self.venueID: %@", self.venueID);
        _isCheckInSuccessful = NO;
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
                                                                                action:@selector(checkIn)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithTitle:@"Cancel"
                                                                     style:UIBarButtonItemStyleBordered
                                                                    target:self
                                                                    action:@selector(dismissView)];
    self.navigationItem.leftBarButtonItem = cancelButton;
    
    self.title = @"Check In";
    
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
    _checkedIndexPath = nil;
    _venueID = nil;
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    switch (section) {
        case 0:
            return 2;
            
        default:
            return 1;
    }
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
        
        switch (indexPath.section) {
            case 0:
                cell.textLabel.numberOfLines = 1;
                break;
                
            default:
                cell.textLabel.numberOfLines = 0;
                break;
        }
    }
    else {
        [[cell.contentView viewWithTag:TAK_PRIVACY_IMAGE_TAG] removeFromSuperview];
    }
    
    switch (indexPath.section) {
        case 0: {
            switch (indexPath.row) {
                case 0:
                    cell.textLabel.text = @"Private (Only Me)";
                    break;
                    
                default:
                    cell.textLabel.text = @"Public";
                    break;
            }
            
            
            switch (self.currentFoursquarePrivacySetting) {
                case TAKFoursquarePrivacySettingPrivate: {
                    if (indexPath.row == 0) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                }
                    
                default: {
                    if (indexPath.row == 1) {
                        cell.accessoryType = UITableViewCellAccessoryCheckmark;
                        self.checkedIndexPath = indexPath;
                    } else {
                        cell.accessoryType = UITableViewCellAccessoryNone;
                    }
                    break;
                }
            }
            break;
        }
            
        default: {
            cell.textLabel.text = @"\n";
            [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
            UIImageView *privacyTips = [[UIImageView alloc] initWithFrame:CGRectMake(10.0f, 7.0f, 280.0f, 311.0f)];
            privacyTips.tag = TAK_PRIVACY_IMAGE_TAG;
            privacyTips.image = [UIImage imageNamed:@"PrivacyTipsCropped4"];
            [cell.contentView addSubview:privacyTips];
            break;
        }
    }
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"Privacy";
            
        default:
            return @"Privacy Tips";
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
    
    if (self.checkedIndexPath != nil) {
        UITableViewCell *previouslyCheckedCell = [tableView
                                                  cellForRowAtIndexPath:self.checkedIndexPath];
        previouslyCheckedCell.accessoryType = UITableViewCellAccessoryNone;
    }
    UITableViewCell *tappedCell = [tableView cellForRowAtIndexPath:indexPath];
    tappedCell.accessoryType = UITableViewCellAccessoryCheckmark;
    self.checkedIndexPath = indexPath;
    
    self.currentFoursquarePrivacySetting = (NSUInteger)indexPath.row;
    NSLog(@"%i", self.currentFoursquarePrivacySetting);
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 45.0f;
            
        default:
            return 330.0f;
    }
}

#pragma mark - Check in

- (void)checkIn
{
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.tableView.allowsSelection = NO;
    
    self.activityIndicatorView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
    self.activityIndicatorView.frame = CGRectMake(self.view.bounds.size.width / 2.0 - 70.0, self.view.bounds.size.height / 2.0 - 65.0, 140.0, 140.0);
    self.activityIndicatorView.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    self.activityIndicatorView.layer.cornerRadius = 12.0;
    [self.view addSubview:self.activityIndicatorView];
    
    [self.activityIndicatorView startAnimating];
    
    TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate && appDelegate.foursquareController && appDelegate.foursquareController.foursquare) {
        NSString *privacySetting;
        
        switch (self.currentFoursquarePrivacySetting) {
            case TAKFoursquarePrivacySettingPrivate:
                privacySetting = @"private";
                break;
                
            default:
                privacySetting = @"public";
                break;
        }
        
        [appDelegate.foursquareController checkInToFoursquareVenueWithID:self.venueID privacySettingValue:privacySetting];
    }
}

#pragma mark - Cancel button action

- (void)dismissView
{
//    void (^reloadDetailViewContents) (void) = ^{
//        @try {
//            if (self.isCheckInSuccessful) {
//                TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
//                UINavigationController *navigationController = (UINavigationController *)appDelegate.window.rootViewController;
//                if ((navigationController != nil) && (navigationController.viewControllers.count > 2)) {
//                    TAKDetailViewController *detailViewController = [navigationController.viewControllers objectAtIndex:2];
//                    if (detailViewController) {
//                        [detailViewController updateCheckInCount];
//                    }
//                }
//            }
//        }
//        @catch (NSException *exception) {
//            NSLog(@"%@", exception.description);
//        }
//    };
    
    [self dismissViewControllerAnimated:YES completion:NULL /* reloadDetailViewContents */];
}

#pragma mark - Activity indicator

- (void)hideActivityIndicator
{
#ifdef DEBUG
    NSLog(@"SUCCESS");
#endif
    
    self.isCheckInSuccessful = YES;
    
    self.navigationItem.leftBarButtonItem.enabled = NO;
    [self.activityIndicatorView stopAnimating];
    [self.activityIndicatorView removeFromSuperview];
    
    self.activityIndicatorLabel = [[UILabel alloc] initWithFrame:CGRectMake(self.view.bounds.size.width / 2.0 - 70.0, self.view.bounds.size.height / 2.0 - 65.0, 140.0, 140.0)];
    self.activityIndicatorLabel.backgroundColor = [UIColor colorWithWhite:0.1 alpha:0.8];
    self.activityIndicatorLabel.textColor = [UIColor whiteColor];
    self.activityIndicatorLabel.backgroundColor = [UIColor colorWithRed:0.1 green:0.6 blue:0.3 alpha:0.83];
    self.activityIndicatorLabel.text = @"Success";
    self.activityIndicatorLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:22.0f];
    self.activityIndicatorLabel.textAlignment = NSTextAlignmentCenter;
    self.activityIndicatorLabel.layer.cornerRadius = 12.0;
    [self.view addSubview:self.activityIndicatorLabel];
    
    [self performSelector:@selector(dismissView) withObject:nil afterDelay:1.2];
}

- (void)showAlertWithText:(NSString *)text
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Could Not Complete the Request"
                                                    message:text delegate:self
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
}

@end
