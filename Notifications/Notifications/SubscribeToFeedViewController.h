//
//  SubscribeToFeedViewController.h
//  Notifications
//
//  Created by Ethan Lowman on 8/26/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscribeToFeedViewController : UIViewController <UIPickerViewDelegate, UIPickerViewDataSource>

@property (nonatomic, strong) NSMutableArray *feeds;

@end
