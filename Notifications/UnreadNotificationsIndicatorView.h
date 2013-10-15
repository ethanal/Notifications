//
//  NotificationCountView.h
//  Notifications
//
//  Created by Ethan Lowman on 10/12/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnreadNotificationsIndicatorView : UIView

- (id)initWithFrame:(CGRect)frame status:(BOOL)status;

@property (nonatomic, assign) BOOL active;

@end