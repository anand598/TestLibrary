//
//  PDPWebController.m
//  Pods
//
//  Created by Rijul Gupta on 5/18/17.
//
//

#import "PDPWebController.h"
#import <Masonry/Masonry.h>
#import "SyndecaRevealViewController.h"
#import "Icons.h"
#import "UIViewHelper.h"
#import "MasterConfiguration.h"
#import "ShareProxy.h"


@interface PDPWebController () <UIGestureRecognizerDelegate>
@property (readwrite) WKWebView* webview;
@property (readwrite) NSURLRequest* request;
@property (readwrite) UIBarButtonItem* shareRightBarButton;
@property (readwrite) UIActivityViewController* shareViewController;
@property (readwrite) UIPopoverController* popOverController;

@end

@implementation PDPWebController

- (id)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        self.request = request;
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated {
    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [self setNavigationItems];
    
    ProductGroupModel* pm = self.productGroupModel;

    UIBarButtonItem* indicatorButton = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
    self.navigationItem.rightBarButtonItem = indicatorButton;
    
    if (pm != nil && pm.url1_shareurl) {
        
        //Create the share tab bar button
        self.shareRightBarButton = [[UIBarButtonItem alloc]
                                    initWithBarButtonSystemItem:UIBarButtonSystemItemAction
                                    target:self
                                    action:@selector(shareProduct)];
        self.shareRightBarButton.accessibilityLabel = @"item-share-product";

//        This overwrites the global tab bar icon color settings.
//        self.shareRightBarButton.tintColor = [UIColor blackColor];
        
        self.navigationItem.rightBarButtonItems = @[indicatorButton, self.shareRightBarButton];
        
//        Update the heart icon if we allow a user to favorite items
        //        [self updateHeartTabBarItem];
    }
    
    
    
    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(didTapOnView)];
    
    //
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webview loadRequest:self.request];
        //REMOVES ALL STORED MEMORY
//        NSSet *websiteDataTypes
//        = [NSSet setWithArray:@[
//                                WKWebsiteDataTypeDiskCache,
//                                WKWebsiteDataTypeOfflineWebApplicationCache,
//                                WKWebsiteDataTypeMemoryCache,
////                                WKWebsiteDataTypeLocalStorage,
//    //                            WKWebsiteDataTypeCookies,
//    //                            WKWebsiteDataTypeSessionStorage,
//    //                            WKWebsiteDataTypeIndexedDBDatabases,
//    //                            WKWebsiteDataTypeWebSQLDatabases
//                                ]];
//        //// All kinds of data
//        //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
//        //// Date from
//        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
//        //// Execute
//        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
//            // Done
//        }];
   
});
    
}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    //    Do not call this on Web PDP
    //    [self.webview reload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.edgesForExtendedLayout = UIRectEdgeNone;
    if (IS_IPAD && self.isFromSearchController == false) {
        self.elementTableViewWidth = [MasterConfiguration sharedConfiguration].productCellWidth;
    } else {
        self.elementTableViewWidth = 0.0;
    }
    if(self.isVertical){
        self.elementTableViewWidth = 0;
    }
    
    WKUserContentController* contentController = [[WKUserContentController alloc] init];
//    NSString* scriptToRun = @"var el = document.getElementById('ctl00_header_divHeaderContainer'); if (el) el.parentNode.removeChild(el);";
//    NSString* scriptToRun = @"var el = document.getElementById('header'); if (el) el.parentNode.removeChild(el);";
    
    //    This script works for lumber liquidators
//    NSString* scriptToRun = @"var el = document.getElementsByClassName('head')[0]; if (el) el.parentNode.removeChild(el);var el = document.getElementsByClassName('nav-bar-inner')[0]; if (el) el.parentNode.removeChild(el);var el = document.getElementsByClassName('Header')[0]; if (el) el.parentNode.removeChild(el);";
    
    
    NSString* scriptToRun = @"var el = document.getElementById('masthead'); if (el) el.parentNode.removeChild(el); var el = document.getElementsByClassName('nav')[0]; if (el) el.parentNode.removeChild(el);";
    
    WKUserScript* script = [[WKUserScript alloc] initWithSource:scriptToRun injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:false];
    [contentController addUserScript:script];
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    [config setUserContentController:contentController];
    MasterConfiguration* mConfig = [MasterConfiguration sharedConfiguration];
    WKProcessPool* gPool = mConfig.globalProcessPool;
    [config setProcessPool:gPool];
    
    //    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    self.webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];
    self.webview.navigationDelegate = self;
    self.webview.UIDelegate = self;
    [self.view addSubview:self.webview];
    
    [self.webview mas_makeConstraints:^(MASConstraintMaker* make){
        make.top.bottom.right.equalTo(self.view);
        make.left.equalTo(@(self.elementTableViewWidth));
    }];
    
    
    [NSTimer scheduledTimerWithTimeInterval:2.0
                                     target:self
                                   selector:@selector(lookForCookies:)
                                   userInfo:nil
                                    repeats:NO];
    
}


-(void)lookForCookies:(id)sender{
    
    
    NSHTTPCookieStorage * k = [NSHTTPCookieStorage sharedHTTPCookieStorage];
    for (NSHTTPCookie *cookie in [k cookies])
    {
        NSLog(@"%@",cookie);
    }
    NSLog(@"THE COOKIES:%@",k);
}

#pragma mark - Navigation Methods

- (void)setUpGsestureRecognizer{
    UITapGestureRecognizer *removeViewTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(removeAsPushedViewControllerWithoutNavigationController)];
    
    removeViewTap.delegate = self;
    [self.webview.scrollView addGestureRecognizer:removeViewTap];
}
- (void)removeAsPushedViewControllerWithoutNavigationController{
    [self dismissViewControllerAnimated:YES completion:^{}];
}

- (void)setUpBackAction{
    
    if(self.delegate){
        
        [self.navigationItem setHidesBackButton:YES animated:YES];
        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction)];
        
        self.navigationItem.leftBarButtonItem = backButton;
    }
}

- (void)backAction {
    if (self.delegate) {
        [self.delegate didRequestDismissalFromWebNavigationController:self];
    }
}


#pragma mark - Reloading the Product

- (void)reloadDetailViewWithProductGroupModel:(ProductGroupModel*)productGroupModel andVariantIndex:(NSUInteger)ndx {
    NSURL* u = productGroupModel.url1;
    u = productGroupModel.url1_tracking;
    NSURLRequest* req = [NSURLRequest requestWithURL:u];
    self.request = req;
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.webview loadRequest:self.request];
    });
}

#pragma mark - UIGestureRecognizerDelegate method
- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer
shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer{
    // [self removeAsPushedViewControllerWithoutNavigationController];
    return true;
}

#pragma mark - WKNavigationDelegate

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self.indicatorView startAnimating];
}

- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(nonnull WKNavigationAction *)navigationAction decisionHandler:(nonnull void (^)(WKNavigationActionPolicy))decisionHandler{
    
    NSURL *url = navigationAction.request.URL;
    NSString *urlString = (url) ? url.absoluteString : @"";
    
    // iTunes: App Store link
    if ([urlString containsString:@"itunes.apple.com"]) {
        [self.navigationController popViewControllerAnimated:false];
        [[UIApplication sharedApplication] openURL:url];
        decisionHandler(WKNavigationActionPolicyCancel);
        return;
    }
    
    decisionHandler(WKNavigationActionPolicyAllow);
    
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self.indicatorView stopAnimating];
    
    [webView evaluateJavaScript:@"document.cookie;" completionHandler:^(NSString *result, NSError *error)
     {
         NSLog(@"Error getting cookies: %@",error);
         NSLog(@"result:%@",result);
     }];
    
}


-(void)didPressBackButton{
    dispatch_async(dispatch_get_main_queue(), ^{
    [self.navigationController popViewControllerAnimated:YES];
    });
}


#pragma mark - Navigation Items

- (void)setNavigationItems {
    
    UIView* titleView = [[MasterConfiguration sharedConfiguration] navigationBarTitleView];
    
    //Add a custom image hamburger button
    UIImage *backuttonImage = [Icons sharedIcons].backButtonImage();
    UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [backButton setBackgroundImage:backuttonImage forState:UIControlStateNormal];
    [backButton addTarget:self action:@selector(didPressBackButton) forControlEvents:UIControlEventTouchUpInside];
    backButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem* hamBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
    
    
    self.navigationItem.leftBarButtonItem = hamBarButton;
    self.navigationItem.titleView = titleView;
    
}



#pragma mark - Sharing

- (void)shareProduct {
    ShareProxy* shareProxy = [[ShareProxy sharedProxy] newShareProxy];
    // ProductEntityModel* pm = [MasterConfiguration choose:self.productDetailView.selectedProduct or:self.productGroupModel];
    
    NSArray* items = @[];
    
    // self.shareProxy = shareProxy;
    
    // if(_pageModel){
    items = [shareProxy itemsFromShareable:self.productGroupModel];
    self.shareViewController = [shareProxy newShareViewControllerWithItems:items];
    // }
    
    if (IS_IPAD) {
        self.popOverController = [[UIPopoverController alloc] initWithContentViewController:self.shareViewController];
        self.popOverController.delegate = self;
        [self.popOverController presentPopoverFromBarButtonItem:self.shareRightBarButton
                                       permittedArrowDirections:UIPopoverArrowDirectionUp animated:YES];
    } else {
        [self.navigationController presentViewController:self.shareViewController animated:YES completion:^{ }];
    }
}

@end
