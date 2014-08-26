//
//  Notification.m
//  Notifications
//
//  Created by Ethan Lowman on 8/25/14.
//  Copyright (c) 2014 Ethan Lowman. All rights reserved.
//

#import "Notification.h"

@implementation Notification

+ (NSDictionary *)JSONKeyPathsByPropertyKey {
    return @{
             @"id": @"id",
             @"sentDate": @"sent_date",
             @"viewed": @"viewed",
             @"feedID": @"feed",
             @"title": @"title",
             @"message": @"message",
             };
}

+ (NSValueTransformer *)dateJSONTransformer {
    return [MTLValueTransformer transformerWithBlock:^(NSString *str) {
        NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
        if ([str rangeOfString:@"."].location == NSNotFound) {
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
        } else {
            [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ss.SSSZ"];
        }
        NSLocale *posix = [[NSLocale alloc] initWithLocaleIdentifier:@"en_US_POSIX"];
        [formatter setLocale:posix];
        
        return [formatter dateFromString:str];
    }];
}

+ (NSValueTransformer *)sentDateJSONTransformer {
    return [self dateJSONTransformer];
}

@end
