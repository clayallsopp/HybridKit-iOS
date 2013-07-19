//
//  HYWebViewCommand.h
//  HYWebViewControlller
//
//  Created by Mert Dümenci on 10/07/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "HYWebViewCommandProtocol.h"
#import "HYWebViewController.h"

/**
    `HYWebViewCommand` is the base class for creating new command handlers. Subclass this when you're creating a new command handler.
 */

@interface HYWebViewCommand : NSObject <HYWebViewCommand>
@property (nonatomic, assign) HYWebViewController *webViewController;
@end

