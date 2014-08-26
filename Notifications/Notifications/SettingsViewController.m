//
//  SettingsViewController.m
//  Notifications
//
//  Created by Ethan Lowman on 7/9/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "SettingsViewController.h"
#import "RegisterDeviceViewController.h"
#import "APIClient.h"
#import <TSMessage.h>
#import <SSKeychain.h>

@interface SettingsViewController ()

@property (nonatomic, strong) NSArray *tableSections;
@property (nonatomic, strong) NSString *username;
@property (nonatomic, strong) NSString *deviceName;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.title = @"Settings";
    UIBarButtonItem *doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    self.navigationItem.rightBarButtonItem = doneButton;
    
    self.username = @"";
    self.deviceName = @"";
    
    [[APIClient sharedClient] fetchDeviceInfo:^(NSDictionary *dictionary) {
        self.username = [dictionary objectForKey:@"username"];
        self.deviceName = [dictionary objectForKey:@"device_name"];
        [self loadTableSectionsData];
        [self.tableView reloadData];
    }];
    
    
    [self loadTableSectionsData];
}

- (void) viewDidAppear:(BOOL)animated {
    [self loadTableSectionsData];
    [self.tableView reloadData];
}

- (void)loadTableSectionsData {
    self.tableSections = @[@{
                               @"title": @"Account Settings",
                               @"cells": @[
                                       @{
                                           @"title": @"Username",
                                           @"detail": self.username
                                           },
                                       @{
                                           @"title": @"Device Name",
                                           @"detail": self.deviceName
                                           }
                                       ]
                               },
                           @{
                               @"title": @"API Root",
                               @"cells": @[
                                       @{
                                           @"content": [[NSUserDefaults standardUserDefaults] objectForKey:@"APIRoot"],
                                           @"targetSelectorName": @"copyCellContent:"
                                           }
                                       ]
                               },
                           @{
                               @"title": @"User Key",
                               @"cells": @[
                                       @{
                                           @"content": [SSKeychain passwordForService:[[NSBundle mainBundle] bundleIdentifier] account:@"API"],
                                           @"targetSelectorName": @"copyCellContent:"
                                           }
                                       ]
                               },
                           @{
                               @"cells": @[
                                       @{
                                           @"content": @"Register Device",
                                           @"targetSelectorName": @"registerDeviceCellSelected:"
                                           }
                                       ]
                               }
                           ];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self.tableSections[section][@"cells"] count];
}


- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return [self.tableSections count];
}

- (NSString*)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    return self.tableSections[section][@"title"];
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSDictionary *cellInfo = self.tableSections[indexPath.section][@"cells"][indexPath.row];
    
    if (cellInfo[@"targetSelectorName"]) {
        SEL selector = NSSelectorFromString(cellInfo[@"targetSelectorName"]);
        IMP imp = [self methodForSelector:selector];
        void (*func)(id, SEL, id) = (void *)imp;
        func(self, selector, [self.tableView cellForRowAtIndexPath:indexPath]);
    }
    
    [self.tableView deselectRowAtIndexPath:indexPath animated:YES];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *cellIdentifier = @"AccountDetailsCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

    NSDictionary *cellInfo = self.tableSections[indexPath.section][@"cells"][indexPath.row];

    if (cell == nil) {
        UITableViewCellStyle style = UITableViewCellStyleValue1;
        if (cellInfo[@"content"])
            style = UITableViewCellStyleDefault;
            
        cell = [[UITableViewCell alloc] initWithStyle:style reuseIdentifier:cellIdentifier];
    }
    
    
    if(cellInfo[@"content"]) {
        NSInteger numberOfLines = 1;
        if (cellInfo[@"numberOfLines"]) {
            numberOfLines = (NSInteger)cellInfo[@"numberOfLines"];
            cell.textLabel.lineBreakMode = NSLineBreakByCharWrapping;
            cell.textLabel.numberOfLines = numberOfLines;
        }
        cell.textLabel.text = cellInfo[@"content"];
    } else {
        cell.textLabel.text = cellInfo[@"title"];
        cell.detailTextLabel.text = cellInfo[@"detail"];
    }
    
    if(!cellInfo[@"targetSelectorName"]) {
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    return cell;

}


- (void)doneButtonPressed:(id)sender {
    [self dismissViewControllerAnimated:YES completion:nil];
}


- (void)registerDeviceCellSelected:(id)sender {
    RegisterDeviceViewController *registerVC = [[RegisterDeviceViewController alloc] init];
    [self.navigationController pushViewController:registerVC animated:YES];
}


- (void)copyCellContent:(id)sender {
    [[UIPasteboard generalPasteboard] setString:((UITableViewCell*)sender).textLabel.text];
    [TSMessage showNotificationInViewController:self.navigationController
                                           title:@"Copied to clipboard"
                                       subtitle:@""
                                           type:TSMessageNotificationTypeSuccess];
}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
