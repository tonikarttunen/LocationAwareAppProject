//
//  NSArray+FoursquareDictionaryProcessor.h
//  LocationAwareApp
//
//  Created by Toni Antero Karttunen on 4/13/13.
//  Copyright (c) 2013 Toni Antero Karttunen. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSArray (FoursquareDictionaryProcessor)

+ (NSArray *)processFoursquareDictionary:(NSDictionary *)dictionary searchPathComponents:(NSArray *)components;

@end
