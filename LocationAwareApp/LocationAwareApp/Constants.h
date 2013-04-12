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

// Local search categories
#define TAK_COFFEE              @"Coffee"
#define TAK_LUNCH               @"Lunch"
#define TAK_DINNER              @"Dinner"
#define TAK_THEATRE             @"Theatre"
#define TAK_NIGHTLIFE           @"Nightlife"
#define TAK_MOVIES              @"Movies"
#define TAK_ART_MUSEUMS         @"Art Museums"
#define TAK_MUSEUMS             @"Museums"
#define TAK_SPORTS              @"Sports"
#define TAK_BEACH               @"Beach"
#define TAK_TOURIST_ATTRACTIONS @"Tourist Attractions"
#define TAK_SHOPPING            @"Shopping"
#define TAK_EVENTS              @"Events"
#define TAK_ARCHITECTURE        @"Architecture"

// UI
#define TAK_STANDARD_TOOLBAR_HEIGHT     44.0f
#define TAK_SEGMENTED_CONTROL_HEIGHT    31.0f
#define TAK_SEGMENTED_CONTROL_WIDTH     308.0f

#endif
