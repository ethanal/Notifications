//
//  NotificationCountView.m
//  Notifications
//
//  Created by Ethan Lowman on 10/12/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import "UnreadNotificationsIndicatorView.h"

@implementation UnreadNotificationsIndicatorView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialize stuff here
    }
    return self;
}

- (id)initWithFrame:(CGRect)frame status:(BOOL)status
{
    self = [super initWithFrame:frame];
    if (self) {
        self.active = status;
    }
    return self;
}

// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if (self.active) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0.11 green:0.47 blue:0.97 alpha:1] CGColor]));
        CGContextFillPath(ctx);
    }
}

@end
