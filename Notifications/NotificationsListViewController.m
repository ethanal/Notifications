//
//  NotificationsListViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 10/12/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import "NotificationsListViewController.h"
#import "Notification.h"
#import "NotificationsAPIClient.h"
#import "NotificationDetailViewController.h"
#import "UnreadNotificationsIndicatorView.h"

@interface NotificationsListViewController ()

@end

@implementation NotificationsListViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
    self.notifications = [[NSMutableArray alloc] initWithCapacity:20];
    
    UIRefreshControl *refreshControl = [[UIRefreshControl alloc] init];
    [refreshControl addTarget:self action:@selector(refresh:) forControlEvents:UIControlEventValueChanged];
    [self setRefreshControl:refreshControl];
}

- (void)viewWillAppear:(BOOL)animated
{
    [self loadNotifications];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.notifications count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"NotificationCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
        
    int diameter = 8;
    CGRect frame = CGRectMake(3, 17, diameter, diameter);
    
    BOOL read = ((Notification *)[self.notifications objectAtIndex:indexPath.row]).read;
    
    UIView *indicatorView = [cell.contentView viewWithTag:1];
    
    if (indicatorView) {
        ((UnreadNotificationsIndicatorView *)indicatorView).active = !read;
    } else {
        UnreadNotificationsIndicatorView *indicator = [[UnreadNotificationsIndicatorView alloc] initWithFrame:frame status:!read];
        
        indicator.tag = 1;
        [cell.contentView addSubview:indicator];
    }
    
    
    
    cell.textLabel.text = ((Notification *)[self.notifications objectAtIndex:indexPath.row]).message;
    
    NSDate *date = ((Notification *)[self.notifications objectAtIndex:indexPath.row]).sentDate;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"'Sent' dd MMM, yyyy 'at' h:mm:ss a"];
    cell.detailTextLabel.text = [dateFormatter stringFromDate:date];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (void)loadNotifications
{
    [[NotificationsAPIClient sharedClient] fetchNotificationsForFeed:self.feed withCallback:^(NSMutableArray *notifications) {
        self.notifications = notifications;
        [self.tableView reloadData];
    }];
}

- (void)refresh:(id)sender
{
    [[NotificationsAPIClient sharedClient] fetchNotificationsForFeed:self.feed withCallback:^(NSMutableArray *notifications) {
        self.notifications = notifications;
        [self.tableView reloadData];
        [(UIRefreshControl *)sender endRefreshing];
    }];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowNotificationDetail"]) {
        NotificationDetailViewController *detailViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        
        detailViewController.notification = [self.notifications objectAtIndex:indexPath.row];
        
    }
}

- (IBAction)markAllRead:(id)sender
{
    for (Notification *notification in self.notifications) {
        if (!notification.read)
            [[NotificationsAPIClient sharedClient] markNotificationRead:notification];
        [self loadNotifications];
    }
}

- (IBAction)unwindToNotificationList:(UIStoryboardSegue *)segue
{
    [self loadNotifications];
    [self dismissViewControllerAnimated:YES completion:nil];
}

@end
