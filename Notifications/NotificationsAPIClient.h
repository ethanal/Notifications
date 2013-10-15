//
//  NotificationsAPIClient.h
//  Notifications
//
//  Created by Ethan Lowman on 10/13/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import <AFNetworking.h>
#import "Feed.h"
#import "Notification.h"

typedef void(^FetchedFeeds)(NSMutableArray *feeds);
typedef void(^FetchedNotifications)(NSMutableArray *notifications);

@interface NotificationsAPIClient : AFHTTPSessionManager

+(instancetype)sharedClient;
+(NSString *)deviceToken;
+(void)setDeviceToken: (NSString *)token;


-(void)fetchFeedWithCallback:(FetchedFeeds)callback;
-(void)fetchNotificationsForFeed:(Feed*)feed withCallback:(FetchedNotifications)callback;
-(void)markNotificationRead: (Notification*)notification;
-(BOOL)subscribeToFeedWithID:(NSInteger)feedID verifiedByPIN:(NSInteger)pin;
-(void)unsubscribeFromFeed:(Feed*)feed;

@end
