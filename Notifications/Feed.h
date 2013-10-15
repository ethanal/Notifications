//
//  Feed.h
//  Notifications
//
//  Created by Ethan Lowman on 10/13/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Feed : NSObject

- (id)initWithFeedID:(NSInteger)feedID name:(NSString *)name hasUnread:(BOOL)unread;

@property (nonatomic, assign) NSInteger feedID;
@property (nonatomic, strong) NSString *name;
@property (nonatomic, assign) BOOL hasUnread;

@end
