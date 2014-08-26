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
#import "APIClient.h"
#import "CellWithUnreadIndicator.h"
#import "SubscribeToFeedViewController.h"
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
}

- (void)viewWillAppear:(BOOL)animated {
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
    settingsVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    UINavigationController *settingsNavVC = [[UINavigationController alloc] initWithRootViewController:settingsVC];
    [self.navigationController presentViewController:settingsNavVC animated:YES completion:nil];
}


- (void)addFeedBarButtonPressed:(id)sender {
    SubscribeToFeedViewController *subscribeVC = [SubscribeToFeedViewController new];
    subscribeVC.modalPresentationStyle = UIModalTransitionStyleCoverVertical;
    subscribeVC.feeds = [NSMutableArray new];
    UINavigationController *subscribeNavVC = [[UINavigationController alloc] initWithRootViewController:subscribeVC];
    [self.navigationController presentViewController:subscribeNavVC animated:YES completion:nil];
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    [[APIClient sharedClient] unsubscribeFromFeedWithID:[((NotificationFeed *)[self.feeds objectAtIndex:indexPath.row]).id intValue]];
    [self.feeds removeObjectAtIndex:indexPath.row];
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}


- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Unsubscribe";
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.feeds count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FeedListCell";
    CellWithUnreadIndicator *cell = (CellWithUnreadIndicator *)[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[CellWithUnreadIndicator alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    NotificationFeed *feed = (NotificationFeed *)[self.feeds objectAtIndex:indexPath.row];
    BOOL hasUnread = feed.hasUnread;
    cell.unreadIndicator.status = hasUnread;
    
    cell.textLabel.text = feed.name;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NotificationListViewController *notifListVC = [NotificationListViewController new];
    NotificationFeed *feed = (NotificationFeed *)[self.feeds objectAtIndex:indexPath.row];
    notifListVC.feedID = [feed.id intValue];
    notifListVC.title = feed.name;
    [self.navigationController pushViewController:notifListVC animated:YES];

    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

@end
