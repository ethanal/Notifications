//
//  CellWithUnreadIndicator.h
//  Notifications
//
//  Created by Ethan Lowman on 8/26/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "UnreadIndicatorView.h"

@interface CellWithUnreadIndicator : UITableViewCell

@property (nonatomic, strong) UnreadIndicatorView *unreadIndicator;

@end
