//
//  APIClient.h
//  Notifications
//
//  Created by Ethan Lowman on 8/25/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AFNetworking.h>
#import "NotificationFeed.h"
#import "Notification.h"

typedef void(^FetchedFeeds)(NSMutableArray *feeds);
typedef void(^FetchedNotifications)(NSMutableArray *notifications);

@interface APIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;
+ (NSString *)deviceToken;
+ (void)setDeviceToken: (NSString *)token;


- (void)fetchFeedsWithCallback:(FetchedFeeds)callback;
- (void)fetchUnsubscribedFeedsWithCallback: (FetchedFeeds)callback;
- (void)fetchNotificationsForFeedWithID:(NSInteger)feedID withCallback:(FetchedNotifications)callback;
- (void)markNotificationRead: (Notification*)notification;
- (BOOL)subscribeToFeedWithID:(NSInteger)feedID;
- (void)unsubscribeFromFeedWithID:(NSInteger)feedID;

@end
