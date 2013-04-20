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
            double rating = [[currentVenue objectForKey:@"rating"] doubleValue];
            NSString *phone = [[currentVenue objectForKey:@"contact"] objectForKey:@"formattedPhone"];
            if (phone == nil) {
                phone = @"N/A";
            }
            NSString *website = [currentVenue objectForKey:@"url"];
            if (website == nil) {
                website = @"N/A";
            }
            NSString *twitter = [[currentVenue objectForKey:@"contact"] objectForKey:@"twitter"];
            if (twitter == nil) {
                twitter = @"N/A";
            }
            [currentVenueDetails setObject:@[@[@"Name", name],
                                             @[@"ID", venueID],
                                             @[@"Phone", phone],
                                             @[@"Website", website],
                                             @[@"Twitter", twitter],
                                             @[@"Rating", [NSNumber numberWithDouble:rating]]]
                                    forKey:TAK_FOURSQUARE_BASIC_INFORMATION];
            
            // Location
            NSDictionary *location = [currentVenue objectForKey:@"location"];
            double latitude = [[location objectForKey:@"lat"] doubleValue];
            double longitude = [[location objectForKey:@"lng"] doubleValue];
            int distance = [[location objectForKey:@"distance"] integerValue];
            NSMutableString *address = [location objectForKey:@"address"];
            
            // If a street name isn't available, check if the cross street is known
            if (address == nil) {
                address = (NSMutableString *)[location objectForKey:@"crossStreet"];
            }
            
            // Postal code
            NSMutableString *postalCode = (NSMutableString *)[location objectForKey:@"postalCode"];
            if (address == nil) {
                address = postalCode;
            } else {
                if (postalCode != nil) {
                    address = (NSMutableString *)[NSMutableString stringWithFormat:@"%@, %@", address, postalCode];
                }
            }
            
            // City
            NSMutableString *city = (NSMutableString *)[location objectForKey:@"city"];
            if (address == nil) {
                address = city;
            } else {
                if (city != nil) {
                    address = (NSMutableString *)[NSMutableString stringWithFormat:@"%@ %@", address, city];
                }
            }
            
            // State
            NSMutableString *state = (NSMutableString *)[location objectForKey:@"state"];
            if (address == nil) {
                address = state;
            } else {
                if (state != nil) {
                    address = (NSMutableString *)[NSMutableString stringWithFormat:@"%@, %@", address, state];
                }
            }
            
            // Country
            NSMutableString *country = (NSMutableString *)[location objectForKey:@"country"];
            if (address == nil) {
                address = country;
            } else {
                if (country != nil) {
                    address = (NSMutableString *)[NSMutableString stringWithFormat:@"%@, %@", address, country];
                }
            }
            
            // Unknown address
            if (address == nil) {
                address = (NSMutableString *)@"N/A";
            }
            
            [currentVenueDetails setObject:@[
                                             @[@"Latitude", [NSNumber numberWithDouble:latitude]],
                                             @[@"Longitude", [NSNumber numberWithDouble:longitude]],
                                             @[@"Distance", [NSNumber numberWithInt:distance]],
                                             @[@"Address", (NSString *)address]
                                            ] forKey:TAK_FOURSQUARE_LOCATION];
            
            // Statistics
            NSDictionary *stats = [currentVenue objectForKey:@"stats"];
            int checkinsCount = [[stats objectForKey:@"checkinsCount"] integerValue];
            int usersCount = [[stats objectForKey:@"usersCount"] integerValue];
            int tipsCount = [[stats objectForKey:@"tipsCount"] integerValue];
            int hereNow = [[[currentVenue objectForKey:@"hereNow"] objectForKey:@"count"] integerValue];
            
            // Likes
            NSDictionary *likes = [currentVenue objectForKey:@"likes"];
            int likesCount = [[likes objectForKey:@"count"] integerValue];

            [currentVenueDetails setObject:@[
                 [NSMutableArray arrayWithObjects:@"Check-Ins", [NSNumber numberWithInt:checkinsCount], nil],
                 [NSMutableArray arrayWithObjects:@"Users", [NSNumber numberWithInt:usersCount], nil],
                 [NSMutableArray arrayWithObjects:@"Here Now", [NSNumber numberWithInt:hereNow], nil],
                 [NSMutableArray arrayWithObjects:@"Tips", [NSNumber numberWithInt:tipsCount], nil],
                 [NSMutableArray arrayWithObjects:@"Likes", [NSNumber numberWithInt:likesCount], nil]
             ] forKey:TAK_FOURSQUARE_STATISTICS];
            
            NSString *path = [[NSBundle mainBundle] pathForResource:@"poweredByFoursquare" ofType:@"png"];
            UIImage *image = [[UIImage alloc] initWithContentsOfFile:path];
            [currentVenueDetails setObject:[NSMutableArray arrayWithObjects:@"", image, nil] forKey:@"Image"];
            
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
