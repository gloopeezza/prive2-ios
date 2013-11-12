//
//  PVBuddyListViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVContactsListViewController.h"
#import "PVChatManager.h"
#import "PVManagedContact.h"
#import "PVManagedDialog.h"
#import "PVDialogViewController.h"
#import "UIImage+Appearance.h"
#import "PVContactCell.h"

static NSString * const kPVBuddyListViewControllerCellReuseIdentifier = @"kPVBuddyListViewControllerCellReuseIdentifier";

@interface PVContactsListViewController () <UIAlertViewDelegate>

@property (nonatomic, weak) UIAlertView *addBuddyAlertView;

@end

@implementation PVContactsListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Contacts";
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Contacts" image:nil tag:0];
        [self.tabBarItem setFinishedSelectedImage:[UIImage imageNamed:@"tabbar-contacts-highlighted"] withFinishedUnselectedImage:[UIImage imageNamed:@"tabbar-contacts-normal"]];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBuddy:)];
    }
    
    return self;
}

#pragma mark - Alert View

- (UIAlertView *)addBuddyAlertView {
    if (_addBuddyAlertView) return _addBuddyAlertView;
    UIAlertView *addBuddyAlertView = [[UIAlertView alloc] initWithTitle:@"Add buddy" message:@"Enter buddy address" delegate:self cancelButtonTitle:@"Cancel" otherButtonTitles:@"Add", nil];
    addBuddyAlertView.alertViewStyle = UIAlertViewStylePlainTextInput;
    _addBuddyAlertView = addBuddyAlertView;
    return addBuddyAlertView;
}

- (void)addBuddy:(id)sender {
    if (!_addBuddyAlertView) {
        [self.addBuddyAlertView show];
    }
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        NSString *buddyAddress = [alertView textFieldAtIndex:0].text;
        [[PVChatManager defaultManager] addBuddy:buddyAddress alias:nil notes:nil];
        self.addBuddyAlertView = nil;
    }
}

#pragma mark - Table View

- (void)configureCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    PVContactCell *contactCell = (PVContactCell *)cell;
    
    PVManagedContact *buddy = (PVManagedContact *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    contactCell.textLabel.text = buddy.alias;
    contactCell.detailTextLabel.text = buddy.address;
    contactCell.online = YES;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PVManagedContact *buddy = [self.fetchedResultsController objectAtIndexPath:indexPath];
    PVManagedDialog *dialog = buddy.dialog;
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
    
    if (dialog == nil) {
        dialog = [[PVManagedDialog alloc] initWithContext:nil];
        buddy.dialog = dialog;
        [dialog save];
    }
    
    UINavigationController *chatNavigationViewController = self.chatDialogsViewController.navigationController;
    [chatNavigationViewController popToRootViewControllerAnimated:NO];
    self.tabBarController.selectedViewController = chatNavigationViewController;
    
    PVDialogViewController *dialogController = [[PVDialogViewController alloc] initWithDialog:dialog];
    dialogController.hidesBottomBarWhenPushed = YES;
    [chatNavigationViewController pushViewController:dialogController animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PVManagedContact *buddy = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[PVChatManager defaultManager] removeBuddy:buddy.address];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDataSource

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 45.0f;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPVBuddyListViewControllerCellReuseIdentifier];
    if (!cell) {
        cell = [[PVContactCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPVBuddyListViewControllerCellReuseIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - SSManagedTableViewController

- (Class)entityClass {
    return [PVManagedContact class];
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *sortByAliasDescriptor = [[NSSortDescriptor alloc] initWithKey:@"alias" ascending:YES];
    return @[sortByAliasDescriptor];
}

@end
