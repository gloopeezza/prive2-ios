//
//  PVDialogViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/11/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVDialogViewController.h"
#import "PVManagedDialog.h"
#import "PVManagedMessage.h"
#import "PVManagedBuddy.h"

static NSString * const kPVDialogViewControllerMessageCellReuseIdentifier = @"kPVDialogViewControllerMessageCellReuseIdentifier";

@interface PVDialogViewController () {
    PVManagedDialog *_dialog;
}

@end

@implementation PVDialogViewController

- (id)initWithDialog:(PVManagedDialog *)dialog {
    self = [super initWithStyle:UITableViewStylePlain];
    
    if (self) {
        _dialog = dialog;
    }
    
    return self;
}

- (Class)entityClass {
    return [PVManagedMessage class];
}

- (NSArray *)sortDescriptors {
    return @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]];
}

- (NSFetchRequest *)fetchRequest {
    NSFetchRequest *request = [super fetchRequest];
    request.predicate = [NSPredicate predicateWithFormat:@"dialog == %@", self.dialog];
    return request;
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PVManagedMessage *message = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = message.text;
    cell.detailTextLabel.text = [NSString stringWithFormat:@"From %@", message.dialog.buddy.address];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPVDialogViewControllerMessageCellReuseIdentifier];\
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPVDialogViewControllerMessageCellReuseIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

@end
