//
//  TAKFoursquareLocalSearchResultsViewController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/8/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAKMapView.h"
#import "TAKSearchResultsTableView.h"
#import "Constants.h"
// #import "APIConstants.h"
// #import "BZFoursquare.h"
#import "TAKFoursquareAuthorizationView.h"
// #import "FSQJSONObjectViewController.h"


@interface TAKFoursquareLocalSearchResultsViewController : UIViewController <UITableViewDelegate>

// @property (nonatomic, strong, readonly) BZFoursquare *foursquare;
@property (nonatomic, strong) TAKFoursquareAuthorizationView *foursquareAuthorizationView;
@property (nonatomic, copy, readonly) NSString *category;

- (id)initWithCategory:(NSString *)category;
- (void)showActivityIndicator;
- (void)generateInitialUI;
- (void)updateUI;
- (NSString *)foursquareCategoryID;

@end
