//
//  VHLSettingLocationViewController.m
//  opendevtest
//
//  Created by vincent on 2017/3/2.
//
//

#import "VHLSettingLocationViewController.h"
//
//
#import "WeChatRedEnvelop.h"
#import "VHLRedEnvelopConfig.h"
#import <objc/objc-runtime.h>

@interface VHLSettingLocationViewController ()

@property (nonatomic, strong) MMTableViewInfo *tableViewInfo;

@end

@implementation VHLSettingLocationViewController

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
    self.title = @"微信定位";
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName: [UIFont boldSystemFontOfSize:18.0]}];
}

- (void)reloadTableData {
    [self.tableViewInfo clearAllSection];
    
    [self addLocationSettingSection];      // 微信运动
    
    MMTableView *tableView = [self.tableViewInfo getTableView];
    [tableView reloadData];
}
#pragma mark - 微信定位
/*
 微信运动
 */
- (void)addLocationSettingSection {
    MMTableViewSectionInfo *sectionInfo = [objc_getClass("MMTableViewSectionInfo") sectionInfoHeader:@"微信定位" Footer:@"如-> 纬度：35.707013 经度：139.730562"];
    if ([VHLRedEnvelopConfig sharedConfig].editWeLocationEnable)
    {
        [sectionInfo addCell:[self createLocationEnableCell]];
        [sectionInfo addCell:[self selectLocationCell]];
        [sectionInfo addCell:[self editWeLocationLatitudeCell]];
        [sectionInfo addCell:[self editWeLocationLongitudeCell]];
    } else {
        [sectionInfo addCell:[self createLocationEnableCell]];
    }
    
    [self.tableViewInfo addSection:sectionInfo];
}
- (MMTableViewSectionInfo *)createLocationEnableCell {
    return [objc_getClass("MMTableViewCellInfo") switchCellForSel:@selector(settingLocationEnable:) target:self title:@"修改微信定位" on:[VHLRedEnvelopConfig sharedConfig].editWeLocationEnable];
}
- (MMTableViewSectionInfo *)selectLocationCell {
    return [objc_getClass("MMTableViewCellInfo") normalCellForSel:@selector(settingSelectLocation) target:self title:@"选择定位" rightValue:@"" accessoryType:1];
}
- (MMTableViewCellInfo *)editWeLocationLongitudeCell {
    return [objc_getClass("MMTableViewCellInfo") editorCellForSel:@selector(editLongitude:) target:self title:nil margin:4.0 tip:@"请输入经度" focus:YES text:[NSString stringWithFormat:@"%f", [VHLRedEnvelopConfig sharedConfig].editWeLocationLongitude]];
}
- (MMTableViewCellInfo *)editWeLocationLatitudeCell {
    return [objc_getClass("MMTableViewCellInfo") editorCellForSel:@selector(editLatitude:) target:self title:nil margin:4.0 tip:@"请输入纬度" focus:YES text:[NSString stringWithFormat:@"%f", [VHLRedEnvelopConfig sharedConfig].editWeLocationLatitude]];
}
#pragma mark - method
- (void)settingLocationEnable:(UISwitch *)locationSwitch {
    [VHLRedEnvelopConfig sharedConfig].editWeLocationEnable = locationSwitch.on;
    // 刷新
    [self reloadTableData];
}
- (void)settingSelectLocation{

}
- (void)editLongitude:(UITextField *)sender
{
    CGFloat longitude = sender.text.floatValue;
    
    [VHLRedEnvelopConfig sharedConfig].editWeLocationLongitude = longitude;
}
- (void)editLatitude:(UITextField *)sender
{
    CGFloat latitude = sender.text.floatValue;
    
    [VHLRedEnvelopConfig sharedConfig].editWeLocationLatitude = latitude;
}

@end
