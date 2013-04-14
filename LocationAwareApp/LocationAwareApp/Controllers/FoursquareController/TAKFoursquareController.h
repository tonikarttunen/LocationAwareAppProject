//
//  TAKFoursquareController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/9/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "NSArray+FoursquareDataProcessor.h"
#import <Foundation/Foundation.h>
#import "BZFoursquare.h"
#import "BZFoursquareRequest.h"

@interface TAKFoursquareController : NSObject <BZFoursquareRequestDelegate, BZFoursquareSessionDelegate>

@property (nonatomic, strong, readonly) BZFoursquare *foursquare;
@property (nonatomic, copy, readonly) NSDictionary *foursquareResponse;
@property (nonatomic, copy, readonly) NSDictionary *foursquareMeta;
@property (nonatomic, copy, readonly) NSArray *foursquareNotifications;
@property (nonatomic, copy, readonly) NSMutableArray *processedFoursquareData;

- (void)searchFoursquareContentWithPath:(NSString *)path
                       searchParameters:(NSDictionary *)searchParameters;
- (void)checkInToFoursquareVenueWithID:(NSString *)venueID
                   privacySettingValue:(NSString *)privacySettingValue;
- (void)cancelFoursquareRequest;
- (void)deleteOldFoursquareRequestData;

@end
