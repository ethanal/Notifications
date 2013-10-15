//
//  Notification.h
//  Notifications
//
//  Created by Ethan Lowman on 10/14/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Notification : NSObject

- (id)initWithNotificationID: (NSInteger)notificationID feedID:(NSInteger)feedID message:(NSString*)message longMessage:(NSString*)longMessage sentDate:(NSDate*)sentDate read:(BOOL)read;

@property (nonatomic, assign) NSInteger notificationID;
@property (nonatomic, assign) NSInteger feedID;
@property (nonatomic, strong) NSString *message;
@property (nonatomic, strong) NSString *longMessage;
@property (nonatomic, strong) NSDate *sentDate;
@property (nonatomic, assign) BOOL read;

@end
