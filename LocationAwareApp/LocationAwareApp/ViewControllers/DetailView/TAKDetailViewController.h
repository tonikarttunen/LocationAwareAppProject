//
//  TAKDetailViewController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/10/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Constants.h"
#import "TAKFoursquareCheckInViewController.h"

@interface TAKDetailViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property NSUInteger informationSourceType;
@property (nonatomic, strong) TAKFoursquareCheckInViewController *foursquareCheckInViewController;

- (id)  initWithStyle:(UITableViewStyle)style
    tableViewContents:(NSArray *)tableViewContents
informationSourceType:(NSUInteger)informationSourceType;

- (id)           initWithStyle:(UITableViewStyle)style
    tableViewContentDictionary:(NSDictionary *)tableViewContentDictionary
         informationSourceType:(NSUInteger)informationSourceType;

- (id)           initWithStyle:(UITableViewStyle)style
    tableViewContentDictionary:(NSDictionary *)tableViewContentDictionary
informationSourceType:(NSUInteger)informationSourceType
                   referenceID:(NSString *)referenceID;

- (void)sendFoursquarePhotoContentRequestWithURLString:(NSString *)URLString;
- (void)showNoPhotosLabel;

// - (void)updateCheckInCount;

@end
