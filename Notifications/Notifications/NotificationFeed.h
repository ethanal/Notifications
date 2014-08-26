//
//  NotificationFeed.h
//  Notifications
//
//  Created by Ethan Lowman on 8/25/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import <Mantle.h>

@interface NotificationFeed : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL hasUnread;

@end
