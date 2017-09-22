//
//  VHLSettingWeRunViewController.m
//  opendevtest
//
//  Created by vincent on 2017/3/2.
//
//

#import "VHLSettingWeRunViewController.h"
//
//
#import "WeChatRedEnvelop.h"
#import "VHLRedEnvelopConfig.h"
#import <objc/objc-runtime.h>

@interface VHLSettingWeRunViewController ()

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation VHLSettingWeRunViewController

- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    if (self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil]) {
        _tableViewInfo = [[objc_getClass("MMTableViewInfo") alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStyleGrouped];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initTitle];
    [self reloadTableData];
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [self.view addSubview:tableView];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    
    [self stopLoading];
}

- (void)initTitle {
    self.title = @"微信运动";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    
    [self addWeRunSettingSection];      // 微信运动
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}
#pragma mark - 微信运动
/*
 微信运动
 */
- (void)addWeRunSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"微信运动"];
    if ([VHLRedEnvelopConfig sharedConfig].editWeRunEnable)
    {
        [sectionInfo addCell:[self createWeRunEnableCell]];
        [sectionInfo addCell:[self createEditWeRunStepCell]];
    } else {
        [sectionInfo addCell:[self createWeRunEnableCell]];
    }
    
    [self.tableViewInfo addSection:sectionInfo];
}
- (MMTableViewSectionInfo *)createWeRunEnableCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingWeRunEnable:) target:self title:@"修改微信运动" on:[VHLRedEnvelopConfig sharedConfig].editWeRunEnable];
}
- (MMTableViewCellInfo *)createEditWeRunStepCell {
    return [objc_getClass("MMTableViewCellInfo") editorCellForSel:@selector(handleStepCount:) target:self title:nil margin:4.0 tip:@"请输入步数" focus:YES text:[NSString stringWithFormat:@"%ld", (long)[VHLRedEnvelopConfig sharedConfig].editWeRunStep]];
}
#pragma mark - method
- (void)settingWeRunEnable:(UISwitch *)werunSwitch {
    [VHLRedEnvelopConfig sharedConfig].editWeRunEnable = werunSwitch.on;
    // 刷新
    [self reloadTableData];
}
- (void)handleStepCount:(UITextField *)sender
{
    NSInteger maxStep = 100000;

    NSInteger step = sender.text.integerValue;
    if (step > maxStep)
    {
        step = maxStep;

        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[NSString stringWithFormat:@"怕你比我多，最多只能设置%ld。给作者发红包涨步数，谢谢~",(long)maxStep] message:nil delegate:nil cancelButtonTitle:@"好哒" otherButtonTitles:nil, nil];
        [alert show];
    }
    [VHLRedEnvelopConfig sharedConfig].editWeRunStep = step;

    [self reloadTableData];
}

@end
