# WJBannerView
## 两个UIImageView实现banner效果
```
WJBannerView *bannerView = [[WJBannerView alloc] init];
bannerView.frame = CGRectMake(0, 100, self.view.frame.size.width, 200);
bannerView.dataSource = self;
bannerView.delegate = self;
[self.view addSubview:bannerView];
[bannerView reloadData];
```
