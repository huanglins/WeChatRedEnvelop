//
//  VHLSelectChatNamesViewController.h
//  opendevtest
//
//  Created by vincent on 2017/3/1.
//
//

#import <UIKit/UIKit.h>

@protocol VHLSelectChatNamesViewControllerDelegate <NSObject>

- (void)onSelectChatNamesReturn:(NSArray *)list;

@optional
- (void)onSelectChatNamesCancel;

@end

@interface VHLSelectChatNamesViewController : UIViewController

- (instancetype)initWithChatNames:(NSArray *)chatNames;

@property (nonatomic, assign) id<VHLSelectChatNamesViewControllerDelegate> delegate;

@end
