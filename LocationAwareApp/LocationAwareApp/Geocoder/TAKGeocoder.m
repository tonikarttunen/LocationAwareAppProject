//
//  TAKGeocoder.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/24/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKGeocoder.h"

@implementation TAKGeocoder

- (id)init
{
    self = [super init];
    if (self) {
        self.addressDictionary = [NSMutableDictionary new];
        self.addressLocation = [CLLocation new];
    }
    return self;
}


- (NSDictionary *)reverseGeocodeLocation:(CLLocation *)location
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        [self setGeocodedPropertiesBasedOnPlacemarkArray:placemarks error:error];
    }];
    return (NSDictionary *)self.addressDictionary;
}

- (CLLocation *)forwardGeocodeAddress:(NSString *)address
{
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    [geocoder geocodeAddressString:address completionHandler:^(NSArray *placemarks, NSError *error) {
        [self setGeocodedPropertiesBasedOnPlacemarkArray:placemarks error:error];
    }];
    return self.addressLocation;
}

- (void)setGeocodedPropertiesBasedOnPlacemarkArray:(NSArray *)placemarks error:(NSError *)error
{
    if (error) {
        NSLog(@"Error %@: %@", error.description, [self humanReadableMessageWithErrorCode:error.code]);
        return;
    }
    
    if (!placemarks) {
        return;
    }
    
    @try {
        if (placemarks.count > 0) {
            CLPlacemark *lastPlacemark = [placemarks lastObject];
            
            self.addressDictionary = (NSMutableDictionary *)lastPlacemark.addressDictionary;
            NSString *addressString = ABCreateStringWithAddressDictionary(lastPlacemark.addressDictionary, YES);
            NSLog(@"Address: %@", addressString);
            // NSLog(@"%@", lastPlacemark.addressDictionary);
            NSLog(@"%@", self.addressDictionary);
            
            self.addressLocation = lastPlacemark.location;
            NSLog(@"Location: latitude: %f, longitude: %f",
                  self.addressLocation.coordinate.latitude, self.addressLocation.coordinate.longitude);
        } else {
            NSLog(@"\n\nNo placemarks found.\n\n");
        }
    }
    @catch (NSException *exception) {
        NSLog(@"%@", exception.description);
    }
}

- (NSString *)humanReadableMessageWithErrorCode:(int)errorCode
{
    NSString *humanReadableMessage;
    
    switch (errorCode) {
        case kCLErrorDenied:
            humanReadableMessage = @"Access to the Location Service Was Denied by the User";
            break;
            
        case kCLErrorGeocodeCanceled:
            humanReadableMessage = @"Geocode Request Was Canceled";
            break;
            
        case kCLErrorGeocodeFoundNoResult:
            humanReadableMessage = @"No Results";
            break;
            
        case kCLErrorGeocodeFoundPartialResult:
            humanReadableMessage = @"The Geocode Request Only Yielded a Partial Result";
            break;
            
        case kCLErrorLocationUnknown:
            humanReadableMessage = @"Location Unknown";
            break;
        
        case kCLErrorNetwork:
            humanReadableMessage = @"Network Error";
            break;
            
        default:
            humanReadableMessage = @"Error";
            break;
    }
    
    return humanReadableMessage;
}

@end
