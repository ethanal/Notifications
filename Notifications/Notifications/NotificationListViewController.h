//
//  NotificationListViewController.h
//  Notifications
//
//  Created by Ethan Lowman on 7/9/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "NotificationFeed.h"
@interface NotificationListViewController : UITableViewController

@property (nonatomic, strong) NotificationFeed *feed;

@end
