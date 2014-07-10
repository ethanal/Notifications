//
//  UnreadIndicatorView.h
//  Notifications
//
//  Created by Ethan Lowman on 7/8/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UnreadIndicatorView : UIView

@property (nonatomic, assign) BOOL status;

- (instancetype)initWithFrame:(CGRect)frame status:(BOOL)status;

@end
