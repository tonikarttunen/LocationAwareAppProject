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

@interface TAKDetailViewController ()

@property (nonatomic, copy) NSArray *tableViewContents; // Apple
@property (nonatomic, strong) NSMutableDictionary *tableViewContentDictionary; // Foursquare

@end

@implementation TAKDetailViewController

- (id)  initWithStyle:(UITableViewStyle)style
    tableViewContents:(NSArray *)tableViewContents
informationSourceType:(NSUInteger)informationSourceType
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _informationSourceType = informationSourceType;
        _tableViewContents = [tableViewContents copy];
        NSLog(@"%@", _tableViewContents);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

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
        default: {
#warning Potentially incomplete implementation (Google Places API search results)
            
            self.tableView.backgroundColor = [UIColor whiteColor];
            break;
        }
    }
    
    self.view.opaque = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
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
        case TAKInformationSourceTypeApple:
            return 1;
        case TAKInformationSourceTypeFoursquare:
            return self.tableViewContentDictionary.count;
        default: { // Google
#warning Incomplete implementation
            
            return 1;
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
#warning Incomplete implementation
            return 1;
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
        cell.accessoryType = UITableViewCellAccessoryNone;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.16 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.opaque = NO;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        cell.textLabel.numberOfLines = 1;
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.opaque = NO;
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        cell.detailTextLabel.numberOfLines = 1;
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
                } else {
                    array = [self.tableViewContentDictionary objectForKey:TAK_FOURSQUARE_STATISTICS];
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
#warning Incomplete implementation
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
    if (self.informationSourceType != TAKInformationSourceTypeFoursquare) {
        return @"";
    }
    switch (section) {
        case 0:
            return TAK_FOURSQUARE_BASIC_INFORMATION;
            
        case 1:
            return TAK_FOURSQUARE_LOCATION;
            
        default:
            return TAK_FOURSQUARE_STATISTICS;
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

@end
