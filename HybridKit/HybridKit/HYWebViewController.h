//
//  HYWebViewController.h
//  HYWebViewControlller
//
//  Created by Mert Dümenci on 7/2/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <TransitionKit/TransitionKit.h>
#import "HYWebViewCommandProtocol.h"

@class HYWebViewController;

/**
    `HYWebViewControllerDelegate` is the protocol which the delegates must conform to.
 */

@protocol HYWebViewControllerDelegate <NSObject, UIWebViewDelegate>

@optional
- (BOOL)hybridWebViewController:(HYWebViewController *)webViewController onWebCommand:(NSDictionary *)jsonDictionary;
- (void)hybridWebViewControllerDidFailLoad:(HYWebViewController *)webViewController;

@end

/**
    `HYWebViewController` is the main component of `HybridKit`. It encapsulates a web view and command handling logic.
*/

@interface HYWebViewController : UIViewController <UIWebViewDelegate>

///-------------------------------
/// @name Properties
///-------------------------------

/**
    The property for loading a URL on the internal `UIWebView`.
 */

@property (nonatomic, retain) NSURL *url;

/**
    The property for loading an HTML string on the internal `UIWebView`.
*/

@property (nonatomic, copy) NSString *htmlString;

/**
    Shows if the internal `UIWebView` has a loaded URL.
 */

@property (nonatomic) BOOL hasLoadedURL;

/**
    Delegate property implementing the `HYWebViewControllerDelegate` protocol.
 */

@property (nonatomic, weak) id <HYWebViewControllerDelegate> delegate;

/**
    The internal `UIWebView`.
*/

@property (nonatomic, retain) UIWebView *webView;

/**
    The activity indicator that gets shown during the loading state of the internal `UIWebView`.
*/

@property (nonatomic, retain) UIActivityIndicatorView *activityIndicator;

/**
    The main state machine handling the internal state of `HYWebViewController`.
 */

@property (nonatomic, retain) TKStateMachine *stateMachine;

/**
    An array of registered command handlers implementing the `HYWebViewCommand` protocol.
*/

@property (nonatomic, retain) NSMutableArray *commandHandlers;

/**
    Determines if `HYWebViewController` should enable debug logging.
 */

@property (nonatomic) BOOL loggingEnabled;

///-------------------------------
/// @name Methods
///-------------------------------

/**
    Main constructor.
 
    @param params A dictionary of load parameters, 'url' and 'html' specifically.
    @return HYWebViewController instance.
 */

- (instancetype)initWithParams:(NSDictionary *)params;

///-------------------------------
/// @name Command handlers
///-------------------------------

/**
    Register a new command handler for handling command requests.
    @param commandHandler The command handler to be registered.
*/

- (void)registerCommandHandler:(id <HYWebViewCommand>)commandHandler;

/**
    Unregister a registered command handler.
    @param commandHandler The command handler to be unregistered.
 */

- (void)unregisterCommandHandler:(id <HYWebViewCommand>)commandHandler;

/**
    Register the default command handler pack bundled with `HybridKit`. This is automatically invoked at instantiation.
 */

- (void)registerDefaultCommandHandlers;

///-------------------------------
/// @name Run commands
///-------------------------------

/**
    Manually run a JSON command. This gets automatically invoked when the web view gets a `command:` url request.
    @param json The JSON command to be invoked.
    @return Shows if any of the internal command handlers handled the JSON command.
 */

- (BOOL)runJSONCommand:(NSDictionary *)json;

/**
    Convert a `command:` url to JSON.
    @param url The `command:` url to be converted to JSON.
    @return The JSON extracted from the `command:` url.
*/

- (NSMutableDictionary *)commandURLToJSON:(NSURL *)url;

@end
