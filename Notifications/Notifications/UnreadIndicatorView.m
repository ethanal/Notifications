//
//  UnreadIndicatorView.m
//  Notifications
//
//  Created by Ethan Lowman on 7/8/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "UnreadIndicatorView.h"

@implementation UnreadIndicatorView

@synthesize status = _status;

- (instancetype)initWithFrame:(CGRect)frame status:(BOOL)status {
    self = [super initWithFrame:frame];
    if (self) {
        self.status = status;
        
        // Set transparent background
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0];
    }
    return self;
}

- (void)drawRect:(CGRect)rect
{
    if (self.status) {
        CGContextRef ctx = UIGraphicsGetCurrentContext();
        CGContextClearRect(ctx, rect);
        
        // Green background for debugging
//        CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0.00 green:1.00 blue:0.00 alpha:1] CGColor]));
//        CGContextFillRect(ctx, rect);
        
        CGContextAddEllipseInRect(ctx, rect);
        CGContextSetFillColor(ctx, CGColorGetComponents([[UIColor colorWithRed:0.11 green:0.47 blue:0.97 alpha:1] CGColor]));
        CGContextFillPath(ctx);
    }
}

- (void)setStatus:(BOOL)status {
    _status = status;
    [self setNeedsDisplay];
}

@end
