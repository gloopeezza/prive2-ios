//
//  PVBuddyListViewController.m
//  Prive
//
//  Created by Ivan Doroshenko on 11/6/13.
//  Copyright (c) 2013 Prive. All rights reserved.
//

#import "PVBuddyListViewController.h"
#import "PVChatManager.h"
#import "PVBuddy.h"

static NSString * const kPVBuddyListViewControllerCellReuseIdentifier = @"kPVBuddyListViewControllerCellReuseIdentifier";

@interface PVBuddyListViewController () <UIAlertViewDelegate>

@property (nonatomic, weak) UIAlertView *addBuddyAlertView;

@end

@implementation PVBuddyListViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self.title = @"Contacts";
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
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
    PVBuddy *buddy = (PVBuddy *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = buddy.alias;
    cell.detailTextLabel.text = buddy.address;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PVBuddy *buddy = [self.fetchedResultsController objectAtIndexPath:indexPath];
    [[PVChatManager defaultManager] sendMessage:@"test" toBuddyWithAddress:buddy.address];
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PVBuddy *buddy = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[PVChatManager defaultManager] removeBuddy:buddy.address];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDataSource

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPVBuddyListViewControllerCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPVBuddyListViewControllerCellReuseIdentifier];
    }
    [self configureCell:cell atIndexPath:indexPath];
    return cell;
}

#pragma mark - SSManagedTableViewController

- (Class)entityClass {
    return [PVBuddy class];
}

- (NSArray *)sortDescriptors {
    NSSortDescriptor *sortByAliasDescriptor = [[NSSortDescriptor alloc] initWithKey:@"alias" ascending:YES];
    return @[sortByAliasDescriptor];
}

@end
