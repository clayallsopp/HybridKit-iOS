//
//  NSString+HybridKit.m
//  HYWebViewControlller
//
//  Created by Mert Dümenci on 10/07/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import "NSString+HybridKit.h"

#import <HexColors/HexColor.h>

@implementation NSString (HybridKit)
- (NSString *)hy_slashEscaped {
    return [self stringByReplacingOccurrencesOfString:@"/" withString:@"%2F"];
}

- (NSString *)hy_slashUnescaped {
    return [self stringByReplacingOccurrencesOfString:@"%2F" withString:@"/"];
}

- (NSString *)hy_realEscaped {
    return (__bridge NSString *)CFURLCreateStringByAddingPercentEscapes(nil, (__bridge CFStringRef)(self), nil, (__bridge CFStringRef)@"!*'();:@&=+$,/?%#[]", kCFStringEncodingUTF8);
}

- (NSString *)hy_realUnescaped {
    return (__bridge NSString *)CFURLCreateStringByReplacingPercentEscapesUsingEncoding(nil, (__bridge CFStringRef)(self), (__bridge CFStringRef)@"", kCFStringEncodingUTF8);
}

- (UIColor *)hy_colorValue {
    NSString *using = self;
    
    if ('#' != [self characterAtIndex:0]) {
        using = [NSString stringWithFormat:@"#%@", self];
    }
    
    NSString *strippedString = [using stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    if (self.hy_isValidHexColor) {
        return [HXColor colorWithHexString:using alpha:1.f];
    }
    
    else {
        NSString *selectorString = [strippedString.lowercaseString stringByAppendingString:@"Color"];
        SEL selector = NSSelectorFromString(selectorString);
        
        if ([UIColor respondsToSelector:selector]) {
            return [UIColor performSelector:selector];
        }
        
        return nil;
    }
}
         
- (BOOL)hy_isValidHexColor {
    NSString *using = self;
    
    if ('#' != [self characterAtIndex:0]) {
        using = [NSString stringWithFormat:@"#%@", self];
    }
    
    if (using.length != 7) return NO;
    
    using = [using stringByReplacingOccurrencesOfString:@"#" withString:@""];
    
    BOOL isValidHex = true;
    
    for(int i = 0; i < using.length; ++i) {
        char current = [using UTF8String][i];
        if (!isxdigit(current)) {
            isValidHex = false;
            break;
        }
    }
    
    return isValidHex;
}

- (NSString *)fromUnderscoreToCamelCase {
    NSArray *parts = [self componentsSeparatedByString:@"_"];
    NSMutableString *builder = [NSMutableString string];
    BOOL shouldUpperCase = NO;
    for (NSString *part in parts) {
        NSString *first = [part substringToIndex:1];
        NSString *rest = [part substringFromIndex:1];
        if (shouldUpperCase) {
            first = [first uppercaseString];
        }
        [builder appendFormat:@"%@%@", first, rest];
        shouldUpperCase = YES;
    }
    return builder;
}

@end
