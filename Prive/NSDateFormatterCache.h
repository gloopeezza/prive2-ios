//
//  NSDateFormatterCache.h
//  Prive
//
//  Created by Andrey Tyshlaev on 11/14/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSDateFormatterCache : NSObject

+ (NSDateFormatter *) sharedDateFormatter;

+ (NSString *) stringFromDate:(NSDate *) value withFormat:(NSString *) format;

@end
