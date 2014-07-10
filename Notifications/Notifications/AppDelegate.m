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

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    UITableViewController *tableViewController = [[FeedListViewController alloc] init];
    UINavigationController *tableViewNavigationController = [[UINavigationController alloc] initWithRootViewController:tableViewController];
    self.window.rootViewController = tableViewNavigationController;
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
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
}

@end
