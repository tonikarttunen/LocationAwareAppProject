//
//  TAKFoursquareDataController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/9/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKFoursquareDataController.h"

@interface TAKFoursquareDataController ()

@property (nonatomic, copy, readwrite) NSDictionary *foursquareData;
@property (nonatomic, copy, readwrite) NSArray *venues;
@property (nonatomic, strong, readwrite) NSMutableArray *dataArray;

@end

@implementation TAKFoursquareDataController

- (id)initWithFoursquareData:(id)foursquareData
{
    self = [super init];
    if (self) {
        _dataArray = [NSMutableArray new];
        _foursquareData = [foursquareData copy];
        if (![_foursquareData isKindOfClass:[NSNull class]]) {
            _venues = [_foursquareData objectForKey:@"venues"];
        }
        // _sortedFoursquareData = [[venues allKeys] sortedArrayUsingSelector:@selector(compare:)];
#ifdef DEBUG
        NSLog(@"foursquareData: %@", _foursquareData);
#endif
    }
    return self;
}

- (void)dealloc
{
    _dataArray = nil;
    _foursquareData = nil;
}

#pragma mark - Methods for converting the data to an array

- (NSArray *)foursquareDataToArray
{
    @try {
        if ([self.foursquareData isKindOfClass:[NSNull class]]) {
            return nil;
        }
        
        for (int i = 0; i < self.venues.count; i++) {
            NSMutableDictionary *currentVenueDetails = [NSMutableDictionary new];
            NSDictionary *currentVenue = [self.venues objectAtIndex:i];
            NSLog(@"currentVenue: %@", currentVenue);
            
            NSString *venueID = [currentVenue objectForKey:@"id"];
            [currentVenueDetails setObject:venueID forKey:@"Venue ID"];
            
            NSString *name = [currentVenue objectForKey:@"name"];
            [currentVenueDetails setObject:name forKey:@"Name"];
            
            NSDictionary *location = [currentVenue objectForKey:@"location"];
            double latitude = [[location objectForKey:@"lat"] doubleValue];
            double longitude = [[location objectForKey:@"lng"] doubleValue];
            NSString *address = [location objectForKey:@"address"];
            
            // [currentVenueDetails addObject:@{@"Latitude" : [NSNumber numberWithDouble:latitude]}];
            [currentVenueDetails setObject:[NSNumber numberWithDouble:latitude] forKey:@"Latitude"];
            // [currentVenueDetails addObject:@{@"Longitude" : [NSNumber numberWithDouble:longitude]}];
            [currentVenueDetails setObject:[NSNumber numberWithDouble:longitude] forKey:@"Longitude"];
            if (address != nil) {
                [currentVenueDetails setObject:address forKey:@"Address"];
            } else {
                NSString *crossStreet = [currentVenue objectForKey:@"cc"];
                if (crossStreet != nil) {
                    [currentVenueDetails setObject:crossStreet forKey:@"Address"];
                } else {
                    NSString *city = [currentVenue objectForKey:@"city"];
                    if (city != nil) {
                        [currentVenueDetails setObject:city forKey:@"Address"];
                    } else {
                        NSString *country = [currentVenue objectForKey:@"country"];
                        if (country != nil) {
                            [currentVenueDetails setObject:country forKey:@"Address"];
                        } else {
                            // [currentVenueDetails addObject:@{@"Address" : @"Unknown address"}];
                            [currentVenueDetails setObject:@"Unknown address" forKey:@"Address"];
                        }
                    }
                }
            }
            
            NSDictionary *stats = [currentVenue objectForKey:@"stats"];
            int checkinsCount = [[stats objectForKey:@"checkinsCount"] integerValue];
            int usersCount = [[stats objectForKey:@"usersCount"] integerValue];
            // [currentVenueDetails addObject:@{@"Check-ins" : [NSNumber numberWithInt:checkinsCount]}];
            [currentVenueDetails setObject:[NSNumber numberWithInt:checkinsCount] forKey:@"Check-ins"];
            // [currentVenueDetails addObject:@{@"Users" : [NSNumber numberWithInt:usersCount]}];
            [currentVenueDetails setObject:[NSNumber numberWithInt:usersCount] forKey:@"Users"];
            [self.dataArray addObject:(NSArray *)currentVenueDetails];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot convert foursquareData to dataArray: %@.", exception.description);
    }
    
    NSLog(@"%@", self.dataArray);
    
    return self.dataArray;
}

@end
