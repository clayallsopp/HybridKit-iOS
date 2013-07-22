//
//  NSString+HybridKit.h
//  HYWebViewControlller
//
//  Created by Mert Dümenci on 10/07/13.
//  Copyright (c) 2013 Mert Dumenci. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (HybridKit)

- (NSString *)hy_slashEscaped;
- (NSString *)hy_slashUnescaped;
- (NSString *)hy_realEscaped;
- (NSString *)hy_realUnescaped;

- (UIColor *)hy_colorValue;
- (BOOL)hy_isValidHexColor;

- (NSString *)fromUnderscoreToCamelCase;

@end
