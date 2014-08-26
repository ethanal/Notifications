//
//  SubscribeToFeedViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 8/26/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "SubscribeToFeedViewController.h"
#import "NotificationFeed.h"
#import "APIClient.h"

@interface SubscribeToFeedViewController ()

@property (nonatomic, strong) UIPickerView *feedPicker;
@property (nonatomic, strong) UIButton *addButton;

@end

@implementation SubscribeToFeedViewController

- (void)viewDidLoad {
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Subscribe to Feed";
    UIBarButtonItem *cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    self.navigationItem.rightBarButtonItem = cancelButton;
    
    self.feedPicker = [UIPickerView new];
    self.feedPicker.delegate = self;
    self.feedPicker.dataSource = self;
    self.feedPicker.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.feedPicker];
    
    self.addButton = [UIButton buttonWithType:UIButtonTypeSystem];
    [self.addButton setTitle:@"Subscribe" forState:UIControlStateNormal];
    [self.addButton addTarget:self action:@selector(subscribe:) forControlEvents:UIControlEventTouchUpInside];
    self.addButton.enabled = NO;
    self.addButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.addButton];
    
    NSDictionary *views = @{
                            @"feedPicker": self.feedPicker,
                            @"addButton": self.addButton
                            };
    NSDictionary *metrics = @{@"margin": @20};
    
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-margin-[feedPicker]-margin-[addButton]"
                               options:0
                               metrics:metrics
                               views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-margin-[feedPicker]-margin-|"
                               options:0
                               metrics:metrics
                               views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|[addButton]|"
                               options:0
                               metrics:metrics
                               views:views]];

}

- (void)viewWillAppear:(BOOL)animated {
    [[APIClient sharedClient] fetchUnsubscribedFeedsWithCallback:^(NSMutableArray *feeds) {
        self.feeds = feeds;
        if ([self.feeds count] > 0) {
            self.addButton.enabled = YES;
        } else {
            self.feedPicker.userInteractionEnabled = NO;
        }
        [self.feedPicker reloadAllComponents];
    }];
}

- (void)cancelButtonPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    return [self.feeds count];
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    return ((NotificationFeed *)[self.feeds objectAtIndex:row]).name;
}

- (void)subscribe:(id)sender {
    NSInteger selectedRow = [self.feedPicker selectedRowInComponent:0];
    [[APIClient sharedClient] subscribeToFeedWithID:[((NotificationFeed *)[self.feeds objectAtIndex:selectedRow]).id intValue]];
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


@end
