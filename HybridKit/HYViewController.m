//
//  HYViewController.m
//  HybridKit
//
//  Created by Mert Dümenci on 18/07/13.
//  Copyright (c) 2013 Propeller. All rights reserved.
//

#import "HYViewController.h"

@interface HYViewController ()

@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    NSString *testHTMLPath = [[NSBundle mainBundle] pathForResource:@"test_html" ofType:@"html"];
    NSString *HTMLString = [NSString stringWithContentsOfFile:testHTMLPath encoding:NSUTF8StringEncoding error:nil];

    self.htmlString = HTMLString;
    self.delegate = self;
    
    self.webView.scrollView.scrollIndicatorInsets = self.webView.scrollView.contentInset = UIEdgeInsetsMake(66, 0, 0, 0);
}


@end
