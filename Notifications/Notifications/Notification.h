//
//  Notification.h
//  Notifications
//
//  Created by Ethan Lowman on 8/25/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import <Mantle.h>

@interface Notification : MTLModel <MTLJSONSerializing>

@property (nonatomic, strong) NSNumber *id;
@property (nonatomic, strong) NSDate *sentDate;
@property (nonatomic, assign) BOOL viewed;
@property (nonatomic, strong) NSNumber *feedID;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *message;

@end