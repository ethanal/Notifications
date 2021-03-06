//
//  APIClient.m
//  Notifications
//
//  Created by Ethan Lowman on 8/25/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "APIClient.h"
#import <SSKeychain.h>
#import <Mantle.h>
#import "NotificationFeed.h"

@interface APIClient ()

@property (nonatomic, strong) NSURLSession *session;

@end

@implementation APIClient

static NSString *APIRoot;
static NSString *APIToken;
static APIClient *__instance;

+ (instancetype)sharedClient {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        __instance = [APIClient getInstance];;
    });
    
    return __instance;
}

- (id) initWithBaseURL:(NSURL *)url {
    self = [super initWithBaseURL:url];
    if (self) {
        [self.requestSerializer setValue:APIToken forHTTPHeaderField:@"Authorization"];
    }
    return self;
}

+ (APIClient *) getInstance {
    APIRoot = [[[NSUserDefaults standardUserDefaults] objectForKey:@"APIRoot"] stringByAppendingString:@"/"];
    if (APIRoot == nil) {
        APIRoot = @"http://localhost";
    }
    
    NSString *token = [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier] account:@"API"];
    if (token == nil) {
        token = @"NO_TOKEN";
    }
    APIToken = [@"Token " stringByAppendingString:token];
    
    return [[APIClient alloc] initWithBaseURL:[NSURL URLWithString:APIRoot]];
}

+ (void) updateInstance {
    __instance = [APIClient getInstance];
}

+ (NSString *) deviceToken {
    return [[NSUserDefaults standardUserDefaults] objectForKey:@"device_token"];
}

+ (void) setDeviceToken:(NSString *)token {
    [[NSUserDefaults standardUserDefaults] setObject:token forKey:@"device_token"];
}

- (void)registerDevice:(NSString*)deviceName withCallback:(void (^)())callback {
    if (![APIClient deviceToken]) return;
    
    [self POST:@"register_device" parameters:@{@"device_token": [APIClient deviceToken], @"name": deviceName} constructingBodyWithBlock:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        callback();
    } failure:^(AFHTTPRequestOperation *operation , NSError *error) {
        NSLog(@"ERROR: %@", error);
        NSLog(@"FOO: %@", operation.request);
    }];
}

- (void)fetchDeviceInfo: (FetchedDictionary)callback {
    if (![APIClient deviceToken]) return;
    
    [self GET:[@"device_info/" stringByAppendingString:[APIClient deviceToken]] parameters:@{}
      success:^(AFHTTPRequestOperation *operation , id responseObject) {
          callback(responseObject);
      }
      failure:^(AFHTTPRequestOperation *operation , NSError *error) {
          callback(@{});
          NSLog(@"ERROR: %@", error);
          NSLog(@"%@", operation.responseString);
      }];
}

- (void)fetchFeedsWithCallback: (FetchedFeeds)callback {
    if (![APIClient deviceToken]) return;
    
    [self GET:@"feeds/list" parameters:@{@"device_token": [APIClient deviceToken]}
      success:^(AFHTTPRequestOperation *operation , id responseObject) {
          NSMutableArray *feeds = [[NSMutableArray alloc] initWithCapacity:10];
          
          for (id feedDict in responseObject) {
              [feeds addObject:[MTLJSONAdapter modelOfClass:NotificationFeed.class fromJSONDictionary:feedDict error:nil]];
          }
          
          callback(feeds);
          
      }
      failure:^(AFHTTPRequestOperation *operation , NSError *error) {
          callback([NSMutableArray new]);
          NSLog(@"ERROR: %@", error);
          NSLog(@"%@", operation.responseString);
      }];
}

- (void)fetchUnsubscribedFeedsWithCallback: (FetchedFeeds)callback {
    if (![APIClient deviceToken]) return;
    
    [self GET:@"feeds/list_unsubscribed" parameters:@{@"device_token": [APIClient deviceToken]}
      success:^(AFHTTPRequestOperation *operation , id responseObject) {
          NSMutableArray *feeds = [[NSMutableArray alloc] initWithCapacity:10];
          
          for (id feedDict in responseObject) {
              [feeds addObject:[MTLJSONAdapter modelOfClass:NotificationFeed.class fromJSONDictionary:feedDict error:nil]];
          }
          
          callback(feeds);
          
      }
      failure:^(AFHTTPRequestOperation *operation , NSError *error) {
          callback([NSMutableArray new]);
          NSLog(@"ERROR: %@", error);
          NSLog(@"%@", operation.responseString);
      }];
}


- (void)fetchNotificationsForFeedWithID:(NSInteger)feedID withCallback:(FetchedNotifications)callback {
    [self GET:[NSString stringWithFormat:@"feeds/%ld/notifications/list", (long)feedID] parameters:@{}
      success:^(AFHTTPRequestOperation *operation , id responseObject) {
          NSMutableArray *notifications = [[NSMutableArray alloc] initWithCapacity:10];

          for (id notificationDict in responseObject) {
              [notifications addObject:[MTLJSONAdapter modelOfClass:Notification.class fromJSONDictionary:notificationDict error:nil]];
          }
          
          callback(notifications);
      }
      failure:^(AFHTTPRequestOperation *operation , NSError *error) {
          callback([NSMutableArray new]);
          NSLog(@"ERROR: %@", error);
      }];
}

- (void)fetchNotificationWithID:(NSInteger)feedID withCallback:(FetchedNotification)callback {
    [self GET:[NSString stringWithFormat:@"notifications/%ld", (long)feedID] parameters:@{}
      success:^(AFHTTPRequestOperation *operation , id responseObject) {
          Notification *notification = [MTLJSONAdapter modelOfClass:Notification.class fromJSONDictionary:responseObject error:nil];
          callback(notification);
      }
      failure:^(AFHTTPRequestOperation *operation , NSError *error) {
          NSLog(@"ERROR: %@", error);
      }];
}

- (void)markNotificationRead: (Notification *)notification {
    [self POST:[NSString stringWithFormat:@"notifications/%d/mark_viewed", [notification.id intValue]] parameters:nil constructingBodyWithBlock:nil success:nil
       failure:^(AFHTTPRequestOperation *operation , NSError *error) {
           NSLog(@"ERROR: %@", error);
       }];
}

- (void)markFeedWithIDRead: (NSInteger)feedID {
    [self POST:[NSString stringWithFormat:@"feeds/%ld/notifications/mark_viewed", (long)feedID] parameters:nil constructingBodyWithBlock:nil success:nil
       failure:^(AFHTTPRequestOperation *operation , NSError *error) {
           NSLog(@"ERROR: %@", error);
       }];
}


- (BOOL)subscribeToFeedWithID:(NSInteger)feedID {
    if (![APIClient deviceToken]) return false;
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@feeds/%ld/subscribe", APIRoot, (long)feedID]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:APIToken forHTTPHeaderField:@"Authorization"];
    
    NSString *postString = [NSString stringWithFormat:@"device_token=%@", [APIClient deviceToken]];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    
    NSHTTPURLResponse *response = nil;
    NSError *error = nil;
    [NSURLConnection sendSynchronousRequest:request returningResponse:&response error:&error];
    
    return [response statusCode] == 201;
}


- (void)unsubscribeFromFeedWithID:(NSInteger)feedID {
    //    [self POST:[NSString stringWithFormat:@"feeds/%d/unsubscribe", feed.feedID] parameters:nil constructingBodyWithBlock:^(id<AFMultipartFormData> formData) {
    //        [formData appendPartWithFormData:[[APIClient deviceToken] dataUsingEncoding:NSUTF8StringEncoding] name:@"device_token"];
    //    } success:nil
    //    failure:^(NSURLSessionDataTask *task, NSError *error) {
    //        NSLog(@"ERROR: %@", error);
    //    }];
    if (![APIClient deviceToken]) return;
    
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@feeds/%ld/unsubscribe", APIRoot, (long)feedID]]];
    [request setHTTPMethod:@"POST"];
    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"content-type"];
    [request setValue:APIToken forHTTPHeaderField:@"Authorization"];
    
    NSString *postString = [NSString stringWithFormat:@"device_token=%@", [APIClient deviceToken]];
    NSData *data = [postString dataUsingEncoding:NSUTF8StringEncoding];
    [request setHTTPBody:data];
    [request setValue:[NSString stringWithFormat:@"%lu", (unsigned long)[data length]] forHTTPHeaderField:@"Content-Length"];
    [NSURLConnection connectionWithRequest:request delegate:self];
    
}

@end
