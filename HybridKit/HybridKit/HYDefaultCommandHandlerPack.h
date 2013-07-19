//
//  HYDefaultCommandHandlerPack.h
//  HYWebViewControlller
//
//  Created by Mert Dümenci on 10/07/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "HYWebViewCommand.h"

/**
    `HYDefaultCommandHandlerPack` is the built-in command handler pack for `HybridKit`.
 
    It can handle `alert`, `open_url`, `set_url`, `set_url_refresh`, `set_title`, `set_scroll_enabled`, `set_background_color`, `deceleration_rate`, `trigger_event` and `javascript` commands.
*/

@interface HYDefaultCommandHandlerPack : HYWebViewCommand

@end
