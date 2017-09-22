//
//  RevealUtil.h
//  temp
//
//  Created by Pandara on 16/8/14.
//  Copyright © 2016年 Pandara. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RevealUtil : NSObject {
    void *_revealLib;
}

- (void)startReveal;
- (void)stopReveal;

@end