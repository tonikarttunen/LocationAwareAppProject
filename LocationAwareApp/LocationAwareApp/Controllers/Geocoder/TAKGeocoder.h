//
//  TAKGeocoder.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/24/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import <AddressBookUI/AddressBookUI.h>

@interface TAKGeocoder : NSObject

@property (nonatomic, strong) NSMutableDictionary *addressDictionary;
@property (nonatomic, strong) CLLocation *addressLocation;

- (NSDictionary *)reverseGeocodeLocation:(CLLocation *)location;
- (CLLocation *)forwardGeocodeAddress:(NSString *)address;

@end
