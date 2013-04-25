//
//  TAKHelpViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/25/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKHelpViewController.h"

@interface TAKHelpViewController ()

@end

@implementation TAKHelpViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
        self.tableView.delegate = self;
        self.tableView.dataSource = self;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.tableView setBackgroundColor:[UIColor colorWithWhite:1.0 alpha:1.0]];
    self.view.opaque = YES;
    self.view.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone
                                                                                target:self
                                                                                action:@selector(dismissView)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.title = @"Help";
    self.tableView.allowsSelection = NO;
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
#ifdef TAK_FOURSQUARE
    return 4;
#else
    return 3;
#endif
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
        cell.textLabel.opaque = NO;
    }
    else {
        [[cell.contentView viewWithTag:5] removeFromSuperview];
        [[cell.contentView viewWithTag:6] removeFromSuperview];
        [[cell.contentView viewWithTag:7] removeFromSuperview];
#ifdef TAK_FOURSQUARE
        [[cell.contentView viewWithTag:8] removeFromSuperview];
#endif
    }
    
    [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    
    switch (indexPath.section) {
        case 0: {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 508.0f)];
            imageView.tag = 5;
            imageView.image = [UIImage imageNamed:@"Help1"];
            [cell.contentView addSubview:imageView];
            break;
        }
            
        case 1: {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 538.0f)];
            imageView.tag = 6;
            imageView.image = [UIImage imageNamed:@"Help2"];
            [cell.contentView addSubview:imageView];
            break;
        }
            
        case 2: {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 541.0f)];
            imageView.tag = 7;
            imageView.image = [UIImage imageNamed:@"Help3"];
            [cell.contentView addSubview:imageView];
            break;
        }
            
        default: {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0.0f, 0.0f, 320.0f, 581.0f)];
            imageView.tag = 8;
            imageView.image = [UIImage imageNamed:@"Help4"];
            [cell.contentView addSubview:imageView];
            break;
        }
    }
    
    return cell;
}


#pragma mark - Table view delegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section) {
        case 0:
            return 512.0f;
            
        case 1:
            return 543.0f;
            
        case 2:
            return 544.0f;
            
        default:
            return 584.0f;
    }
}

#pragma mark - Done button action

- (void)dismissView
{
    [self dismissViewControllerAnimated:YES completion:NULL];
}

@end
