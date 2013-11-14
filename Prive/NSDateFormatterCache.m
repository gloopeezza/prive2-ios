//
//  NSDateFormatterCache.m
//  Prive
//
//  Created by Andrey Tyshlaev on 11/14/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "NSDateFormatterCache.h"

@implementation NSDateFormatterCache

+ (NSDateFormatter *) sharedDateFormatter {
    static NSDateFormatter *_sharedDateFormatter;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedDateFormatter = [[NSDateFormatter alloc] init];
    });
    return _sharedDateFormatter;
}

+ (NSString *) stringFromDate:(NSDate *) value withFormat:(NSString *) format {
    NSDateFormatter *df = [NSDateFormatterCache sharedDateFormatter];
    [df setDateFormat:format];
    return [df stringFromDate:value];
}

@end
