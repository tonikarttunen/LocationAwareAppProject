//
//  Constants.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/4/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#ifndef LocationAwareApp_Constants_h
#define LocationAwareApp_Constants_h

// Information sources
typedef enum TAKInformationSourceType : NSUInteger {
    TAKInformationSourceTypeApple,
    TAKInformationSourceTypeFoursquare,
    TAKInformationSourceTypeGoogle
} TAKInformationSourceType;

// Locations
typedef enum TAKLocationType : NSUInteger {
    TAKLocationTypeCurrentLocation,
    TAKLocationTypeOtaniemi,
    TAKLocationTypeSchonberg,
    TAKLocationTypePittsburgh,
    TAKLocationTypeSuzhou
} TAKLocationType;

#define TAK_OTANIEMI_LATITUDE       60.186933
#define TAK_OTANIEMI_LONGITUDE      24.827261

#define TAK_SCHONBERG_LATITUDE      54.392899
#define TAK_SCHONBERG_LONGITUDE     10.374110

#define TAK_PITTSBURGH_LATITUDE     40.440625
#define TAK_PITTSBURGH_LONGITUDE    -79.995886

#define TAK_SUZHOU_LATITUDE         31.207516
#define TAK_SUZHOU_LONGITUDE        120.613403

// UI
#define TAK_STANDARD_TOOLBAR_HEIGHT     44.0f
#define TAK_SEGMENTED_CONTROL_HEIGHT    31.0f
#define TAK_SEGMENTED_CONTROL_WIDTH     308.0f

// Foursquare
#define TAK_FOURSQUARE_BASIC_INFORMATION    @"Basic Information"
#define TAK_FOURSQUARE_LOCATION             @"Location"
#define TAK_FOURSQUARE_STATISTICS           @"Statistics"

// User defaults
#define TAK_LOCATION_TYPE     @"LocationType"
#define TAK_LOCATION_ACCURACY @"LocationAccuracy"

#define TAK_LOCATION_ACCURACY_BEST              @"LocationAccuracyBest"
#define TAK_LOCATION_ACCURACY_TEN_METERS        @"LocationAccuracyTenMeters"
#define TAK_LOCATION_ACCURACY_HUNDRED_METERS    @"LocationAccuracyHundredMeters"
#define TAK_LOCATION_ACCURACY_ONE_KILOMETER     @"LocationAccuracyOneKilometer"
#define TAK_LOCATION_ACCURACY_THREE_KILOMETERS  @"LocationAccuracyThreeKilometers"

#endif
