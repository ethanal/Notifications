//
//  Feed.m
//  Notifications
//
//  Created by Ethan Lowman on 10/13/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import "Feed.h"

@implementation Feed

- (id)initWithFeedID:(NSInteger)feedID name:(NSString *)name hasUnread:(BOOL)unread
{
    self = [super init];
    if (self) {
        self.feedID = feedID;
        self.name = name;
        self.hasUnread = unread;
    }
    return self;
}

@end
