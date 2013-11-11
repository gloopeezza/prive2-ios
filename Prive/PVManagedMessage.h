//
//  PVMessage.h
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "SSManagedObject.h"

@class PVManagedDialog;

@interface PVManagedMessage : SSManagedObject

@property (nonatomic, retain) NSDate * date;
@property (nonatomic, retain) NSString * text;
@property (nonatomic, retain) NSString * fromAddress;
@property (nonatomic, retain) PVManagedDialog *dialog;

@end
