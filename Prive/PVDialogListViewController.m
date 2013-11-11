//
//  PVChatDialogListViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/8/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVDialogListViewController.h"
#import "PVManagedContact.h"
#import "PVManagedDialog.h"
#import "PVDialogViewController.h"

static NSString * const kPVChatDialogListViewControllerCellReuseIdentifier = @"kPVChatDialogListViewControllerCellReuseIdentifier";

@interface PVDialogListViewController ()

@end

@implementation PVDialogListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    
    if (self) {
        self.title = @"Dialogs";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Dialogs" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar-dialogs-highlighted"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar-dialogs-normal"]];
    }
    
    return self;
}

- (Class)entityClass {
    return [PVManagedDialog class];
}

- (NSArray *)sortDescriptors {
    return @[[[NSSortDescriptor alloc] initWithKey:@"date" ascending:YES]];
}

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PVManagedDialog *dialog = [self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = dialog.buddy.address;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPVChatDialogListViewControllerCellReuseIdentifier];
    
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:kPVChatDialogListViewControllerCellReuseIdentifier];
    }
    
    [self configureCell:cell atIndexPath:indexPath];
    
    return cell;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    PVManagedDialog *dialog = [self.fetchedResultsController objectAtIndexPath:indexPath];
    PVDialogViewController *dialogController = [[PVDialogViewController alloc] initWithDialog:dialog];
    
    [self.navigationController pushViewController:dialogController animated:YES];
}

@end
