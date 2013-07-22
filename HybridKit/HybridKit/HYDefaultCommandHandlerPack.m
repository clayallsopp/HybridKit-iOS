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
    SEL action = NSSelectorFromString([commandString.fromUnderscoreToCamelCase stringByAppendingString:@":"]);

    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Warc-performSelector-leaks"

    if ([self respondsToSelector:action]) {
        [self performSelector:action withObject:commandDictionary];
    }

    #pragma clang diagnostic pop
}

- (BOOL)respondsToCommandString:(NSString *)commandString {
    NSArray *commandArray = @[@"alert", @"open_url", @"set_url", @"set_url_refresh", @"set_title", @"set_scroll_enabled", @"set_background_color", @"deceleration_rate", @"trigger_event", @"javascript"];

    return [commandArray containsObject:commandString];
}

- (void)alert:(NSDictionary *)commandDictionary {
    UIAlertView *alertView = [UIAlertView alertViewWithTitle:commandDictionary[@"title"] message:commandDictionary[@"message"]];
    [alertView setCancelButtonWithTitle:commandDictionary[@"cancel_button_title"] ? commandDictionary[@"cancel_button_title"] : @"OK" handler:nil];
    [alertView show];
}

- (void)openUrl:(NSDictionary *)commandDictionary {
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:commandDictionary[@"url"]]];
}

- (void)setUrl:(NSDictionary *)commandDictionary {
    self.webViewController.url = [NSURL URLWithString:commandDictionary[@"url"]];
}

- (void)setUrlRefresh:(NSDictionary *)commandDictionary {
    self.webViewController.hasLoadedURL = NO;
    self.webViewController.url = [NSURL URLWithString:commandDictionary[@"url"]];
}

- (void)setTitle:(NSDictionary *)commandDictionary {
    self.webViewController.title = commandDictionary[@"title"];
}

- (void)setScrollEnabled:(NSDictionary *)commandDictionary {
    self.webViewController.webView.scrollView.scrollEnabled = [commandDictionary[@"enabled"] boolValue];
}

- (void)setBackgroundColor:(NSDictionary *)commandDictionary {
    self.webViewController.webView.scrollView.backgroundColor = [commandDictionary[@"color"] hy_colorValue];
}

- (void)decelerationRate:(NSDictionary *)commandDictionary {
    NSString *decelerationRate = commandDictionary[@"deceleration_rate"];
    if ([decelerationRate isEqualToString:@"normal"]) {
        self.webViewController.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;
    }

    else if ([decelerationRate isEqualToString:@"fast"]) {
        self.webViewController.webView.scrollView.decelerationRate = UIScrollViewDecelerationRateFast;
    }
}

- (void)triggerEvent:(NSDictionary *)commandDictionary {
    [self.webViewController.stateMachine fireEvent:commandDictionary[@"event"] error:nil];
}

- (void)javascript:(NSDictionary *)commandDictionary {
    [self.webViewController.webView stringByEvaluatingJavaScriptFromString:commandDictionary[@"javascript"]];
}

@end
