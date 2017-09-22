//
//  RevealUtil.m
//  temp
//
//  Created by Pandara on 16/8/14.
//  Copyright © 2016年 Pandara. All rights reserved.
//

#import "RevealUtil.h"
#import <dlfcn.h>

@implementation RevealUtil
- (void)startReveal {
    if (NSClassFromString(@"IBARevealLoader") != nil) {
        return;
    }

// document    
    NSString *revealLibName = @"libReveal.dylib";
    NSString *documentDirectory = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) firstObject];
    NSString *dylibPath = [documentDirectory stringByAppendingPathComponent:revealLibName];
    
    _revealLib = NULL;
    _revealLib = dlopen([dylibPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_NOW);
    if (_revealLib == NULL) {
        char *error = dlerror();
        NSLog(@"dlopen error: %s", error);
    } else {
        //Post a notification to signal Reveal to start the service
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStart" object:nil];
    }

// bundle
    NSString *revealLibBundlePath = [[NSBundle mainBundle] pathForResource:@"libReveal.dylib" ofType:@""]; 
    _revealLib = dlopen([revealLibBundlePath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_NOW);
    if (_revealLib == NULL) {
        char *error = dlerror();
        NSLog(@"dlopen error: %s", error);
    } else {
        //Post a notification to signal Reveal to start the service
        [[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStart" object:nil];
    }
}

- (void)stopReveal {
    if (_revealLib == NULL) {
        return;
    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"IBARevealRequestStop" object:nil];
    if (dlclose(_revealLib) == 0) {
        _revealLib = NULL;
    } else {
        char *error = dlerror();
        NSLog(@"Reveal library could not be unloaded: %s", error);
    }
}

@end