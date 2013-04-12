//
//  TAKDetailViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/10/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKDetailViewController.h"

@interface TAKDetailViewController ()

@property (nonatomic, copy) NSArray *tableViewContents;

@end

@implementation TAKDetailViewController

- (id)initWithStyle:(UITableViewStyle)style
  tableViewContents:(NSArray *)tableViewContents
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        _tableViewContents = [tableViewContents copy];
        NSLog(@"%@", _tableViewContents);
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

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
    return self.tableViewContents.count;
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
        cell.textLabel.textColor = [UIColor colorWithRed:0.2 green:0.5 blue:0.5 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.opaque = NO;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        cell.textLabel.numberOfLines = 1;
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.2 green:0.2 blue:0.2 alpha:1.0];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.opaque = NO;
        cell.detailTextLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:14.0];
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
                        cell.detailTextLabel.text = (NSString *)obj;
                    }
                }
                break;
            }
                
            case TAKInformationSourceTypeFoursquare: {
                break;
            }
                
            case TAKInformationSourceTypeGoogle: {
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

@end
