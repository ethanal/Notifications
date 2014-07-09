//
//  FeedListViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 7/8/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "FeedListViewController.h"
#import "RegisterDeviceModalViewController.h"
#import "UnreadIndicatorView.h"

@interface FeedListViewController ()

@end

@implementation FeedListViewController {
    NSMutableArray *feeds;
}

- (void)viewDidLoad {
    [super viewDidLoad];

    
    // Set up refresh mechanism
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    // Set up navigation bar buttons
    UIBarButtonItem *subscribeToFeedButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(subscribeToFeedButtonPressed:)];
    self.navigationItem.rightBarButtonItem = subscribeToFeedButton;
    
    
    self.title = @"Feeds";
    
    feeds = [[NSMutableArray alloc] initWithObjects:@"Feed 1", @"Feed 2", @"Feed 3", @"Feed 4", nil];
}

- (UIStatusBarStyle)preferredStatusBarStyle {
    return UIStatusBarStyleLightContent;
}



- (void)refresh:(id)sender {
    NSLog(@"refreshing");
    [(UIRefreshControl *)sender endRefreshing];
}

- (void)subscribeToFeedButtonPressed:(id)sender {
    NSLog(@"Subscribing to feed");
    RegisterDeviceModalViewController *modal = [[RegisterDeviceModalViewController alloc] init];
    UINavigationController *modalNavigationController = [[UINavigationController alloc] initWithRootViewController:modal];
    [modal setModalTransitionStyle:UIModalTransitionStyleCoverVertical];
    [self.navigationController presentViewController:modalNavigationController animated:YES completion:nil];
    
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [feeds count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"FeedListCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    
    int diameter = 8;
    CGRect frame = CGRectMake(3, 17, diameter, diameter);
    
    BOOL hasUnread = YES;
    
    UIView *indicatorView = [cell.contentView viewWithTag:1];
    
    if (indicatorView) {
        ((UnreadIndicatorView *)indicatorView).status = hasUnread;
    } else {
        UnreadIndicatorView *indicator = [[UnreadIndicatorView alloc] initWithFrame:frame status:hasUnread];
        
//        indicator.tag = 1;
        [cell.contentView addSubview:indicator];
    }
    
    cell.textLabel.text = [feeds objectAtIndex:indexPath.row];
    
    return cell;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
