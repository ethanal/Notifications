//
//  NotificationDetailViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 8/26/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "NotificationDetailViewController.h"
#import "APIClient.h"

@interface NotificationDetailViewController ()

@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *sentDateLabel;
@property (nonatomic, strong) UITextView *messageTextView;

@end

@implementation NotificationDetailViewController

- (void)viewDidLoad {
    self.title = @"Notification";
    self.view.backgroundColor = [UIColor whiteColor];
    
    [[APIClient sharedClient] markNotificationRead:self.notification];
    
    self.titleLabel = [UILabel new];
    self.titleLabel.font = [self.titleLabel.font fontWithSize:20.0f];
    self.titleLabel.text = self.notification.title;
    self.titleLabel.numberOfLines = 0;
    [self.titleLabel sizeToFit];
    self.titleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.titleLabel];
    
    self.sentDateLabel = [UILabel new];
    self.sentDateLabel.font = [self.sentDateLabel.font fontWithSize:17.0f];
    self.sentDateLabel.textColor = [UIColor lightGrayColor];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"'Sent' dd MMM, yyyy 'at' h:mm:ss a"];
    self.sentDateLabel.text = [dateFormatter stringFromDate:self.notification.sentDate];
    self.sentDateLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.sentDateLabel];
    
    self.messageTextView = [UITextView new];
    
    NSString *html = [self.notification.message stringByReplacingOccurrencesOfString:@"\n" withString:@"<br/>"];
    NSString *prefix = @"<meta charset=\"UTF-8\"><style>* {font-size: 15px; font-family: 'HelveticaNeue'}</style>";
    html = [prefix stringByAppendingString:html];
    NSData *htmlData = [html dataUsingEncoding:NSUTF8StringEncoding];
    NSDictionary *attributedStringOptions = @{NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType,
                                              NSCharacterEncodingDocumentAttribute: @(NSUTF8StringEncoding)
                                              };
    NSAttributedString *messageContent = [[NSAttributedString alloc] initWithData:htmlData options:attributedStringOptions documentAttributes:nil error:nil];
    self.messageTextView.attributedText = messageContent;
    
    self.messageTextView.textContainer.lineFragmentPadding = 0;
    self.messageTextView.textContainerInset = UIEdgeInsetsZero;
    self.messageTextView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.messageTextView];
    
    NSDictionary *views = @{@"titleLabel": self.titleLabel,
                            @"sentDateLabel": self.sentDateLabel,
                            @"messageTextView": self.messageTextView,
                            };
    
    NSDictionary *metrics = @{@"margin": @20,
                              @"innerMargin": @10
                              };
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-(margin)-[titleLabel]-(innerMargin)-[sentDateLabel]-(innerMargin)-[messageTextView]|"
                               options:0
                               metrics:metrics
                               views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(margin)-[titleLabel]-(margin)-|"
                               options:0
                               metrics:metrics
                               views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(margin)-[sentDateLabel]-(margin)-|"
                               options:0
                               metrics:metrics
                               views:views]];
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-(margin)-[messageTextView]-(margin)-|"
                               options:0
                               metrics:metrics
                               views:views]];

}

@end
