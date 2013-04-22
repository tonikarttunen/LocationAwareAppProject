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
    NSString *imageName;
    if (([UIScreen mainScreen].scale == 2.0f) && ([UIScreen mainScreen].bounds.size.height == 568.0f)) {
        imageName = @"FoursquareLogin-568h";
    } else {
        imageName = @"FoursquareLogin";
    }
    UIImageView *imageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:imageName]];
    imageView.frame = CGRectMake(0.0f, 0.0f, self.bounds.size.width, self.bounds.size.height);
    imageView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleWidth;
    imageView.opaque = YES;
    [self addSubview:imageView];
    
    _authorizationButton = [UIButton buttonWithType:UIButtonTypeCustom];
    _authorizationButton.frame = CGRectMake(88.0f, 238.0f, 144.0f, 44.0f);
    _authorizationButton.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin | UIViewAutoresizingFlexibleLeftMargin | UIViewAutoresizingFlexibleRightMargin;
    // _authorizationButton.backgroundColor = [UIColor colorWithRed:0.5 green:0.7 blue:0.8 alpha:1.0];
    [_authorizationButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    _authorizationButton.titleLabel.font = [UIFont fontWithName:@"HelveticaNeue-Bold" size:20.0];
    [_authorizationButton setTitle:@"Log In" forState:UIControlStateNormal];
    _authorizationButton.backgroundColor = [UIColor clearColor];
    [_authorizationButton setBackgroundImage:[UIImage imageNamed:@"FoursquareLoginButton"] forState:UIControlStateNormal];
    // _authorizationButton.layer.cornerRadius = 8.0f;
    [_authorizationButton addTarget:self action:@selector(startFoursquareAuthorization) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_authorizationButton];
}

- (void)startFoursquareAuthorization
{
    TAKAppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    if (appDelegate && appDelegate.foursquareController && appDelegate.foursquareController.foursquare) {
        BZFoursquare *foursquare = appDelegate.foursquareController.foursquare;
        [foursquare startAuthorization];
    }
}

@end
