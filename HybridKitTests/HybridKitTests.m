//
//  HybridKitTests.m
//  HybridKitTests
//
//  Created by Mert Dümenci on 18/07/13.
//  Copyright (c) 2013 Propeller. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "HYWebViewController.h"

@interface HybridKitTests : XCTestCase
@property (nonatomic, retain) HYWebViewController *webViewController;

- (HYWebViewController *)createWebViewControllerWithParams:(NSDictionary *)params;
@end

@implementation HybridKitTests

- (void)setUp
{
    [super setUp];
    self.webViewController = [self createWebViewControllerWithParams:nil];
    // Set-up code here.
}

- (void)tearDown
{
    // Tear-down code here.
    
    self.webViewController = nil;
    [super tearDown];
}

#pragma mark - Helpers

typedef void (^WaitBlock)(void);

void hy_wait(int wait_time, WaitBlock block) {
    __block BOOL done = false;
    
    double delayInSeconds = wait_time;
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delayInSeconds * NSEC_PER_SEC));
    dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
        block();
        done = true;
    });
    
    do {
        [[NSRunLoop currentRunLoop] runMode:NSDefaultRunLoopMode beforeDate:[NSDate
                                                                             distantFuture]];
    } while (!done);
}

#pragma mark - Tests

- (HYWebViewController *)createWebViewControllerWithParams:(NSDictionary *)params {
    HYWebViewController *webViewController = [[HYWebViewController alloc] initWithParams:params];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:webViewController];
    
    [[UIApplication sharedApplication] keyWindow].rootViewController = navigationController;
    
    return webViewController;
}

- (void)testInitWithParams {
    NSDictionary *params = @{@"url" : @"about:none"};
    self.webViewController = [self createWebViewControllerWithParams:params];
    
    XCTAssertEqualObjects([NSURL URLWithString:params[@"url"]], self.webViewController.url);
}

- (void)testUnescapeSlashes {
    NSDictionary *params = @{@"url" : @"http:%2F%2Fgoogle.com"};
    self.webViewController = [self createWebViewControllerWithParams:params];
    
    XCTAssertEqualObjects([NSURL URLWithString:@"http://google.com"], self.webViewController.url);
}

- (void)testOpenHTML {
    NSDictionary *params = @{@"html" : @"<html><head><%2Fhead><body><%2Fbody><%2Fhtml>"};
    self.webViewController = [self createWebViewControllerWithParams:params];
    
    XCTAssertEqualObjects(@"<html><head></head><body></body></html>", self.webViewController.htmlString);
}

- (void)testDOMReadyRequestLoadRejection {
    NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"domready://anything"]];
    
    XCTAssertFalse([self.webViewController webView:self.webViewController.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther]);
}

- (void)testDOMReadyFlow {
    self.webViewController.url = [NSURL URLWithString:@"http://google.com?dom_event=1"];
    
    hy_wait(2.0, ^{
        XCTAssertEqualObjects(self.webViewController.stateMachine.currentState.name, @"loading");
        
        NSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"domready://anything"]];
        
        XCTAssertFalse([self.webViewController webView:self.webViewController.webView shouldStartLoadWithRequest:request navigationType:UIWebViewNavigationTypeOther]);
        XCTAssertEqualObjects(self.webViewController.stateMachine.currentState.name, @"success");
    });
}

- (void)testCommandURLToJSON {
    NSDictionary *JSON = [self.webViewController commandURLToJSON:[NSURL URLWithString:@"%7B%22command%22%3A%20%22push%22%2C%20%22url%22%3A%20%22http%3A%2F%2Fgoogle.com%22%2C%20%22nested%22%3A%20%7B%22herp%22%3A%20%22derp%22%7D%7D"]].copy;
    
    NSDictionary *expected = @{@"command" : @"push", @"url" : @"http://google.com", @"nested" : @{@"herp" : @"derp"}};
    XCTAssertEqualObjects(expected, JSON);
}

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
- (void)testAlertView {
    self.webViewController.url = [NSURL URLWithString:@"http://google.com"];
    
    NSDictionary *JSON = @{@"command" : @"alert", @"title" : @"Title", @"message" : @"Test", @"cancel_button_title" : @"OK"};
    [self.webViewController runJSONCommand:JSON];
    
    hy_wait(2.0, ^{
        Class klass = NSClassFromString(@"_UIModalItemsCoordinator");
        id coord = [klass performSelector:NSSelectorFromString(@"sharedModalItemsCoordinator")];
        NSMapTable *presentingSessions = [coord valueForKey:@"_presentingSessionsMapTable"];
        
        BOOL found = (presentingSessions != nil);
        
        XCTAssert(found);
    });
}
#pragma clang diagnostic pop

- (void)testSetTitle {
    NSDictionary *JSON = @{@"command" : @"set_title", @"title" : @"my window"};
    [self.webViewController runJSONCommand:JSON];
    
    XCTAssertEqualObjects(self.webViewController.title, JSON[@"title"]);
}

- (void)testScrollEnabled {
    NSDictionary *JSON = @{@"command" : @"set_scroll_enabled", @"enabled" : @"false"};
    [self.webViewController runJSONCommand:JSON];
    
    XCTAssertFalse(self.webViewController.webView.scrollView.scrollEnabled);
}

- (void)testBackgroundColor {
    NSDictionary *JSON = @{@"command" : @"set_background_color", @"color" : @"red"};
    [self.webViewController runJSONCommand:JSON];
    
    XCTAssertEqualObjects(self.webViewController.webView.scrollView.backgroundColor, [UIColor redColor]);
}

- (void)testTriggerEvent {
    [self.webViewController.stateMachine fireEvent:@"start_load" error:nil];
    
    NSDictionary *JSON = @{@"command" : @"trigger_event", @"event" : @"load_error"};
    [self.webViewController runJSONCommand:JSON];
    
    XCTAssertEqualObjects(self.webViewController.stateMachine.currentState.name, @"error");
}

- (void)testDecelerationRate {
    NSDictionary *JSON = @{@"command" : @"deceleration_rate", @"rate" : @"normal"};
    [self.webViewController runJSONCommand:JSON];
    
    XCTAssertEquals(self.webViewController.webView.scrollView.decelerationRate, UIScrollViewDecelerationRateNormal);
}


@end