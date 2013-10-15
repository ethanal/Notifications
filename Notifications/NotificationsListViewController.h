//
//  NotificationsListViewController.h
//  Notifications
//
//  Created by Ethan Lowman on 10/12/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Feed.h"

@interface NotificationsListViewController : UITableViewController

- (void)loadNotifications;
- (void)refresh:(id)sender;
- (IBAction)markAllRead:(id)sender;

@property (strong) Feed *feed;
@property (strong) NSMutableArray *notifications;

@end
