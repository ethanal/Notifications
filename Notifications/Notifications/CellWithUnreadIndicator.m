//
//  CellWithUnreadIndicator.m
//  Notifications
//
//  Created by Ethan Lowman on 8/26/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "CellWithUnreadIndicator.h"
#import "UnreadIndicatorView.h"

@implementation CellWithUnreadIndicator

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        int diameter = 8;
        CGRect frame = CGRectMake(3, 17, diameter, diameter);
        self.unreadIndicator = [[UnreadIndicatorView alloc] initWithFrame:frame];
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    return self;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self.contentView addSubview:self.unreadIndicator];
}
@end
