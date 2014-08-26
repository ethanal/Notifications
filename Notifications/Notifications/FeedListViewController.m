//
//  FeedListViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 7/8/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "FeedListViewController.h"
#import "NotificationListViewController.h"
#import "SettingsViewController.h"
#import "UnreadIndicatorView.h"
#import "APIClient.h"
#import <TSMessage.h>

@interface FeedListViewController ()

@property (nonatomic, strong) NSMutableArray *feeds;

@end

@implementation FeedListViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // Set up refresh mechanism
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    // Set up navigation bar buttons
    UIBarButtonItem *settingsBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"GearIcon"]style:UIBarButtonItemStylePlain target:self action:@selector(settingsBarButtonPressed:)];
    self.navigationItem.leftBarButtonItem = settingsBarButton;
    UIBarButtonItem *addFeedBarButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addFeedBarButtonPressed:)];
    self.navigationItem.rightBarButtonItem = addFeedBarButton;
    
    self.title = @"Feeds";
    
    [self loadFeedList];
}

- (void)refresh:(id)sender {
    [[APIClient sharedClient] fetchFeedsWithCallback:^(NSMutableArray *feeds) {
        if (feeds)
            self.feeds = feeds;
        [self.tableView reloadData];
        [(UIRefreshControl *)sender endRefreshing];
    }];
}

- (void)loadFeedList {
    [[APIClient sharedClient] fetchFeedsWithCallback:^(NSMutableArray *feeds) {
        if (feeds)
            self.feeds = feeds;
        [self.tableView reloadData];
    }];
}

- (void)settingsBarButtonPressed:(id)sender {
    SettingsViewController *settingsVC = [[SettingsViewController alloc] initWithStyle:UITableViewStyleGrouped];
    [settingsVC setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    UINavigationController *settingsNavVC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self.navigationController presentViewController:settingsNavVC animated:YES completion:nil];
}


- (void)addFeedBarButtonPressed:(id)sender {
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feeds count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FeedListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NotificationFeed *feed = (NotificationFeed *)[self.feeds objectAtIndex:indexPath.row];
    
    
    int diameter = 8;
    CGRect frame = CGRectMake(3, 17, diameter, diameter);
    
    BOOL hasUnread = feed.hasUnread;
    
    UIView *indicatorView = [cell.contentView viewWithTag:1];
    
    if (indicatorView) {
        ((UnreadIndicatorView *)indicatorView).status = hasUnread;
    } else {
        UnreadIndicatorView *indicator = [[UnreadIndicatorView alloc] initWithFrame:frame status:hasUnread];
        [cell.contentView addSubview:indicator];
        indicatorView.tag = 1;
        
    }
    
    cell.textLabel.text = feed.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationListViewController *notifListVC = [[NotificationListViewController alloc] init];
    notifListVC.feed = (NotificationFeed *)[self.feeds objectAtIndex:indexPath.row];
    [self.navigationController pushViewController:notifListVC animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
