//
//  HYWebViewCommandProtocol.h
//  HYWebViewControlller
//
//  Created by Mert Dümenci on 10/07/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

@class HYWebViewController;

/**
    `HYWebViewCommand` is the protocol command handlers must conform to.
 */

@protocol HYWebViewCommand <NSObject>

/**
    The `HYWebViewController` instance that this command handler was invoked on.
 */

@property (nonatomic, assign) HYWebViewController *webViewController;

@required

/**
    Which command strings does this command handler handle? The `HYWebViewController` instance routes commands according to this method.
    @param commandString The command string to be checked.
    @return Does this instance respond to this command?
*/

- (BOOL)respondsToCommandString:(NSString *)commandString;

/**
    `HYWebViewController` automatically invokes this method with the appropriate arguments if `-respondsToCommandString` returned true.
    @param commandString The command string which this command handler told the `HYWebViewController` that it will handle.
    @param commandDictionary The full command dictionary from the `HYWebViewController` instance.
 */

- (void)handleCommandString:(NSString *)commandString dictionary:(NSDictionary *)commandDictionary;

@end