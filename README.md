# HybridKit for iOS

**iOS version of HybridKit, a pseudo Web <-> iOS/Android bridge.**

![Screenshot](http://i.imgur.com/K86x7V1l.png)

# What is it?

HybridKit is an extensible, basic messaging system for your web view induced native apps.

Using our [JavaScript library](http://github.com/usepropeller/HybridKit-JS), you can send commands from your web page for the native counterpart to catch it.

HybridKit uses **command handlers** for handling commands thrown at it using the [JavaScript library](http://github.com/usepropeller/HybridKit-JS). You can create new command handlers to extend the built-in ones or to bring completely new features.

# Setup

HybridKit for iOS requires [CocoaPods](http://cocoapods.org/). Add it to your `Podfile`:

```ruby
pod 'HybridKit'
```

Run `pod install` and you're off!

# Usage

You can utilize HybridKit by using  `HYWebViewController` instead of  `UIWebViewController`. `HYWebViewController` will  be ready to catch commands by registering the default command handlers automatically.

Setup `HYWebViewController` and load a URL.
```Objective-C
HYWebViewController *webViewController = [[HYWebViewController alloc] initWithParams:@{@"url" : @"http://google.com"}];

// or

HYWebViewController *webViewController = [[HYWebViewController alloc] init];
webViewController.url = [NSURL URLWithString:@"http://google.com"];

[self presentViewController:webViewController animated:YES completion:nil];
```

## Built-in command handler

The built-in command handler can handle :
`alert`, `open_url`, `set_url`, `set_url_refresh`, `set_title`, `set_scroll_enabled`, `set_background_color`, `deceleration_rate`, `trigger_event` and `javascript` commands.

For more information about the built-in command handler, check the [HybridKit-JS Wiki](https://github.com/usepropeller/HybridKit-iOS/wiki).

## Creating a new command handler

You can create new command handlers for custom commands invoked using the [JavaScript library](http://github.com/usepropeller/HybridKit-JS) easily.

Subclass `HYWebViewCommand` and override `handleCommandString:dictionary` & `respondsToCommandString` methods.

```Objective-C

@interface HideNavigationBarHandler : HYWebViewCommand
@end

@implementation HideNavigationBarHandler
-(void)handleCommandString:(NSString *)commandString dictionary:(NSDictionary *)commandDictionary {
	if ([commandString isEqualToString:@"hide_navbar"]) {
       self.webViewController.navigationController.navigationBarHidden = [commandDictionary[@"hidden"] boolValue];
	}
}

- (BOOL)respondsToCommandString:(NSString *)commandString {
	return [commandString isEqualToString:@"hide_navbar"];
}
@end
```

Register the new command handler to a `HYWebViewController` instance.

```Objective-C
[webViewController registerCommandHandler:[HideNavigationBarHandler new]];
```

Invoke it using the [JavaScript library](http://github.com/usepropeller/HybridKit-JS).

```JavaScript
HybridKit.runCommand("hide_navbar", {hidden: true});
```

# Contact

[Mert Dümenci](http://dumenci.me/)
[@mertdumenci](https://twitter.com/mertdumenci)

[Clay Allsopp](http://clayallsopp.com/)
[@clayallsopp](https://twitter.com/clayallsopp)
