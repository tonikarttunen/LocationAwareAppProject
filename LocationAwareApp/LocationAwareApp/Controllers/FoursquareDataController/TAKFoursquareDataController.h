//
//  TAKFoursquareDataController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/9/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TAKFoursquareDataController : NSObject

@property (nonatomic, copy, readonly) NSDictionary *foursquareData;
@property (nonatomic, copy, readonly) NSArray *venues;
@property (nonatomic, strong, readonly) NSMutableArray *dataArray;

- (id)initWithFoursquareData:(id)foursquareData;
- (NSArray *)foursquareDataToArray;

@end
