//
//  TAKLocalSearchResultsViewController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/20/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TAKMapView.h"
#import "TAKSearchResultsTableView.h"

@interface TAKLocalSearchResultsViewController : UIViewController

- (void)performLocalSearchWithString:(NSString *)searchString;

@end
