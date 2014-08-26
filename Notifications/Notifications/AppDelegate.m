//
//  AppDelegate.m
//  Notifications
//
//  Created by Ethan Lowman on 7/8/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "AppDelegate.h"
#import "FeedListViewController.h"
#import <TSMessage.h>
#import "NSData+HexString.h"
#import "APIClient.h"
#import "NotificationListViewController.h"
#import "NotificationDetailViewController.h"

@interface AppDelegate ()

@property (nonatomic, assign) NSInteger apnFeedID;
@property (nonatomic, assign) NSInteger apnNotificationID;

@end


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UITableViewController *feedlistVC = [[FeedListViewController alloc] init];
    UINavigationController *feedlistNavVC = [[UINavigationController alloc] initWithRootViewController:feedlistVC];
    self.window.rootViewController = feedlistNavVC;
    [self.window makeKeyAndVisible];

    
    // Set up navigation bar appearance
    [[UINavigationBar appearance] setTitleTextAttributes:@{
        NSForegroundColorAttributeName: [UIColor whiteColor],
    }];

    UIColor *navColor = [UIColor colorWithRed:57.0/255.0 green:72.0/255.0 blue:95.0/255.0 alpha:1.0];
    [[UINavigationBar appearance] setBarTintColor:navColor];
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setTranslucent:NO];
    [[UINavigationBar appearance] setBarStyle:UIBarStyleBlack];
    
    
    // Set up TSMessage
    [TSMessage setDefaultViewController: self.window.rootViewController];
 
    
    
    NSUInteger notificationTypes = (UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge);
    
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0) {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:notificationTypes categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    } else {
        #pragma clang diagnostic push
        #pragma clang diagnostic ignored "-Wdeprecated-declarations"
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
        #pragma clang diagnostic pop
    }
    
    NSDictionary *apnPayload = launchOptions[UIApplicationLaunchOptionsRemoteNotificationKey];
    
    if(apnPayload) {
        NSInteger feedID = [apnPayload[@"aps"][@"feed"] intValue];
        NSInteger notificationID = [apnPayload[@"aps"][@"notification"] intValue];
        [self jumpToNotificationID:(NSInteger)notificationID inFeedID:(NSInteger)feedID];
    }
    
    return YES;
}

- (void)application:(UIApplication*)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData*)deviceToken {
    [[[APIClient sharedClient] class] setDeviceToken:[deviceToken hexadecimalString]];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error {
    NSLog(@"Failed to get token, error: %@", error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSDictionary *apnPayload = userInfo[@"aps"];
    self.apnFeedID = [apnPayload[@"feed"] intValue];
    self.apnNotificationID = [apnPayload[@"notification"] intValue];
    NSLog(@"%d", application.applicationState);
    if (application.applicationState == UIApplicationStateActive) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:apnPayload[@"feed_name"]
                                                        message:apnPayload[@"alert"]
                                                       delegate:self
                                              cancelButtonTitle:@"Cancel"
                                              otherButtonTitles:@"Show", nil];
        [alert show];
    } else {
        [self jumpToNotificationID:(NSInteger)self.apnNotificationID inFeedID:(NSInteger)self.apnFeedID];
    }
}

- (void)jumpToNotificationID:(NSInteger)notificationID inFeedID:(NSInteger)feedID {
    NotificationListViewController *notifListVC = [NotificationListViewController new];
    notifListVC.feedID = feedID;
    NotificationDetailViewController *notifDetailVC = [NotificationDetailViewController new];
    [[APIClient sharedClient] fetchNotificationWithID:notificationID withCallback:^(Notification *notification) {
        notifDetailVC.notification = notification;
        UINavigationController *rootVC = (UINavigationController *)self.window.rootViewController;
        
        if (rootVC.presentedViewController) {
            [rootVC dismissViewControllerAnimated:NO completion:^{
                [rootVC popToRootViewControllerAnimated:NO];
                [rootVC pushViewController:notifListVC animated:NO];
                [rootVC pushViewController:notifDetailVC animated:YES];
            }];
        } else {
            [rootVC popToRootViewControllerAnimated:NO];
            [rootVC pushViewController:notifListVC animated:NO];
            [rootVC pushViewController:notifDetailVC animated:YES];
        }
        
        
    }];
    
}

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
    if (buttonIndex == 1) {
        [self jumpToNotificationID:(NSInteger)self.apnNotificationID inFeedID:(NSInteger)self.apnFeedID];
    }
}

@end
