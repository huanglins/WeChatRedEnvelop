//
//  VHLBaseViewController.m
//  opendevtest
//
//  Created by vincent on 2017/2/28.
//
//

#import "VHLBaseViewController.h"
#import "WeChatRedEnvelop.h"
#import <objc/objc-runtime.h>

@interface VHLBaseViewController ()

@property (nonatomic, strong) MMLoadingView *loadingView;

@end

@implementation VHLBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)startLoadingBlocked
{
    if (!self.loadingView) {
        self.loadingView = [self createDefaultLoadingView];
        [self.view addSubview:self.loadingView];
    } else {
        [self.view bringSubviewToFront:self.loadingView];
    }
    [self.loadingView setM_bIgnoringInteractionEventsWhenLoading:NO];
    [self.loadingView setFitFrame:1];
    [self.loadingView startLoading];
}
- (void)startLoadingNonBlock
{
    if (!self.loadingView) {
        self.loadingView = [self createDefaultLoadingView];
        [self.view addSubview:self.loadingView];
    } else {
        [self.view bringSubviewToFront:self.loadingView];
    }
    [self.loadingView setM_bIgnoringInteractionEventsWhenLoading:NO];
    [self.loadingView setFitFrame:1];
    [self.loadingView startLoading];
}
- (void)startLoadingWithText:(NSString *)text
{
    [self startLoadingNonBlock];
    
    [self.loadingView.m_label setText:text];
}
- (void)stopLoading
{
    [self.loadingView stopLoading];
}
- (void)stopLoadingWithFailText:(NSString *)text
{
    [self.loadingView stopLoadingAndShowError:text];
}
- (void)stopLoadingWithOKText:(NSString *)text
{
    [self.loadingView stopLoadingAndShowOK:text];
}

#pragma mark - private
- (MMLoadingView *)createDefaultLoadingView {
    MMLoadingView *loadingView = [[objc_getClass("MMLoadingView") alloc] init];
    
    MMServiceCenter *serviceCenter = [objc_getClass("MMServiceCenter") defaultCenter];
    MMLanguageMgr *languageMgr = [serviceCenter getService:objc_getClass("MMLanguageMgr")];
    NSString *loadingText = [languageMgr getStringForCurLanguage:@"Common_DefaultLoadingText" defaultTo:@"Common_DefaultLoadingText"];
    
    [loadingView.m_label setText:loadingText];
    
    return loadingView;
}
@end
