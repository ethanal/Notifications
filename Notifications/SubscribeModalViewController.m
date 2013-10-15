//
//  SubscribeModalViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 10/12/13.
//  Copyright (c) 2013 Binary Seal. All rights reserved.
//

#import "SubscribeModalViewController.h"
#import "Config.h"
#import "NotificationsAPIClient.h"
#import "FeedListViewController.h"

@interface SubscribeModalViewController ()

@end

@implementation SubscribeModalViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (BOOL)textField:(UITextField *) textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    NSUInteger oldLength = [textField.text length];
    NSUInteger replacementLength = [string length];
    NSUInteger rangeLength = range.length;
    
    NSUInteger newLength = oldLength - rangeLength + replacementLength;
    
    BOOL returnKey = [string rangeOfString: @"\n"].location != NSNotFound;
    
    return newLength <= PIN_LENGTH || returnKey;
}

- (IBAction)submit:(id)sender {
    [self.view endEditing:YES];
    BOOL subscribed = [[NotificationsAPIClient sharedClient] subscribeToFeedWithID:[self.feedIDField.text integerValue] verifiedByPIN:[self.pinField.text integerValue]];

    if (subscribed)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"You have successfully been subscribed!"
                                                        message:nil
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [[NSNotificationCenter defaultCenter] postNotificationName:@"SubscribeModalDismissed"
                                                            object:nil
                                                          userInfo:nil];
        
        [self.presentingViewController dismissViewControllerAnimated:YES completion:nil];
    } else {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Subscription failed"
                                                        message:@"Check that the PIN is correct and you are connected to the internet."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
    }
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    NSInteger nextTag = textField.tag + 1;
    UIResponder *nextResponder = [textField.superview viewWithTag:nextTag];
    
    if (nextResponder) {
        [nextResponder becomeFirstResponder];
        return NO;
    } else {
        [textField resignFirstResponder];
        [self submit:nil];
        return YES;
    }
}

- (BOOL)disablesAutomaticKeyboardDismissal
{
    return NO;
}


@end
