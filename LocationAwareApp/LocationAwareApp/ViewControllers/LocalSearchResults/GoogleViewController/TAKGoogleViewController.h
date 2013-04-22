//
//  TAKGooglePlacesController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/18/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <GoogleMaps/GoogleMaps.h>

@interface TAKGoogleViewController : UIViewController <UITableViewDelegate, GMSMapViewDelegate>

- (id)initWithCategory:(NSString *)category;

@end
