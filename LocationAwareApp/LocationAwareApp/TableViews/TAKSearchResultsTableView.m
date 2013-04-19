//
//  TAKSearchResultsTableView.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/5/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKSearchResultsTableView.h"

@class TAKFoursquareLocalSearchResultsViewController;

@implementation TAKSearchResultsTableView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame style:UITableViewStylePlain];
    if (self) {
        // Initialization code
        self.informationSourceType = 0;
        self.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
        self.tableViewContents = [NSMutableArray new];
        // self.delegate = self;
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
        cell.textLabel.textColor = [UIColor colorWithWhite:0.16 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.opaque = NO;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica-Bold" size:18.0];
        
        cell.detailTextLabel.backgroundColor = [UIColor clearColor];
        cell.detailTextLabel.textColor = [UIColor colorWithRed:0.35 green:0.35 blue:0.35 alpha:1.0];
        cell.detailTextLabel.highlightedTextColor = [UIColor whiteColor];
        cell.detailTextLabel.opaque = NO;
        cell.detailTextLabel.font = [UIFont fontWithName:@"HelveticaNeue-Light" size:16.0];
        
    }
    
    @try {
        if ((self.tableViewContents != nil) && (self.tableViewContents.count > 0)) {
            switch (self.informationSourceType) {
                case TAKInformationSourceTypeApple: {
                    MKMapItem *mapItem = [self.tableViewContents objectAtIndex:indexPath.row];
                    MKPlacemark *placemark = mapItem.placemark;
                    
                    cell.textLabel.text = mapItem.name;
                    cell.detailTextLabel.text = ABCreateStringWithAddressDictionary(placemark.addressDictionary, YES);
                    break;
                }
                    
                case TAKInformationSourceTypeFoursquare: {
                    NSArray *locationData = [[self.tableViewContents objectAtIndex:indexPath.row] objectForKey:TAK_FOURSQUARE_LOCATION];
                    NSArray *basicInformation = [[self.tableViewContents objectAtIndex:indexPath.row] objectForKey:TAK_FOURSQUARE_BASIC_INFORMATION];
                    
                    cell.textLabel.text = (NSString *)[[basicInformation objectAtIndex:0] objectAtIndex:1];
                    cell.detailTextLabel.text = (NSString *)[[locationData objectAtIndex:3] objectAtIndex:1];
                    break;
                }
                    
                default:  { // Google
//                    NSLog(@"GOOGLE!");
//                    NSLog(@"tableViewContents class: %@, %@",
//                          [self.tableViewContents class],
//                          self.tableViewContents);
                    
                    NSDictionary *placeInformation = [self.tableViewContents objectAtIndex:indexPath.row];
                    cell.textLabel.text = (NSString *)[placeInformation objectForKey:@"name"];
                    cell.detailTextLabel.text = (NSString*)[placeInformation objectForKey:@"vicinity"];
//#ifdef DEBUG
//                    NSLog(@"placeInformation: %@", placeInformation);
//#endif
                    break;
                }
            }
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

@end
