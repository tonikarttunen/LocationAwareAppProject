//
//  TAKPrivacyPolicyViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/23/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKPrivacyPolicyViewController.h"

@interface TAKPrivacyPolicyViewController ()

@end

@implementation TAKPrivacyPolicyViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
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
    
    self.title = @"Privacy Policy";
    
    self.tableView.allowsSelection = NO;

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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    // Return the number of rows in the section.
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    // Configure the cell...
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"Cell"];
        
        cell.textLabel.backgroundColor = [UIColor clearColor];
        cell.textLabel.textColor = [UIColor colorWithWhite:0.16 alpha:1.0];
        cell.textLabel.highlightedTextColor = [UIColor whiteColor];
        cell.textLabel.opaque = NO;
        cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
        cell.textLabel.numberOfLines = 0;
    }
    
    NSString *cellText;
    switch (indexPath.section) {
        case 0:
            cellText = @"The application uses your current location to provide relevant local search results.";
            break;
            
        case 1: {
            cellText = @"No, this application respects your privacy.";
            break;
        }
            
        default:
#if defined TAK_APPLE
            cellText = @"The application sends your location data to Apple in order to provide local search results.";
#elif defined TAK_GOOGLE
            cellText = @"The application sends your location data to Google in order to provide local search results.";
#else
            cellText = @"The application sends your location data to Foursquare in order to provide local search results.";
#endif
            break;
    }
    
    cell.textLabel.text = cellText;
    
    return cell;
}

- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    switch (section) {
        case 0:
            return @"What Information Does the Application Collect?";
            
        case 1:
            return @"Does this Application Store My Location Data Permanently?";
            
        default:
            return @"Does the Application Disclose My Location Data to Any Third Parties?";
    }
}

#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString *cellText;
    switch (indexPath.section) {
        case 0:
            cellText = @"The application uses your current location to provide relevant local search results.";
            break;
            
        case 1: {
            cellText = @"No, this application respects your privacy.";
            break;
        }
            
        default:
#if defined TAK_APPLE
            cellText = @"The application sends your location data to Apple in order to provide local search results.";
#elif defined TAK_GOOGLE
            cellText = @"The application sends your location data to Google in order to provide local search results.";
#else
            cellText = @"The application sends your location data to Foursquare in order to provide local search results.";
#endif
            break;
    }
    
    CGSize labelSize = [cellText sizeWithFont:[UIFont fontWithName:@"Helvetica" size:16.0]
                            constrainedToSize:CGSizeMake(self.view.bounds.size.width - 45.0f, MAXFLOAT)
                                lineBreakMode:NSLineBreakByWordWrapping];
    
    if ((labelSize.height + 24.0f) < 60.0f) {
        return 60.0f;
    } else {
        return labelSize.height + 24.0f;
    }

}

@end
