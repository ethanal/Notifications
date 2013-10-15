//
//  Notification.m
//  Notifications
//
//  Created by Ethan Lowman on 10/14/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import "Notification.h"

@implementation Notification

- (id)initWithNotificationID:(NSInteger)notificationID feedID:(NSInteger)feedID message:(NSString*)message longMessage:(NSString*)longMessage sentDate:(NSDate*)sentDate read:(BOOL)read
{
    self = [super init];
    if (self) {
        self.notificationID = notificationID;
        self.feedID = feedID;
        self.message = message;
        self.longMessage = longMessage;
        self.sentDate = sentDate;
        self.read = read;
    }
    return self;
}

@end
