//
//  VHLBaseViewController.h
//  opendevtest
//
//  Created by vincent on 2017/2/28.
//
//

#import <UIKit/UIKit.h>
// #impott <Foundation/Foundation.h>

@interface VHLBaseViewController : UIViewController

- (void)startLoadingBlocked;
- (void)startLoadingNonBlock;
- (void)startLoadingWithText:(NSString *)text;
- (void)stopLoading;
- (void)stopLoadingWithFailText:(NSString *)text;
- (void)stopLoadingWithOKText:(NSString *)text;


@end
