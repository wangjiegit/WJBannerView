//
//  ViewController.m
//  WJBannerView
//
//  Created by 王杰 on 2018/10/25.
//  Copyright © 2018年 wangjie. All rights reserved.
//

#import "ViewController.h"
#import "WJBannerView.h"

@interface ViewController ()<WJBannerViewDataSource, WJBannerViewDelegate>

@property (nonatomic, copy) NSArray *array;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    WJBannerView *bannerView = [[WJBannerView alloc] init];
    bannerView.frame = CGRectMake(0, 100, self.view.frame.size.width, 200);
    bannerView.middleImageViewEdgeLeft = 35;
    bannerView.dataSource = self;
    bannerView.delegate = self;
    [self.view addSubview:bannerView];
    [bannerView reloadData];
}

#pragma mark WJBannerViewDelegate
- (void)wj_bannerView:(WJBannerView *)bannerView didSelectedRowAtIndex:(NSInteger)index {
    
}

#pragma mark WJBannerViewDataSource
- (NSString *)wj_bannerView:(WJBannerView *)bannerView imageNameForIndex:(NSInteger)index {
    return self.array[index];
}

- (NSInteger)wj_numberOfRowInWJBannerView:(WJBannerView *)bannerView {
    return self.array.count;
}

- (NSArray *)array {
    if (!_array) {
        _array = @[
                   @"https://img.tbb.la/images/201803/thumb_img/6829_thumb_P_1522108048012.jpg",
                   @"https://img.tbb.la/images/201803/thumb_img/6829_thumb_P_1522108048868.jpg"];
    }
    return _array;
}

@end
