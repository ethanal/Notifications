//
//  NotificationDetailViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 10/14/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import "NotificationDetailViewController.h"
#import "NotificationsAPIClient.h"
@interface NotificationDetailViewController ()

@end

@implementation NotificationDetailViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    self.messageLabel.text = self.notification.message;
    
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"'Sent' dd MMM, yyyy 'at' h:mm:ss a"];
    self.sentDateLabel.text = [dateFormatter stringFromDate:self.notification.sentDate];
    
    self.longMessageTextView.text = self.notification.longMessage;
    
    self.longMessageTextView.textContainerInset = UIEdgeInsetsMake(0.0f, 20.0f, 0.0f, 20.0f);
    self.longMessageTextView.contentInset = UIEdgeInsetsMake(0.0f, -3.0f, 0.0f, 0.0f);
    
    [[NotificationsAPIClient sharedClient] markNotificationRead:self.notification];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
