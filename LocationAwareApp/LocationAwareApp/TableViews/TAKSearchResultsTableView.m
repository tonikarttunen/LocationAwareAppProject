//
//  TAKSearchResultsTableView.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/5/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKSearchResultsTableView.h"

@implementation TAKSearchResultsTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        // Initialization code
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.tableViewContents = [NSMutableArray new];
        self.delegate = self;
        self.dataSource = self;
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

#pragma mark - Table data source

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
    
    // Configure the cell
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:CellIdentifier];
        
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithRed:0.059 green:0.498 blue:0.353 alpha:1] /*#0f7f5a*/;
        cell.textLabel.opaque = NO;
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        
        cell.textLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0]; // Default: 18pt
        // cell.textLabel.numberOfLines = 2;
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor darkTextColor];
        cell.detailTextLabel.opaque = NO;
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:14.0]; // Default: 14pt
        
    }
    
    @try {
        if ((self.tableViewContents != nil) && (self.tableViewContents.count > 0)) {
            MKMapItem *mapItem = [self.tableViewContents objectAtIndex:indexPath.row];
            MKPlacemark *placemark = mapItem.placemark;
            
            cell.textLabel.text = mapItem.name;
            cell.detailTextLabel.text = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", [exception description]);
    }
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 58.0f;
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Navigation logic may go here. Create and push another view controller.
//    NSString *dvcTitle;
//    switch (indexPath.row) {
//        case 0:
//            dvcTitle = COPENHAGEN_OFFICE;
//            break;
//            
//        case 1:
//            dvcTitle = LONDON_OFFICE;
//            break;
//            
//        default:
//            dvcTitle = MANHATTAN_OFFICE;
//            break;
//    }
//    
//    NSLog(@"Detail View Controller Title: %@", dvcTitle);
//    TAKOfficeDetailViewController *officeDetailViewController = [[TAKOfficeDetailViewController alloc] initWithStyle:UITableViewStyleGrouped title:dvcTitle];
//    
//    @try {
//        UIViewController *mainViewController = (UIViewController *)[self.view.superview nextResponder];
//        [mainViewController.navigationController pushViewController:officeDetailViewController animated:YES];
//        [tableView deselectRowAtIndexPath:indexPath animated:YES];
//    }
//    @catch (NSException *exception) {
//        NSLog(@"%@", exception.description);
//    }
}

@end
