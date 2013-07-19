//
//  HYDefaultCommandHandlerPack.m
//  HYWebViewControlller
//
//  Created by Mert Dümenci on 10/07/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "HYDefaultCommandHandlerPack.h"
#import "NSString+HybridKit.h"

#import <BlocksKit/BlocksKit.h>

@implementation HYDefaultCommandHandlerPack
-(void)handleCommandString:(NSString *)commandString dictionary:(NSDictionary *)commandDictionary {
    if ([commandString isEqualToString:@"alert"]) {
        UIAlertView *alertView = [UIAlertView alertViewWithTitle:commandDictionary[@"title"] message:commandDictionary[@"message"]];
        [alertView setCancelButtonWithTitle:commandDictionary[@"cancel_button_title"] ? commandDictionary[@"cancel_button_title"] : @"OK" handler:nil];
        [alertView show];
    }

    else if ([commandString isEqualToString:@"open_url"]) {
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:commandDictionary[@"url"]]];
    }

    else if ([commandString isEqualToString:@"set_url"]) {
        self.webViewController.url = [NSURL URLWithString:commandDictionary[@"url"]];
    }

    else if ([commandString isEqualToString:@"set_url_refresh"]) {
        self.webViewController.hasLoadedURL = NO;
        self.webViewController.url = [NSURL URLWithString:commandDictionary[@"url"]];
    }

    else if ([commandString isEqualToString:@"set_title"]) {
        self.webViewController.title = commandDictionary[@"title"];
    }

    else if ([commandString isEqualToString:@"set_scroll_enabled"]) {
        self.webViewController.webView.scrollView.scrollEnabled = [commandDictionary[@"enabled"] boolValue];
    }

    else if ([commandString isEqualToString:@"set_background_color"]) {
        self.webViewController.webView.scrollView.backgroundColor = [commandDictionary[@"color"] hy_colorValue];
    }

    else if ([commandString isEqualToString:@"deceleration_rate"]) {
        NSString *decelerationRate = commandDictionary[@"deceleration_rate"];
        if ([decelerationRate isEqualToString:@"normal"]) {
            self.webViewController.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
        }

        else if ([decelerationRate isEqualToString:@"fast"]) {
            self.webViewController.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
        }
    }

    else if ([commandString isEqualToString:@"trigger_event"]) {
        [self.webViewController.stateMachine fireEvent:commandDictionary[@"event"] error:nil];
    }

    else if ([commandString isEqualToString:@"javascript"]) {
        [self.webViewController.webView stringByEvaluatingJavaScriptFromString:commandDictionary[@"javascript"]];
    }
}

- (BOOL)respondsToCommandString:(NSString *)commandString {
    NSArray *commandArray = @[@"alert", @"open_url", @"set_url", @"set_url_refresh", @"set_title", @"set_scroll_enabled", @"set_background_color", @"deceleration_rate", @"trigger_event", @"javascript"];
    
    return [commandArray containsObject:commandString];
}

@end
