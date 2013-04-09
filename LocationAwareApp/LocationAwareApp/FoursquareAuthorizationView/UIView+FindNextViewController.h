//
//  UIView+FindNextViewController.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/9/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIView (FindNextViewController)

- (UIViewController *)parentViewController;
- (id)findParentViewController;

@end
