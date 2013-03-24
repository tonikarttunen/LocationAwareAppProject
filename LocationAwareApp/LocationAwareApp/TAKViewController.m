//
//  TAKViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 3/20/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "TAKViewController.h"
#import "TAKGeocoder.h"

@interface TAKViewController ()

@end

@implementation TAKViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.mapView = [[TAKMapView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:self.mapView];
    
    TAKGeocoder *geo = [[TAKGeocoder alloc] init];
    
    CLLocation *location = [[CLLocation alloc] initWithLatitude:37.781516 longitude:-122.404955];
    [geo reverseGeocodeLocation:location];
    
    NSString *address = @"Aleksanterinkatu 52, Helsinki, Finland";
    [geo forwardGeocodeAddress:address];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc
{
    self.mapView = nil;
}

@end
