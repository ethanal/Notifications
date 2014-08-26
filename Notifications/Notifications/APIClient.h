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
typedef void(^FetchedNotification)(Notification *notification);
typedef void(^FetchedDictionary)(NSDictionary *dictionary);

@interface APIClient : AFHTTPRequestOperationManager

+ (instancetype)sharedClient;
+ (NSString *)deviceToken;
+ (void)setDeviceToken: (NSString *)token;

- (void)registerDevice:(NSString*)deviceName withCallback:(void (^)())callback;
- (void)fetchDeviceInfo: (FetchedDictionary)callback;
- (void)fetchFeedsWithCallback:(FetchedFeeds)callback;
- (void)fetchUnsubscribedFeedsWithCallback: (FetchedFeeds)callback;
- (void)fetchNotificationsForFeedWithID:(NSInteger)feedID withCallback:(FetchedNotifications)callback;
- (void)fetchNotificationWithID:(NSInteger)feedID withCallback:(FetchedNotification)callback;
- (void)markNotificationRead: (Notification*)notification;
- (void)markFeedWithIDRead: (NSInteger)feedID;
- (BOOL)subscribeToFeedWithID:(NSInteger)feedID;
- (void)unsubscribeFromFeedWithID:(NSInteger)feedID;

@end
