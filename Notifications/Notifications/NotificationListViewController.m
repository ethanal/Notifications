//
//  NotificationListViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 7/9/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "NotificationListViewController.h"
#import "NotificationDetailViewController.h"
#import "UnreadIndicatorView.h"
#import "CellWithUnreadIndicator.h"
#import "APIClient.h"

@interface NotificationListViewController ()

@property (nonatomic, strong) NSMutableArray *notifications;

@end

@implementation NotificationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.feed.name;
    self.view.backgroundColor = [UIColor whiteColor];
    
    // Set up refresh mechanism
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    // Set up navigation bar buttons
    UIBarButtonItem *markAllReadButton = [[UIBarButtonItem alloc] initWithTitle:@"Mark All Read" style:UIBarButtonItemStylePlain target:self action:@selector(markAllRead:)];
    self.navigationItem.rightBarButtonItem = markAllReadButton;
    
    [self loadNotifications];
}

- (void)loadNotifications {
    [[APIClient sharedClient] fetchNotificationsForFeedWithID:[self.feed.id intValue] withCallback:^(NSMutableArray *notifications) {
        self.notifications = notifications;
        [self.tableView reloadData];
    }];
}

- (void)refresh:(id)sender {
    [[APIClient sharedClient] fetchNotificationsForFeedWithID:[self.feed.id intValue] withCallback:^(NSMutableArray *notifications) {
        self.notifications = notifications;
        [self.tableView reloadData];
        [(UIRefreshControl *)sender endRefreshing];
    }];
}

- (void)markAllRead:(id)sender {
    [[APIClient sharedClient] markFeedRead:self.feed];
    for (id notification in self.notifications) {
        ((Notification *) notification).viewed = YES;
    }
    [self.tableView reloadData];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notifications count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NotificationListCell";
    CellWithUnreadIndicator *cell = (CellWithUnreadIndicator *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[CellWithUnreadIndicator alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Notification *notification = (Notification *)[self.notifications objectAtIndex:indexPath.row];
    BOOL isUnread = !notification.viewed;
    cell.unreadIndicator.status = isUnread;
    
    cell.textLabel.text = notification.title;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationDetailViewController *notifDetailVC = [[NotificationDetailViewController alloc] init];
    notifDetailVC.notification = (Notification *)[self.notifications objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:notifDetailVC animated:YES];
    
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
