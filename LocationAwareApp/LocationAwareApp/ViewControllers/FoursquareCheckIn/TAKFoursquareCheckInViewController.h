//
//  TAKFoursquareCheckInViewController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/14/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAKFoursquareCheckInViewController : UITableViewController

@property (nonatomic, strong) UIActivityIndicatorView *activityIndicatorView;

- (id)initWithStyle:(UITableViewStyle)style foursquareVenueID:(NSString *)venueID;
- (void)hideActivityIndicator;
- (void)dismissView;
- (void)showAlertWithText:(NSString *)text;

@end
