//
//  PVDialogViewController.h
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "SSManagedTableViewController.h"
#import "HPGrowingTextView.h"

@class PVManagedDialog;

@interface PVDialogViewController : SSManagedTableViewController<HPGrowingTextViewDelegate>

@property (nonatomic, strong, readonly) PVManagedDialog *dialog;

- (id)initWithDialog:(PVManagedDialog *)dialog;
- (void)sendMessage;

@end
