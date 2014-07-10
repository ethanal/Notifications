//
//  NotificationListViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 7/9/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "NotificationListViewController.h"
#import "UnreadIndicatorView.h"

@interface NotificationListViewController ()

@property (nonatomic, strong) NSMutableArray *notifications;

@end

@implementation NotificationListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Notifications";
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.notifications = [[NSMutableArray alloc] initWithObjects:@"Notification 1", @"Notification 2", @"Notification 3", @"Notification 4", nil];
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
    
    
    int diameter = 8;
    CGRect frame = CGRectMake(3, 17, diameter, diameter);
    
    BOOL isUnread = YES;
    
    UIView *indicatorView = [cell.contentView viewWithTag:1];
    
    if (indicatorView) {
        ((UnreadIndicatorView *)indicatorView).status = isUnread;
    } else {
        UnreadIndicatorView *indicator = [[UnreadIndicatorView alloc] initWithFrame:frame status:isUnread];
        indicator.tag = 1;
        [cell.contentView addSubview:indicator];
    }
    
    cell.textLabel.text = [self.notifications objectAtIndex:indexPath.row];
    
    return cell;
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
