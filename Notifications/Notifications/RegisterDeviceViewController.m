//
//  RegisterDeviceViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 7/8/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "RegisterDeviceViewController.h"
#import "MTBBarcodeScanner.h"
#import <SSKeyChain.h>

@interface RegisterDeviceViewController ()

@property (nonatomic, strong) UIView *cameraView;
@property (nonatomic, strong) UIView *feedbackView;
@property (nonatomic, strong) MTBBarcodeScanner *scanner;
@property (nonatomic, strong) UIAlertView *invalidQRAlert;
@property (assign) BOOL foundQRCode;
@property (nonatomic, strong) UILabel *apiRootLabel;
@property (nonatomic, strong) UILabel *apiKeyLabel;
@property (nonatomic, strong) UIButton *registerDeviceButton;

@end

@implementation RegisterDeviceViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.title = @"Register Device";
    
    [self setupViews];
    [self setupScanner];
}

- (void)setupViews {
    self.cameraView = [UIView new];
    self.cameraView.backgroundColor = [UIColor blackColor];
    self.cameraView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.cameraView];

    
    self.feedbackView = [UIView new];
    self.feedbackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.view addSubview:self.feedbackView];
    
    
    NSDictionary *views = @{
        @"cameraView": self.cameraView,
        @"feedbackView": self.feedbackView
    };
    NSDictionary *metrics = @{@"margin": @20};
    
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"V:|-margin-[cameraView]-margin-[feedbackView]-margin-|"
                               options:0
                               metrics:metrics
                               views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-margin-[cameraView]-margin-|"
                               options:0
                               metrics:metrics
                               views:views]];
    
    [self.view addConstraints:[NSLayoutConstraint
                               constraintsWithVisualFormat:@"H:|-margin-[feedbackView]-margin-|"
                               options:0
                               metrics:metrics
                               views:views]];
    
    // Make cameraView square
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:self.cameraView
                                                          attribute:NSLayoutAttributeHeight
                                                          relatedBy:NSLayoutRelationEqual
                                                             toItem:self.cameraView
                                                          attribute:NSLayoutAttributeWidth
                                                         multiplier:1
                                                           constant:0]];
    
    
    
    // Add and configure feedback view title
    UILabel *feedbackViewTitleLabel = [UILabel new];
    feedbackViewTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    feedbackViewTitleLabel.text = @"API Credentials";
    feedbackViewTitleLabel.textAlignment = NSTextAlignmentCenter;
    UIFontDescriptor *titleFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleHeadline];
    titleFontDescriptor = [titleFontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    feedbackViewTitleLabel.font = [UIFont fontWithDescriptor:titleFontDescriptor size:0];
    [self.feedbackView addSubview:feedbackViewTitleLabel];
    
    
    // Add and configure subtitle labels
    UIFontDescriptor *subtitleFontDescriptor = [UIFontDescriptor preferredFontDescriptorWithTextStyle:UIFontTextStyleSubheadline];
    subtitleFontDescriptor = [subtitleFontDescriptor fontDescriptorWithSymbolicTraits:UIFontDescriptorTraitBold];
    UIFont *subitleFont = [UIFont fontWithDescriptor:subtitleFontDescriptor size:0];
    
    UILabel *apiRootTitleLabel = [UILabel new];
    apiRootTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    apiRootTitleLabel.text = @"API Root";
    apiRootTitleLabel.font = subitleFont;
    [self.feedbackView addSubview:apiRootTitleLabel];
    
    UILabel *apiKeyTitleLabel = [UILabel new];
    apiKeyTitleLabel.translatesAutoresizingMaskIntoConstraints = NO;
    apiKeyTitleLabel.text = @"API Key";
    apiKeyTitleLabel.font = subitleFont;
    [self.feedbackView addSubview:apiKeyTitleLabel];
    
    
    // Add and configure API credential labels
    UIFont *monoFont = [UIFont fontWithName:@"Menlo-Regular" size:10];
    
    self.apiRootLabel = [UILabel new];
    self.apiRootLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.apiRootLabel.text = @" ";
    self.apiRootLabel.font = monoFont;
    [self.feedbackView addSubview:self.apiRootLabel];
    
    self.apiKeyLabel = [UILabel new];
    self.apiKeyLabel.translatesAutoresizingMaskIntoConstraints = NO;
    self.apiKeyLabel.text = @" ";
    self.apiKeyLabel.font = monoFont;
    [self.feedbackView addSubview:self.apiKeyLabel];
    
    
    // Add submit button
    self.registerDeviceButton = [UIButton buttonWithType:UIButtonTypeSystem];
    self.registerDeviceButton.translatesAutoresizingMaskIntoConstraints = NO;
    [self.registerDeviceButton setTitle:@"Add Device" forState:UIControlStateNormal];
    self.registerDeviceButton.enabled = NO;
    [self.registerDeviceButton addTarget:self action:@selector(registerDevice:) forControlEvents:UIControlEventTouchUpInside];
    [self.feedbackView addSubview:self.registerDeviceButton];
    
    
    NSDictionary *feedbackViews = @{
        @"title": feedbackViewTitleLabel,
        @"apiRootTitle": apiRootTitleLabel,
        @"apiKeyTitle": apiKeyTitleLabel,
        @"apiRoot": self.apiRootLabel,
        @"apiKey": self.apiKeyLabel,
        @"registerDevice": self.registerDeviceButton
    };
    
    [self.feedbackView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:|[title]-(10)-[apiRootTitle]-(5)-[apiRoot]-(10)-[apiKeyTitle]-(5)-[apiKey]"
                                       options:0
                                       metrics:nil
                                       views:feedbackViews]];
    
    [self.feedbackView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"V:[registerDevice]-(10)-|"
                                       options:0
                                       metrics:nil
                                       views:feedbackViews]];

    [self.feedbackView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|[title]|"
                                       options:0
                                       metrics:nil
                                       views:feedbackViews]];
    
    [self.feedbackView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|[apiRootTitle]|"
                                       options:0
                                       metrics:nil
                                       views:feedbackViews]];
    [self.feedbackView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|[apiKeyTitle]|"
                                       options:0
                                       metrics:nil
                                       views:feedbackViews]];
    [self.feedbackView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|[apiRoot]|"
                                       options:0
                                       metrics:nil
                                       views:feedbackViews]];
    [self.feedbackView addConstraints:[NSLayoutConstraint
                                       constraintsWithVisualFormat:@"H:|[apiKey]|"
                                       options:0
                                       metrics:nil
                                       views:feedbackViews]];
    [self.feedbackView addConstraint:[NSLayoutConstraint constraintWithItem:self.registerDeviceButton
                                                                  attribute:NSLayoutAttributeCenterX
                                                                  relatedBy:NSLayoutRelationEqual
                                                                     toItem:self.feedbackView
                                                                  attribute:NSLayoutAttributeCenterX
                                                                 multiplier:1 constant:0]];
    
    
}


- (void)setupScanner {
    self.scanner = [[MTBBarcodeScanner alloc] initWithMetadataObjectTypes:@[AVMetadataObjectTypeQRCode] previewView:self.cameraView];
    self.foundQRCode = NO;
    
    [self.scanner startScanningWithResultBlock:^(NSArray *codes) {
        AVMetadataMachineReadableCodeObject *code = [codes firstObject];
        if (code.stringValue && !self.foundQRCode) {
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:code.stringValue options:0];
            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            NSArray *stringParts = [decodedString componentsSeparatedByString:@" "];
            NSString *apiRoot = [stringParts firstObject];
            NSString *apiKey = [stringParts lastObject];
            
            NSLog(@"%@ %@", apiRoot, apiKey);
            
            self.foundQRCode = YES;
            
            // Pause the camera view on a still frame of the QR code
            ((AVCaptureVideoPreviewLayer*)[self.cameraView.layer.sublayers firstObject]).connection.enabled = NO;
            
            if (([NSURL URLWithString:apiRoot] != nil) && [apiKey length] > 0) {
                self.apiRootLabel.text = apiRoot;
                self.apiKeyLabel.text = apiKey;
                self.registerDeviceButton.enabled = YES;
            
                [SSKeychain setPassword:apiKey forService:[[NSBundle mainBundle] bundleIdentifier] account:@"API"];
                [[NSUserDefaults standardUserDefaults] setObject:apiRoot forKey:@"APIRoot"];
            } else {
                self.invalidQRAlert = [[UIAlertView alloc] initWithTitle:@"Invalid QR Code"
                                                                 message:nil
                                                                delegate:self
                                                       cancelButtonTitle:@"Try Again"
                                                       otherButtonTitles:nil];
                [self.invalidQRAlert show];
            }
            
            
            
        }
    }];
}

- (void)alertView:(UIAlertView *)alertView didDismissWithButtonIndex:(NSInteger)buttonIndex {
    if (alertView == self.invalidQRAlert) {
        self.foundQRCode = NO;
        // Unpause the camera view
        ((AVCaptureVideoPreviewLayer*)[self.cameraView.layer.sublayers firstObject]).connection.enabled = YES;
    }
}

- (void)registerDevice:(id)sender {
    NSLog(@"Added device");
    [self dismissViewController:nil];
}


- (BOOL)registerDeviceToAPIRoot:(NSString*) apiRoot withAPIKey:(NSString*) apiKey {
    return YES;
}


- (void)dismissViewController:(id)sender {
    [self.scanner stopScanning];
    [self.navigationController popViewControllerAnimated:YES];
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
