//
//  PVMessage.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVManagedMessage.h"
#import "PVManagedDialog.h"


@implementation PVManagedMessage

@dynamic date;
@dynamic text;
@dynamic fromAddress;
@dynamic dialog;

- (NSString *)day {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = NSDateFormatterFullStyle;
    
    return [dateFormatter stringFromDate:self.date];
}

@end
