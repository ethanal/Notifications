//
//  SubscribeModalViewController.h
//  Notifications
//
//  Created by Ethan Lowman on 10/12/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SubscribeModalViewController : UIViewController <UITextFieldDelegate>

@property (strong, nonatomic) IBOutlet UITextField *feedIDField;
@property (strong, nonatomic) IBOutlet UITextField *pinField;


- (IBAction)submit:(id)sender;

@end
