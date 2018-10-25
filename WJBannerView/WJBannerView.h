//
//  WJBannerView.h
//  WJBannerView
//
//  Created by 王杰 on 2018/10/25.
//  Copyright © 2018年 wangjie. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol WJBannerViewDataSource, WJBannerViewDelegate;

@interface WJBannerView : UIView

@property (nonatomic, copy) NSString *imagePlaceholder;//默认图片

@property (nonatomic, copy) NSString *pageImage;//翻页小点图片

@property (nonatomic, copy) NSString *currentPageImage;

@property (nonatomic, weak) id<WJBannerViewDataSource> dataSource;

@property (nonatomic, weak) id<WJBannerViewDelegate> delegate;

@property (nonatomic) NSUInteger timeInterval;//自动滚动时间间隔 默认2秒

- (void)reloadData;

@end

@protocol WJBannerViewDataSource <NSObject>

@required
//图片总个数
- (NSInteger)wj_numberOfRowInWJBannerView:(WJBannerView *)bannerView;

//获取当前图片urlString
- (NSString *)wj_bannerView:(WJBannerView *)bannerView imageNameForIndex:(NSInteger)index;

@end;

@protocol WJBannerViewDelegate <NSObject>

@optional
//点击事件
- (void)wj_bannerView:(WJBannerView *)bannerView didSelectedRowAtIndex:(NSInteger)index;

@end
