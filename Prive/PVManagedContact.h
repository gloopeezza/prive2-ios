//
//  PVBuddy.h
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSManagedObject.h"

typedef NS_ENUM(NSInteger, PVManagedContactStatus) {
    PVManagedContactStatusOnline,
    PVManagedContactStatusOffline
};


@class PVManagedDialog;
@interface PVManagedContact : SSManagedObject;

@property (nonatomic, retain) NSString * address;
@property (nonatomic, retain) NSString * alias;
@property (nonatomic, retain) NSString * info;
@property (nonatomic, retain) PVManagedDialog * dialog;

@property (nonatomic, assign) PVManagedContactStatus status;

@end
