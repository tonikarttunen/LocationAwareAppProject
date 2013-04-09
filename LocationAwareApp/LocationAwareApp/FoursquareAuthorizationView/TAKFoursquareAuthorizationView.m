//
//  TAKFoursquareAuthorizationView.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/9/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <QuartzCore/QuartzCore.h>
#import "TAKFoursquareAuthorizationView.h"
#import "TAKFoursquareLocalSearchResultsViewController.h"
#import "TAKAppDelegate.h"

@interface TAKFoursquareAuthorizationView ()

@property (nonatomic, strong) UIButton *authorizationButton;

@end

@implementation TAKFoursquareAuthorizationView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        
        [self generateUI];
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

- (void)setViewBasicProperties
{
    self.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleBottomMargin;
    self.backgroundColor = [UIColor greenColor];
    self.opaque = YES;
}

- (void)generateUI
{
    [self setViewBasicProperties];
    
    _authorizationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _authorizationButton.frame = CGRectMake(88.0f, 176.0f, 144.0f, 44.0f);
    _authorizationButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    _authorizationButton.backgroundColor = [UIColor whiteColor];
    [_authorizationButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    _authorizationButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:18.0];
    [_authorizationButton setTitle:@"Log In" forState:UIControlStateNormal];
    [_authorizationButton setBackgroundImage:[UIImage imageNamed:@"Icon"] forState:UIControlStateNormal];
    _authorizationButton.layer.cornerRadius = 8.0f;
    [_authorizationButton addTarget:self action:@selector(startFoursquareAuthorization) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_authorizationButton];
}

- (void)startFoursquareAuthorization
{
    // TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    TAKFoursquareLocalSearchResultsViewController *foursquareSearchResultsViewController = (TAKFoursquareLocalSearchResultsViewController *)[self parentViewController];
    BZFoursquare *foursquare = foursquareSearchResultsViewController.foursquare;
    [foursquare startAuthorization];
}

@end
