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
#import "AFNetworking.h"

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
    
    [self loadFeedList];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)loadFeedList
{
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    
    [manager GET:@"http://pugme.herokuapp.com/bomb?count=10" parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             [feedList addObjectsFromArray:[responseObject objectForKey:@"pugs"]];
             [self.tableView reloadData];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [feedList count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    
    static NSString *CellIdentifier = @"FeedListCell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    int diameter = 8;
    CGRect frame = CGRectMake(3, 17, diameter, diameter);
    UnreadNotificationsIndicatorView *indicator = [[UnreadNotificationsIndicatorView alloc] initWithFrame:frame status:indexPath.row % 2 == 0];
    
    indicator.tag = 1;
    indicator.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    
    [cell.contentView addSubview:indicator];
    
    NSString *category = [feedList objectAtIndex:indexPath.row];
    
    cell.textLabel.text = category;
    
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}


- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([[segue identifier] isEqualToString:@"ShowNotificationsList"]) {
        NotificationsListViewController *detailViewController = [segue destinationViewController];
        NSIndexPath *indexPath = [self.tableView indexPathForSelectedRow];
        detailViewController.notifications = [[NSMutableArray alloc] initWithObjects:@"1", @"2", @"3", @"4", @"5", nil];
        detailViewController.title = [feedList objectAtIndex:indexPath.row];
    }
}

@end
