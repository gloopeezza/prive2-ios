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

@interface PVBuddyListViewController () <NSFetchedResultsControllerDelegate, UITableViewDataSource, UITableViewDelegate, UIAlertViewDelegate>

@property (nonatomic, strong, readonly) NSFetchedResultsController *fetchedResultsController;
@property (nonatomic, weak) UIAlertView *addBuddyAlertView;

@end

@implementation PVBuddyListViewController {
    UITableView *_tableView;
    NSFetchedResultsController *_fetchedResultController;
}

- (id)init {
    self = [super init];
    if (self) {
        self.title = @"Contacts";
        self.tabBarItem = [[UITabBarItem alloc] initWithTabBarSystemItem:UITabBarSystemItemContacts tag:0];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addBuddy:)];
    }
    
    return self;
}

- (void)loadView {
    [super loadView];
    [self.view addSubview:self.tableView];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
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
        [[PVChatManager defaultManager] addBuddyWithAddress:buddyAddress alias:@"" info:@""];
        self.addBuddyAlertView = nil;
    }
}

#pragma mark - Table View

- (UITableView *)tableView {
    if (_tableView) return _tableView;
    CGRect frame = CGRectMake(0.0f, 0.0f, CGRectGetWidth(self.view.bounds), CGRectGetHeight(self.view.bounds) - 44.0f);
    UITableView *tableView = [[UITableView alloc] initWithFrame:frame style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    _tableView = tableView;
    return tableView;
}

- (void)configureCell:(UITableViewCell *)cell indexPath:(NSIndexPath *)indexPath {
    PVBuddy *buddy = (PVBuddy *)[self.fetchedResultsController objectAtIndexPath:indexPath];
    cell.textLabel.text = buddy.alias;
    cell.detailTextLabel.text = buddy.address;
}

#pragma mark - UITableViewDelegate

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        PVBuddy *buddy = [self.fetchedResultsController objectAtIndexPath:indexPath];
        [[PVChatManager defaultManager] removeBuddyWithAddress:buddy.address];
    }
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.fetchedResultsController.sections.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    id <NSFetchedResultsSectionInfo> sectionInfo = [[self.fetchedResultsController sections] objectAtIndex:section];
    return [sectionInfo numberOfObjects];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:kPVBuddyListViewControllerCellReuseIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:kPVBuddyListViewControllerCellReuseIdentifier];
    }

    [self configureCell:cell indexPath:indexPath];
    return cell;
}


#pragma mark - NSFetchedResultController

- (NSFetchedResultsController *)fetchedResultsController {
    if (!_fetchedResultController) {
        _fetchedResultController = [[PVChatManager defaultManager] createBuddiesFetchedResultController];
        _fetchedResultController.delegate = self;
    }
    
    return _fetchedResultController;
}

#pragma mark - NSFetchedResultsControllerDelegate

- (void)controllerWillChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView beginUpdates];
}

- (void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath {
    switch (type) {
        case NSFetchedResultsChangeInsert: {
            [self.tableView insertRowsAtIndexPaths:@[newIndexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
            
        case NSFetchedResultsChangeDelete: {
            [self.tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
            
        case NSFetchedResultsChangeUpdate: {
            [self.tableView reloadRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            break;
        }
        
        case NSFetchedResultsChangeMove: {
            break;
        }
            
        default:
            break;
    }
}

- (void)controllerDidChangeContent:(NSFetchedResultsController *)controller {
    [self.tableView endUpdates];
}

@end
