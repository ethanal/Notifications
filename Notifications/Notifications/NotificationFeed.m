//
//  NotificationFeed.m
//  Notifications
//
//  Created by Ethan Lowman on 8/25/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "NotificationFeed.h"

@implementation NotificationFeed

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id": @"id",
             @"name": @"name",
             @"hasUnread": @"has_unread"
             };
}

@end
