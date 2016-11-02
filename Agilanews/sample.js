require('UIDevice,UIImageView,UIApplication,UIButton,UIImage,UIBarButtonItem,UITableView,UIColor,NewsDetailModel,UIScreen,NSNumber');
defineClass('VideoDetailViewController', {
    viewDidLoad: function() {
        self.super().viewDidLoad();
        if (self.navigationController().navigationBar().respondsToSelector("setBackgroundImage: forBarMetrics:")) {
            var list = self.navigationController().navigationBar().subviews();
            for (var obj in list) {
                if (UIDevice.currentDevice().systemVersion().integerValue() >= 10) {
                    var view = obj;
                    for (var obj2 in view.subviews()) {
                        if (obj2.isKindOfClass(UIImageView.class())) {
                        var image = obj2;
                        image.setHidden(YES);
                        }
                    }
                }
            }
        }
        self.setAutomaticallyAdjustsScrollViewInsets(NO);
        self.setIsBackButton(YES);
//        _toView = UIApplication.sharedApplication().snapshotViewAfterScreenUpdates(NO);
        
//        var shareBtn = UIButton.buttonWithType("UIButtonTypeCustom");
//        shareBtn.setFrame({x:0, y:0, width:40, height:40});
//        shareBtn.setImage_forState(UIImage.imageNamed("icon_article_share_default"), 0);
//        var UIControlEventTouchUpInside  = 1 << 6;
//        shareBtn.addTarget_action_forControlEvents(self, "shareAction", UIControlEventTouchUpInside);
//        var shareItem = UIBarButtonItem.alloc().initWithCustomView(shareBtn);
//        var negativeSpacer = UIBarButtonItem.alloc().initWithBarButtonSystemItem_target_action(6, null, null);
//        negativeSpacer.setWidth(-10);
//        self.navigationItem().setRightBarButtonItems(negativeSpacer, shareItem);
        var playerView = self.playerView();
        self.view().addSubview(playerView);
        self.playerView().setDelegate(self);
        var tableView = self.tableView();
        tableView = UITableView.alloc().initWithFrame_style({x:0, y:playerView.bottom(), width:UIScreen.mainScreen().bounds().width, height:UIScreen.mainScreen().bounds().height - playerView.bottom()}, 1);
        tableView.setBackgroundColor(UIColor.greenColor());
        tableView.setDataSource(self);
        tableView.setDelegate(self);
        tableView.setSectionHeaderHeight(0);
        tableView.setSectionFooterHeight(0);
        tableView.setSeparatorColor(UIColor.redColor());
        self.view().addSubview(tableView);
//        var detailModel = slf.detailModel();
        self.setDetailModel(NewsDetailModel.alloc().init());
        self.detailModel().setTitle("111111.");
        self.detailModel().setSource("22222");
        self.detailModel().setBody("3333333d request, PH to sit as observer in Morocco climate talks, Raphael Banal, Gelo Alolino go 1-2 in regular PBA Draft, Iceland PM announces resignation after vote drubbing");
        self.detailModel().setLikedCount(NSNumber.numberWithInt(5));
    },
});
