//
//  HYWebViewController.m
//  HYWebViewControlller
//
//  Created by Mert Dümenci on 7/2/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "HYWebViewController.h"
#import "NSString+HybridKit.h"
#import "HYDefaultCommandHandlerPack.h"

#import <SVProgressHUD/SVProgressHUD.h>

#define IS_IOS7 !([[[UIDevice currentDevice] systemVersion] floatValue] < 7.0f)
#define HY_LOG(str, ...) if (self.loggingEnabled) NSLog(@"<%@ | %p> %@", NSStringFromClass(self.class), self, [NSString stringWithFormat:str, ##__VA_ARGS__])

@interface HYWebViewController ()
@end

@interface HYWebViewController (Commands)
@end

@implementation HYWebViewController {
    NSDictionary *_params;
}

@synthesize webView = _webView;

- (instancetype)initWithParams:(NSDictionary *)params {
    self = [super init];

    if (self) {
        _params = params;
    }

    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.webView.delegate = self;
    
    [self stateMachine];
    [self registerDefaultCommandHandlers];

    if (_params[@"url"]) self.url = [NSURL URLWithString:[_params[@"url"] hy_slashUnescaped]];
    if (_params[@"html"]) self.htmlString = [_params[@"html"] hy_slashUnescaped];
}

#pragma mark - Command handler interface

- (void)registerCommandHandler:(id<HYWebViewCommand>)commandHandler {
    commandHandler.webViewController = self;
    [self.commandHandlers addObject:commandHandler];
}

- (void)unregisterCommandHandler:(id<HYWebViewCommand>)commandHandler {
    [self.commandHandlers removeObject:commandHandler];
}

- (void)registerDefaultCommandHandlers {
    [self registerCommandHandler:[HYDefaultCommandHandlerPack new]];
}

#pragma mark - Internal command handling

- (NSMutableDictionary *)commandURLToJSON:(NSURL *)url {
    /*
        Slices & parses the command URL.
    */
    
    NSArray *commandURLComponents = [url.absoluteString componentsSeparatedByString:@"command:"];
    NSString *encodedJSON = commandURLComponents[commandURLComponents.count - 1];
    NSString *unencodedJSON = [encodedJSON hy_realUnescaped];

    NSError *error;
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:[unencodedJSON dataUsingEncoding:NSUTF8StringEncoding] options:0 error:&error];

    return dict.mutableCopy;
}

- (BOOL)runJSONCommand:(NSDictionary *)json {
    HY_LOG(@"Got JSON command : %@", json);
    
    NSString *commandString = json[@"command"];
    if (!commandString) return NO;
    
    BOOL executed = NO;

    if ([self.delegate respondsToSelector:@selector(hybridWebViewController:onWebCommand:)]) {
        executed = [self.delegate hybridWebViewController:self onWebCommand:json];
    }
    
    if (!executed) {
        for (id <HYWebViewCommand> commandHandler in self.commandHandlers) {
            if ([commandHandler respondsToCommandString:commandString]) {
                [commandHandler handleCommandString:commandString dictionary:json];
                executed = YES;
                break;
            }
        }
    }

    if (json[@"callback_javascript"]) {
        [self.webView stringByEvaluatingJavaScriptFromString:json[@"callback_javascript"]];
    }

    return executed;
}

#pragma mark - Property getters

- (NSMutableArray *)commandHandlers {
    if (!_commandHandlers) {
        _commandHandlers = @[].mutableCopy;
    }

    return _commandHandlers;
}

- (void)setUrl:(NSURL *)url {
    if (_url != url) {
        _url = url;

        NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
        urlRequest.cachePolicy = NSURLRequestReloadIgnoringCacheData;
        [self.webView loadRequest:urlRequest];
    }
}

- (void)setHtmlString:(NSString *)htmlString {
    if (_htmlString != htmlString) {
        _htmlString = htmlString;
        
        [self.webView loadHTMLString:_htmlString baseURL:[NSURL fileURLWithPath:[[NSBundle mainBundle] bundlePath]]];
    }
}

- (UIActivityIndicatorView *)activityIndicator {
    if (!_activityIndicator) {
        _activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
        _activityIndicator.center = self.view.center;
        _activityIndicator.translatesAutoresizingMaskIntoConstraints = NO;
        [_activityIndicator startAnimating];

        [self.view addSubview:_activityIndicator];

        NSLayoutConstraint *centerXConstraint = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterX multiplier:1 constant:0];
        NSLayoutConstraint *centerYConstraint = [NSLayoutConstraint constraintWithItem:_activityIndicator attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeCenterY multiplier:1 constant:0];

        [self.view addConstraint:centerXConstraint];
        [self.view addConstraint:centerYConstraint];
    }

    return _activityIndicator;
}

- (TKStateMachine *)stateMachine {
    if (!_stateMachine) {

        _stateMachine = [TKStateMachine new];

        TKState *setup = [TKState stateWithName:@"setup"];
        TKState *loading = [TKState stateWithName:@"loading"];

        [loading setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
            if (!self.hasLoadedURL) {
                self.webView.hidden = YES;
                self.webView.scrollView.scrollEnabled = NO;
                self.activityIndicator.hidden = NO;
            }
        }];

        [loading setDidExitStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
            self.navigationItem.rightBarButtonItem = nil;
            self.activityIndicator.hidden = YES;
        }];


        TKState *error = [TKState stateWithName:@"error"];
        [error setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
            self.webView.hidden = YES;

            [SVProgressHUD showErrorWithStatus:@"Error :("];
            if ([self.delegate respondsToSelector:@selector(hybridWebViewControllerDidFailLoad:)]) {
                [self.delegate hybridWebViewControllerDidFailLoad:self];
            }
        }];

        [error setDidExitStateBlock:^(TKState *state, TKStateMachine *stateMachine) {
            self.navigationItem.rightBarButtonItem = nil;
        }];

        TKState *success = [TKState stateWithName:@"success"];
        [success setDidEnterStateBlock:^(TKState *state, TKStateMachine *stateMachine) {

            self.hasLoadedURL = NO;
            self.webView.hidden = NO;
            self.webView.scrollView.scrollEnabled = YES;
        }];

        [_stateMachine addStates:@[setup, loading, error, success]];

        TKEvent *startLoad = [TKEvent eventWithName:@"start_load" transitioningFromStates:@[setup, success, error] toState:loading];
        TKEvent *loadError = [TKEvent eventWithName:@"load_error" transitioningFromStates:@[loading] toState:error];
        TKEvent *finishLoad = [TKEvent eventWithName:@"finish_load" transitioningFromStates:@[loading] toState:success];

        [_stateMachine addEvents:@[startLoad, loadError, finishLoad]];
        [_stateMachine isInState:@"setup"];

        [_stateMachine activate];
    }

    return _stateMachine;
}

- (UIWebView *)webView {
    if (!_webView) {
        _webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        _webView.translatesAutoresizingMaskIntoConstraints = NO;

        [self.view addSubview:_webView];
        
        /*
            Auto layout in code is a lot of work.
        */
        
        for (NSNumber *attribute in @[@(NSLayoutAttributeCenterX), @(NSLayoutAttributeCenterY), @(NSLayoutAttributeTop), @(NSLayoutAttributeLeft), @(NSLayoutAttributeRight), @(NSLayoutAttributeBottom), @(NSLayoutAttributeWidth), @(NSLayoutAttributeHeight)]) {
            NSLayoutConstraint *constraint = [NSLayoutConstraint constraintWithItem:_webView attribute:attribute.integerValue relatedBy:NSLayoutRelationEqual toItem:self.view attribute:attribute.integerValue multiplier:1 constant:0];
            [self.view addConstraint:constraint];
        }

        _webView.scrollView.decelerationRate = UIScrollViewDecelerationRateNormal;

        _webView.scrollView.backgroundColor = [UIColor whiteColor];
        _webView.suppressesIncrementalRendering = NO;
        _webView.delegate = self;

        for (UIView *subview in self.webView.scrollView.subviews) {
            if ([subview isKindOfClass:[UIImageView class]]) {
                subview.hidden = YES;
            }
        }
    }

    return _webView;
}

#pragma mark - UIWebViewDelegate

- (BOOL)webView:(UIWebView *)webView shouldStartLoadWithRequest:(NSURLRequest *)request navigationType:(UIWebViewNavigationType)navigationType {
    NSString *scheme = request.URL.scheme;

    if ([scheme isEqualToString:@"domready"]) {
        [self.stateMachine fireEvent:@"finish_load" error:nil];
        return NO;
    }

    else if ([scheme isEqualToString:@"command"]) {
        NSDictionary *commandDictionary = [self commandURLToJSON:request.URL].copy;
        [self runJSONCommand:commandDictionary];
        return NO;
    }

    return YES;
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    [self.stateMachine fireEvent:@"start_load" error:nil];
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    if ([self.url.absoluteString rangeOfString:@"dom_event"].location == NSNotFound || !self.url.absoluteString) {
        [self.stateMachine fireEvent:@"finish_load" error:nil];
    }
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    if (error.code == NSURLErrorCancelled) return;
    [self.stateMachine fireEvent:@"load_error" error:nil];
}

@end