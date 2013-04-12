//
//  TAKDetailViewController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/10/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"

@interface TAKDetailViewController : UITableViewController <UITableViewDataSource, UITableViewDelegate>

@property NSUInteger informationSourceType;

- (id)initWithStyle:(UITableViewStyle)style
  tableViewContents:(NSArray *)tableViewContents;

@end