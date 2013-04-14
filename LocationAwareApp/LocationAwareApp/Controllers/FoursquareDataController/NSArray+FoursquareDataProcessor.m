//
//  NSArray+FoursquareDataProcessor.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/13/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "NSArray+FoursquareDataProcessor.h"
#import "Constants.h"

@implementation NSArray (FoursquareDataProcessor)

+ (NSArray *)arrayWithFoursquareData:(NSDictionary *)dictionary searchPathComponents:(NSArray *)components
{
    // Format:
    // [
    // 1 {
    //   "location" : [["address", "street 100"], ["lat", 1.111], ["long", 1.111]],
    //   "social" : [["users", 500], []]
    //   },
    // 2 {},...
    // ]
    
    NSMutableArray *processed = [NSMutableArray new];
    
    @try {
        // No data
        if ([dictionary isKindOfClass:[NSNull class]] || (components == nil)) {
            return (NSArray *)processed;
        }
        
#ifdef DEBUG
        NSLog(@"foursquareDictionary: %@", dictionary);
#endif
        
        NSArray *venues;
        if (components.count == 1) {
            venues = [dictionary objectForKey:@"venues"];
            if ((venues == nil) || (venues.count == 0)) {
                return (NSArray *)processed;
            }
        } else {
            NSLog(@"Invalid input to NSArray+FoursquareDataProcessor.m!");
            return @[];
        }
        
        for (int i = 0; i < venues.count; i++) {
            NSMutableDictionary *currentVenueDetails = [NSMutableDictionary new];
            NSDictionary *currentVenue = [venues objectAtIndex:i];
            NSLog(@"currentVenue: %@", currentVenue);
            
            // Basic details
            NSString *venueID = [currentVenue objectForKey:@"id"];
            NSString *name = [currentVenue objectForKey:@"name"];
            [currentVenueDetails setObject:@[ @[@"Name", name], @[@"ID", venueID] ] forKey:TAK_FOURSQUARE_BASIC_INFORMATION];
            
            // Location
            NSDictionary *location = [currentVenue objectForKey:@"location"];
            double latitude = [[location objectForKey:@"lat"] doubleValue];
            double longitude = [[location objectForKey:@"lng"] doubleValue];
            int distance = [[location objectForKey:@"distance"] integerValue];
            NSString *address = [location objectForKey:@"address"];
            
            if (address == nil) {
                address = [currentVenue objectForKey:@"cc"];
            }
            if (address == nil) {
                address = [currentVenue objectForKey:@"city"];
            }
            if (address == nil) {
                address = [currentVenue objectForKey:@"country"];
            }
            if (address == nil) {
                address = @"Unknown address";
            }
            
            [currentVenueDetails setObject:@[
                                             @[@"Latitude", [NSNumber numberWithDouble:latitude]],
                                             @[@"Longitude", [NSNumber numberWithDouble:longitude]],
                                             @[@"Distance", [NSNumber numberWithInt:distance]],
                                             @[@"Address", address]
                                            ] forKey:TAK_FOURSQUARE_LOCATION];
            
            // Statistics
            NSDictionary *stats = [currentVenue objectForKey:@"stats"];
            int checkinsCount = [[stats objectForKey:@"checkinsCount"] integerValue];
            int usersCount = [[stats objectForKey:@"usersCount"] integerValue];
            int tipsCount = [[stats objectForKey:@"tipsCount"] integerValue];

            [currentVenueDetails setObject:@[
                 @[@"Check-Ins", [NSNumber numberWithInt:checkinsCount]],
                 @[@"Users", [NSNumber numberWithInt:usersCount]],
                 @[@"Tips", [NSNumber numberWithInt:tipsCount]]
             ] forKey:TAK_FOURSQUARE_STATISTICS];
            
            [processed addObject:(NSArray *)currentVenueDetails];
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
    
    NSLog(@"processed: %@", processed);
    
    return (NSArray *)processed;
}

@end
