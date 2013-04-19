//
//  TAKSearchResultsTableView.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/5/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <AddressBookUI/AddressBookUI.h>
#import "Constants.h"

@interface TAKSearchResultsTableView : UITableView <UITableViewDataSource>

@property (nonatomic, strong) NSMutableArray *tableViewContents;
@property NSUInteger informationSourceType;

@end
