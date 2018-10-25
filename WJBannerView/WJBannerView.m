//
//  WJBannerView.m
//  WJBannerView
//
//  Created by 王杰 on 2018/10/25.
//  Copyright © 2018年 wangjie. All rights reserved.
//

#import "WJBannerView.h"
#import <UIImageView+WebCache.h>

@interface WJBannerView()<UIScrollViewDelegate>

@property (nonatomic, strong) UIScrollView *contentView;

@property (nonatomic, strong) UIPageControl *pageControl;

@property (nonatomic, strong) UIImageView *currImageView;//当前的

@property (nonatomic, strong) UIImageView *otherImageView;//两边的

@property (nonatomic) NSInteger currIndex;//当前index

@property (nonatomic) NSInteger nextIndex;//下一个（前一个或者后一个）

@end

@implementation WJBannerView {
    NSTimer *timer;//定时器
}

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.timeInterval = 3;
        [self setupUI];
    }
    return self;
}

- (void)willMoveToSuperview:(UIView *)newSuperview {
    [super willMoveToSuperview:newSuperview];
    if (!newSuperview) [self stopTimer];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.contentView.frame = self.bounds;
    NSInteger num = [self.dataSource wj_numberOfRowInWJBannerView:self];
    CGSize size = [self.pageControl sizeForNumberOfPages:num];
    self.pageControl.frame = CGRectMake((self.frame.size.width - size.width) / 2, self.frame.size.height - 20, size.width, 20);
}

- (void)setupUI {
    [self.contentView addSubview:self.currImageView];
    [self.contentView addSubview:self.otherImageView];
    [self addSubview:self.contentView];
    [self addSubview:self.pageControl];
    UITapGestureRecognizer *tgr = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didSelectedItem)];
    [self addGestureRecognizer:tgr];
}

#pragma mark Funcion

- (void)reloadData {
    assert(self.dataSource);
    NSInteger num = [self.dataSource wj_numberOfRowInWJBannerView:self];
    if (num == 0) return;
    if (num > 1) [self startTimer];
    self.pageControl.numberOfPages = num;
    //设置scrollView可滚动的范围
    self.contentView.contentSize = num > 1 ? CGSizeMake(3 * CGRectGetWidth(self.bounds), 0) : CGSizeZero;
    //设置scrollView的偏移量
    self.contentView.contentOffset = num > 1 ? CGPointMake(CGRectGetWidth(self.bounds), 0) : CGPointZero;
    //设置当前图片位置
    self.currImageView.frame = CGRectMake((num > 1 ? CGRectGetWidth(self.bounds) : 0), 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    //获取第一张图片
    NSString *imgName = [self.dataSource wj_bannerView:self imageNameForIndex:0];
    [self.currImageView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:self.imagePlaceholder]];
}

//开启定时器
- (void)startTimer {
    [self stopTimer];
    timer = [NSTimer timerWithTimeInterval:self.timeInterval target:self selector:@selector(intervalRoll) userInfo:nil repeats:YES];
    [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
}

//关闭定时器
- (void)stopTimer {
    [timer invalidate];
    timer = nil;
}

//定时滚动
- (void)intervalRoll {
    [self.contentView setContentOffset:CGPointMake(2 * CGRectGetWidth(self.bounds), 0) animated:YES];
}

#pragma mark Touch Event
//点击当前图片
- (void)didSelectedItem {
    if ([self.delegate respondsToSelector:@selector(wj_bannerView:didSelectedRowAtIndex:)]) {
        [self.delegate wj_bannerView:self didSelectedRowAtIndex:self.currIndex];
    }
}

#pragma mark UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = scrollView.contentOffset;
    //未翻页的情况下 不改变当前图片
    if (offset.x == CGRectGetWidth(self.bounds)) return;
    
    //如果偏移量大于scrollView的width，说明向右，反正向左
    BOOL theRight = offset.x > CGRectGetWidth(self.bounds);
    //下一个出现的坐标
    CGFloat x =  theRight ? 2 * CGRectGetWidth(self.bounds) : 0;
    CGRect rect = CGRectMake(x, 0, CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds));
    self.otherImageView.frame = rect;
    
    NSInteger num = [self.dataSource wj_numberOfRowInWJBannerView:self];
    //(self.currIndex + 1) % image.count 获取下一个对象
    self.nextIndex = theRight ? (self.currIndex + 1) % num : self.currIndex - 1;
    if (self.nextIndex < 0) self.nextIndex = num - 1;//获取数组最后一个
    
    NSString *imgName = [self.dataSource wj_bannerView:self imageNameForIndex:self.nextIndex];
    [self.otherImageView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:self.imagePlaceholder]];
}

//拖动的时候关闭定时器
- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    [self stopTimer];
}

//手指离开拖动的时候开启定时器
- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    [self startTimer];
}

//一次滚动结束
- (void)scrollViewDidEndScrollingAnimation:(UIScrollView *)scrollView {
    [self pauseRoll];
}

//一次滚动结束
- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    [self pauseRoll];
}

- (void)pauseRoll {
    //未翻页的情况下 不改变当前图片
    if (self.contentView.contentOffset.x == CGRectGetWidth(self.bounds)) return;
    self.currIndex = self.nextIndex;
    NSString *imgName = [self.dataSource wj_bannerView:self imageNameForIndex:self.currIndex];
    [self.currImageView sd_setImageWithURL:[NSURL URLWithString:imgName] placeholderImage:[UIImage imageNamed:self.imagePlaceholder]];
    self.pageControl.currentPage = self.currIndex;
    self.contentView.contentOffset = CGPointMake(CGRectGetWidth(self.bounds), 0);
}


#pragma mark Setter and Getter

- (UIScrollView *)contentView {
    if (!_contentView) {
        _contentView = [[UIScrollView alloc] init];
        _contentView.showsHorizontalScrollIndicator = NO;
        _contentView.showsVerticalScrollIndicator = NO;
        _contentView.bounces = NO;
        _contentView.delegate = self;
        _contentView.pagingEnabled = YES;
    }
    return _contentView;
}

- (UIImageView *)otherImageView {
    if (!_otherImageView) {
        _otherImageView = [[UIImageView alloc] init];
        _otherImageView.contentMode = UIViewContentModeScaleAspectFill;
        _otherImageView.clipsToBounds = YES;
    }
    return _otherImageView;
}

- (UIImageView *)currImageView {
    if (!_currImageView) {
        _currImageView = [[UIImageView alloc] init];
        _currImageView.contentMode = UIViewContentModeScaleAspectFill;
        _currImageView.clipsToBounds = YES;
    }
    return _currImageView;
}

- (UIPageControl *)pageControl {
    if (!_pageControl) {
        _pageControl = [[UIPageControl alloc] init];
        _pageControl.hidesForSinglePage = YES;
    }
    return _pageControl;
}

- (void)setPageImage:(NSString *)pageImage {
    _pageImage = [pageImage copy];
    [_pageControl setValue:[UIImage imageNamed:pageImage] forKey:@"_pageImage"];
}

- (void)setCurrentPageImage:(NSString *)currentPageImage {
    _currentPageImage = [currentPageImage copy];
    [_pageControl setValue:[UIImage imageNamed:currentPageImage] forKey:@"_currentPageImage"];
}

@end
