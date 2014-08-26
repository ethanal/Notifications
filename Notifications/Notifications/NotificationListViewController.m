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
#import "APIClient.h"

@interface NotificationListViewController ()

@property (nonatomic, strong) NSMutableArray *notifications;

@end

@implementation NotificationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = self.feed.name;
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self loadNotifications];
}

- (void)loadNotifications {
    NSLog(@"%@", self.feed.id);
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

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.notifications count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"NotificationListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    Notification *notification = (Notification *)[self.notifications objectAtIndex:indexPath.row];
    
    int diameter = 8;
    CGRect frame = CGRectMake(3, 17, diameter, diameter);
    
    BOOL isUnread = !notification.viewed;
    
    UIView *indicatorView = [cell.contentView viewWithTag:1];
    
    if (indicatorView) {
        ((UnreadIndicatorView *)indicatorView).status = isUnread;
    } else {
        UnreadIndicatorView *indicator = [[UnreadIndicatorView alloc] initWithFrame:frame status:isUnread];
        indicator.tag = 1;
        [cell.contentView addSubview:indicator];
    }
    
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
