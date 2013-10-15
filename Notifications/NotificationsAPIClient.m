//
//  NotificationsAPIClient.m
//  Notifications
//
//  Created by Ethan Lowman on 10/13/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import "NotificationsAPIClient.h"
#import "Config.h"

@implementation NotificationsAPIClient


+ (instancetype)sharedClient
{
    static NotificationsAPIClient *__instance;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [[NotificationsAPIClient alloc] initWithBaseURL:[NSURL URLWithString:API_ENTRY_POINT]];
    });
    return __instance;
}

-(id) initWithBaseURL:(NSURL *)url
{
    self = [super initWithBaseURL:url];
    if (self)
    {
        [self.requestSerializer setValue:API_TOKEN forHTTPHeaderField:@"Authorization"];
    }
    return self;
}

+ (NSString *) deviceToken
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
}

+ (void) setDeviceToken:(NSString *)token
{
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
}

-(void)fetchFeedWithCallback: (FetchedFeeds)callback
{
    
    [self GET:@"feeds/list" parameters:@{@"device_token": [NotificationsAPIClient deviceToken]}
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSMutableArray *feeds = [[NSMutableArray alloc] initWithCapacity:10];
          
          for (id feed in responseObject) {
              [feeds addObject:[[Feed alloc]
                initWithFeedID:[[feed objectForKey:@"id"] integerValue]
                          name:[feed objectForKey:@"name"]
                     hasUnread:[[feed objectForKey:@"has_unread"] boolValue]]];
          }

          callback(feeds);
        
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          callback([NSMutableArray new]);
          NSLog(@"ERROR: %@", error);
      }];
}


-(void)fetchNotificationsForFeed:(Feed *)feed withCallback:(FetchedNotifications)callback
{
    [self GET:@"notifications/list" parameters:@{@"feed": [NSNumber numberWithInteger:feed.feedID]}
      success:^(NSURLSessionDataTask *task, id responseObject) {
          NSMutableArray *notifications = [[NSMutableArray alloc] initWithCapacity:10];
          
          NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
          [dateFormat setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"];
          
          for (id notification in responseObject) {
              NSDate *date = [dateFormat dateFromString:[notification objectForKey:@"sent_date"]];
              [notifications addObject:[[Notification alloc] initWithNotificationID:[[notification objectForKey:@"id"] integerValue]
                                                                             feedID:feed.feedID
                                                                            message:[notification objectForKey:@"message"]
                                                                        longMessage:[notification objectForKey:@"long_message"]
                                                                           sentDate:date
                                                                               read:[[notification objectForKey:@"viewed"] boolValue]]];
          }
          
          callback(notifications);
      }
      failure:^(NSURLSessionDataTask *task, NSError *error) {
          callback([NSMutableArray new]);
          NSLog(@"ERROR: %@", error);
    }];
}

-(void)markNotificationRead: (Notification *)notification
{
    [self POST:[NSString stringWithFormat:@"notifications/%d/viewed", notification.notificationID] parameters:nil constructingBodyWithBlock:nil success:nil
       failure:^(NSURLSessionDataTask *task, NSError *error) {
           NSLog(@"ERROR: %@", error);
       }];
}


-(BOOL)subscribeToFeedWithID:(NSInteger)feedID verifiedByPIN:(NSInteger)pin
{
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@feeds/%d/subscribe", API_ENTRY_POINT, feedID]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:API_TOKEN forHTTPHeaderField:@"Authorization"];
    
    NSString *postString = [NSString stringWithFormat:@"device_token=%@&pin=%d", [NotificationsAPIClient deviceToken], pin];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%u", [data length]] forHTTPHeaderField:@"Content-Length"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return [response statusCode] == 201;
    
}


-(void)unsubscribeFromFeed:(Feed *)feed
{
//    [self POST:[NSString stringWithFormat:@"feeds/%d/unsubscribe", feed.feedID] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
//        [formData appendPartWithFormData:[[NotificationsAPIClient deviceToken] dataUsingEncoding:NSUTF8StringEncoding] name:@"device_token"];
//    } success:nil
//    failure:^(NSURLSessionDataTask *task, NSError *error) {
//        NSLog(@"ERROR: %@", error);
//    }];
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@feeds/%d/unsubscribe", API_ENTRY_POINT, feed.feedID]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:API_TOKEN forHTTPHeaderField:@"Authorization"];
    
    NSString *postString = [NSString stringWithFormat:@"device_token=%@", [NotificationsAPIClient deviceToken]];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%u", [data length]] forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}


@end
