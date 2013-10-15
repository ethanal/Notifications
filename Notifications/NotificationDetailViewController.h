//
//  NotificationDetailViewController.h
//  Notifications
//
//  Created by Ethan Lowman on 10/14/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Notification.h"

@interface NotificationDetailViewController : UIViewController

@property (strong, nonatomic) Notification *notification;
@property (strong, nonatomic) IBOutlet UILabel *messageLabel;
@property (strong, nonatomic) IBOutlet UILabel *sentDateLabel;
@property (strong, nonatomic) IBOutlet UITextView *longMessageTextView;

@end
