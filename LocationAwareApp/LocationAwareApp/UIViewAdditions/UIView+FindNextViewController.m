//
//  UIView+FindNextViewController.m
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/9/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import "UIView+FindNextViewController.h"

@implementation UIView (FindNextViewController)

- (UIViewController *)parentViewController
{
    return (UIViewController *)[self findParentViewController];
}

- (id)findParentViewController
{
    @try {
        id nextResponderObject = [self nextResponder];
        
        if ([nextResponderObject isKindOfClass:[UIViewController class]]) {
            return nextResponderObject;
        } else if ([nextResponderObject isKindOfClass:[UIView class]]) {
            return [nextResponderObject findParentViewController];
        } else {
            return nil;
        }
    }
    @catch (NSException *exception) {
        NSLog(@"Cannot find the parent view controller: %@", exception.description);
    }
}

@end
