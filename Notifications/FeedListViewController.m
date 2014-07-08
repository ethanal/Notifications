//
//  ViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 10/11/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import "FeedListViewController.h"
#import "NotificationsListViewController.h"
#import "UnreadNotificationsIndicatorView.h"
#import "NotificationsAPIClient.h"
#import "Feed.h"
#import "Config.h"
#import <AFNetworking.h>

@interface FeedListViewController ()

@end

@implementation FeedListViewController {
    NSMutableArray *feedList;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    feedList = [[NSMutableArray alloc] initWithCapacity: 10];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
    
    UIColor *navColor = [UIColor colorWithRed:53.0/255.0 green:73.0/255.0 blue:94.0/255.0 alpha:1.0];
    [self.navigationController.navigationBar setBarTintColor:navColor];
    [self.navigationController.navigationBar setTranslucent:NO];
    //set title color
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObject:[UIColor whiteColor] forKey:UITextAttributeTextColor]];
    //set back button color
    [[UIBarButtonItem appearanceWhenContainedIn:[UINavigationBar class], nil] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor], UITextAttributeTextColor,nil] forState:UIControlStateNormal];
    //set back button arrow color
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadFeedList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFeedList
{
    [[NotificationsAPIClient sharedClient] fetchFeedWithCallback:^(NSMutableArray *feeds) {
        if (feeds)
            feedList = feeds;
        [self.tableView reloadData];
    }];
}

- (void)refresh:(id)sender
{
    [[NotificationsAPIClient sharedClient] fetchFeedWithCallback:^(NSMutableArray *feeds) {
        if (feeds)
            feedList = feeds;
        [self.tableView reloadData];
        [(UIRefreshControl *)sender endRefreshing];
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [feedList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"FeedListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    int diameter = 8;
    CGRect frame = CGRectMake(3, 17, diameter, diameter);
    
    BOOL hasUnread = ((Feed *)[feedList objectAtIndex:indexPath.row]).hasUnread;

    UIView *indicatorView = [cell.contentView viewWithTag:1];
    
    if (indicatorView) {
        ((UnreadNotificationsIndicatorView *)indicatorView).active = hasUnread;
    } else {
        UnreadNotificationsIndicatorView *indicator = [[UnreadNotificationsIndicatorView alloc] initWithFrame:frame status:hasUnread];
        
        indicator.tag = 1;
        [cell.contentView addSubview:indicator];
    }
    
    
    NSString *category = [(Feed *)[feedList objectAtIndex:indexPath.row] name];
    
    cell.textLabel.text = category;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    cell.textLabel.backgroundColor = [UIColor greenColor];
    cell.contentView.backgroundColor = [UIColor yellowColor];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    [[NotificationsAPIClient sharedClient] unsubscribeFromFeed:[feedList objectAtIndex:indexPath.row]];
    [feedList removeObjectAtIndex:indexPath.row];
    [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationLeft];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowNotificationsList"]) {
        NotificationsListViewController *detailViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        detailViewController.notifications = [[NSMutableArray alloc] initWithCapacity:20];
        
        Feed *feed = [feedList objectAtIndex:indexPath.row];
        detailViewController.feed = feed;
        
        detailViewController.title = feed.name;
    }
}

- (IBAction)unwindToFeedList:(UIStoryboardSegue *)segue
{
    [self loadFeedList];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)showSubscribeModal:(id)sender {
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didDismissSubscribeModalViewController)
                                                 name:@"SubscribeModalDismissed"
                                               object:nil];
    [self performSegueWithIdentifier: @"ShowSubscribeModal" sender: self];
}

-(void)didDismissSubscribeModalViewController {
    [self loadFeedList];
}

@end