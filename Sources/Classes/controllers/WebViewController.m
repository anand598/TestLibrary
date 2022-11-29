//
//  WebViewController.m
//  Nordstrom
//
//  Created by Schell Scivally on 12/21/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "WebViewController.h"
#import <Masonry/Masonry.h>
#import "SyndecaRevealViewController.h"
#import "Icons.h"
#import "NLS.h"
#import "Fonts.h"
#import "MasterConfiguration.h"
#import "SearchViewController.h"
#import "FIRTrackProxy.h"

@interface WebViewController () <UIGestureRecognizerDelegate>
@property (readwrite) WKWebView* webview;
@property (readwrite) NSURLRequest* request;
@end

@implementation WebViewController

- (id)initWithRequest:(NSURLRequest *)request {
    self = [super init];
    if (self) {
        self.request = request;
    }
    return self;
}

- (void)loadView {

    self.indicatorView = [[UIActivityIndicatorView alloc]
                          initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];

    WKUserContentController* contentController = [[WKUserContentController alloc] init];

    if (self.clientScript != nil && ![self.clientScript isEqualToString:@""]) {
        WKUserScript* script = [[WKUserScript alloc] initWithSource:self.clientScript injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:false];
        [contentController addUserScript:script];
    }
    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    [config setUserContentController:contentController];

    MasterConfiguration* mConfig = [MasterConfiguration sharedConfiguration];
    WKProcessPool* gPool = mConfig.globalProcessPool;
    [config setProcessPool:gPool];

    //    WKWebViewConfiguration* config = [[WKWebViewConfiguration alloc] init];
    self.webview = [[WKWebView alloc] initWithFrame:CGRectZero configuration:config];

    self.webview.navigationDelegate = self;
    self.webview.UIDelegate = self;
    self.view = self.webview;

    //    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemUndo target:self action:@selector(didTapOnView)];


    dispatch_async(dispatch_get_main_queue(), ^{
        //        NSSet *websiteDataTypes
        //        = [NSSet setWithArray:@[
        //                                WKWebsiteDataTypeDiskCache,
        //                                WKWebsiteDataTypeOfflineWebApplicationCache,
        //                                WKWebsiteDataTypeMemoryCache,
        //                                //                                WKWebsiteDataTypeLocalStorage,
        //                                //                            WKWebsiteDataTypeCookies,
        //                                //                            WKWebsiteDataTypeSessionStorage,
        //                                //                            WKWebsiteDataTypeIndexedDBDatabases,
        //                                //                            WKWebsiteDataTypeWebSQLDatabases
        //                                ]];
        //        //// All kinds of data
        //        //NSSet *websiteDataTypes = [WKWebsiteDataStore allWebsiteDataTypes];
        //        //// Date from
        //        NSDate *dateFrom = [NSDate dateWithTimeIntervalSince1970:0];
        //        //// Execute
        //        [[WKWebsiteDataStore defaultDataStore] removeDataOfTypes:websiteDataTypes modifiedSince:dateFrom completionHandler:^{
        //            // Done
        //        }];
        [self.webview loadRequest:self.request];


//        wkWebView.evaluateJavaScript("document.body.innerHTML", completionHandler: { (value: Any!, error: Error!) -> Void in
//
//            if error != nil {
//                //Error logic
//                return
//            }
//
//            //let result = value as? String
//            //Main logic
//        })

    });

    [[FIRTrackProxy sharedProxy] trackLinkClick:self.request.URL.absoluteString];

//    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, 10 * NSEC_PER_SEC);
//        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
//            NSString* runScript = @"document.body.innerHTML";
//            [self.webview evaluateJavaScript:runScript completionHandler:^(id result, NSError *error) {
//                if (error == nil) {
//                    if (result != nil) {
//                        NSLog(@"html value : %@", result);
//                    }
//                } else {
//                    NSLog(@"evaluateJavaScript error : %@", error.localizedDescription);
//                }
//            }];
//        });




}

- (void)viewWillAppear:(BOOL)animated {

    dispatch_async(dispatch_get_main_queue(), ^{

    });
    [self setNavigationItems];
//    [self.webview reload];

//    Reload the original request, this helps us re-direct to the original URL if it has been navigated away from.
    if(self.shouldReloadOnViewDidAppear == true){
        [self.webview loadRequest:self.request];
    }

    if(self.isFromHamburgerMenu == true){
        UIImage *backuttonImage = [Icons sharedIcons].removeFromDiskImage();
        UIImageView* imageView = [[UIImageView alloc] initWithImage:backuttonImage];
        [self.webview addSubview:imageView];
        [imageView mas_remakeConstraints:^(MASConstraintMaker *make) {
            make.left.equalTo(@(20));
            make.top.equalTo(@(20));
            make.width.height.equalTo(@(40));
        }];
        UITapGestureRecognizer* toggleTap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressBackButton)];
        [imageView addGestureRecognizer:toggleTap];
        [imageView setUserInteractionEnabled:true];

    }


//    This break the LL floor visualizer

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];

//    [self.webview reload];
}

- (void)viewDidLoad {
    [super viewDidLoad];

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

//
//    if(self.delegate){
//
//        [self.navigationItem setHidesBackButton:YES animated:YES];
//        UIBarButtonItem* backButton = [[UIBarButtonItem alloc] initWithTitle:@"Back" style:UIBarButtonItemStyleBordered target:self action:@selector(backAction)];
//
//        self.navigationItem.leftBarButtonItem = backButton;
//    }
}

- (void)backAction {
    if (self.delegate) {
        [self.delegate didRequestDismissalFromWebNavigationController:self];
    }
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



- (WKWebView *)webView:(WKWebView *)webView createWebViewWithConfiguration:(WKWebViewConfiguration *)configuration forNavigationAction:(WKNavigationAction *)navigationAction windowFeatures:(WKWindowFeatures *)windowFeatures
{
      if (!navigationAction.targetFrame.isMainFrame) {
        [webView loadRequest:navigationAction.request];
      }

      return nil;
}

-(void)didPressBackButton{

    if(self.isFromScanView == true){
         if (self.scanShopDelegate) {
             [self.scanShopDelegate didDismissResultsController:self];
             [self dismissViewControllerAnimated:YES completion: ^{
             }];
         }
        return;
    }

    if(self.isFromHamburgerMenu == true){
        [self dismissViewControllerAnimated:YES completion: ^{
                    }];
        return;
    }
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - Navigation Items

- (void)setNavigationItems {



    NSArray* rightItems = @[];
    UIImage *searchImage = [Icons sharedIcons].searchIconImage();
    UIBarButtonItem *search = [[UIBarButtonItem alloc] initWithImage:searchImage style:UIBarButtonItemStylePlain target:self action:@selector(showSearch:)];
    [search setImageInsets:UIEdgeInsetsMake(4, 4, 4, 4)];
    UIBarButtonItem* indicator = [[UIBarButtonItem alloc] initWithCustomView:self.indicatorView];
//    rightItems = [rightItems arrayByAddingObject:search];
    rightItems = [rightItems arrayByAddingObject:indicator];

    UIView* titleView = [[MasterConfiguration sharedConfiguration] navigationBarTitleView];


    //Add a custom image hamburger button
    UIImage *hamButtonImage = [Icons sharedIcons].hamburgerMenuImage();
    UIButton* hamButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
    [hamButton setBackgroundImage:hamButtonImage forState:UIControlStateNormal];
    [hamButton addTarget:self.delegate action:@selector(revealToggle:) forControlEvents:UIControlEventTouchUpInside];
    hamButton.adjustsImageWhenHighlighted = NO;
    UIBarButtonItem* hamBarButton = [[UIBarButtonItem alloc] initWithCustomView:hamButton];

    UIBarButtonItem* leftBarButton = hamBarButton;

    if(self.shouldShowBackButton){
        //Add a custom image hamburger button

        UIImage *backuttonImage = [Icons sharedIcons].backButtonImage();
        UIButton* backButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 28, 28)];
        [backButton setBackgroundImage:backuttonImage forState:UIControlStateNormal];
        [backButton addTarget:self action:@selector(didPressBackButton) forControlEvents:UIControlEventTouchUpInside];
        backButton.adjustsImageWhenHighlighted = NO;
        UIBarButtonItem* hamBarButton = [[UIBarButtonItem alloc] initWithCustomView:backButton];
        leftBarButton = hamBarButton;

    } else {

    }


    dispatch_async(dispatch_get_main_queue(), ^{

        if(self.isFromMoreView == true){

        } else{
            self.navigationItem.leftBarButtonItem = leftBarButton;
        }
        self.navigationItem.titleView = titleView;
        self.navigationItem.rightBarButtonItems = rightItems;
    });
}

#pragma mark - Search

- (UITextField*)newSearchField {

    CGFloat width = self.view.frame.size.width - 80 - 20;
    UITextField* t = [[UITextField alloc] initWithFrame:CGRectMake(0, 0, width, 32)];
    t.tag = [@"search text" hash];
    t.font = [Fonts fontType:FontTypeNormalLight withSize:FontSizeBig];
    t.font = [UIFont fontWithName:[Fonts fontType:FontTypeNormalLight withSize:FontSizeMedium].fontName size:([Fonts fontType:FontTypeNormalLight withSize:FontSizeMedium].pointSize + 4)];
    t.text = @"Search for Products";
    t.textColor = [UIColor colorWithRed:(212.0/255.0) green:(212.0/255.0) blue:(212.0/255.0) alpha:1.0];
    t.keyboardType = UIKeyboardTypeDefault;

    t.leftViewMode = UITextFieldViewModeAlways;
    UIImage *searchIcon = [Icons sharedIcons].searchIconImage();
    UIImageView* leftView = [[UIImageView alloc] initWithImage:searchIcon];
    leftView.frame = CGRectMake(0.0, 0.0, leftView.image.size.width+10.0, leftView.image.size.height);
    leftView.contentMode = UIViewContentModeScaleAspectFit;
    t.leftView = leftView;

    t.clearButtonMode = UITextFieldViewModeWhileEditing;

    t.backgroundColor = [UIColor whiteColor];
    t.layer.borderColor = [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1]
                           CGColor];
    t.layer.borderWidth = 1;
    t.layer.cornerRadius = 4;
    return t;
}

- (UIBarButtonItem*)newSearchItem {
    return [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemSearch
                                                         target:self
                                                         action:@selector(startSearch:)];
}

- (void)showSearch:(id)sender {
    UITextField* searchField = [self newSearchField];
    searchField.delegate = self;
    UIBarButtonItem* searchItem = [self newSearchItem];



    UIBarButtonItem* space = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
                                                                           target:nil
                                                                           action:nil];
    UIBarButtonItem* search = [[UIBarButtonItem alloc] initWithCustomView:searchField];

    UIBarButtonItem* cancel = [[UIBarButtonItem alloc] initWithTitle:[[NLS nls] stringFor:@"share.cancelText" default:@"Cancel"]
                                                               style:UIBarButtonItemStyleDone
                                                              target:self action:@selector(cancel:)];
    [cancel setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                    [UIFont fontWithName:@"Helvetica-Light" size:18.0], NSFontAttributeName,
                                     [MasterConfiguration sharedConfiguration].cancelButtonColor, NSForegroundColorAttributeName,
                                    nil]
                          forState:UIControlStateNormal];

    self.navigationItem.titleView = nil;
    self.navigationItem.leftBarButtonItems = nil;
    self.navigationItem.rightBarButtonItems = nil;

    [self.navigationItem setLeftBarButtonItems:@[search, space] animated:YES];
    [self.navigationItem setRightBarButtonItem:cancel animated:YES];
}

#pragma mark - Setters and Getters
    /*
-(void)setShouldShowBackButton:(BOOL)shouldShowBackButton{
//    if(shouldShowBackButton == true){
//        NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle mainBundle] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
//        UIImage *backButtonImage = [UIImage imageNamed:@"backArrow.png" inBundle:bundle compatibleWithTraitCollection:nil];
//        UIImageView* backButtonImageView = [[UIImageView alloc] initWithImage:backButtonImage];
//        [backButtonImageView addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(didPressBackButton)]];
//        UIBarButtonItem* back = [[UIBarButtonItem alloc] initWithCustomView:backButtonImageView];
//        self.navigationController.navigationItem.leftBarButtonItem = back;
//
//    }

}
*/

#pragma mark - Text Input
-(void)textFieldDidBeginEditing:(UITextField *)textField{
    if([textField.text isEqualToString:@"Search for Products"]){
        textField.text = @"";
        textField.textColor = [UIColor colorWithRed:(120.0/255.0) green:(120.0/255.0) blue:(120.0/255.0) alpha:1.0];
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField {
    [self openSearchControllerWithString:textField.text];
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
    [textField resignFirstResponder];
    return YES;
}

-(void)openSearchControllerWithString:(NSString*)string{
    if([string  isEqual: @""]){
        [self setNavigationItems];
        return;
    }
//    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
//    layout.itemSize = CGSizeMake(100, 200);
//    layout.minimumLineSpacing = 5;
//    layout.minimumInteritemSpacing = 5;
//    SearchViewController* c = [[SearchViewController alloc] initWithCollectionViewLayout:layout];
//    IssueModel* issue = self.guideModel.issueModels.firstObject;
//    ItemSelection* selection = [[ItemSelection alloc] init];
//    selection.selection = issue;
//    selection.selectionType = ItemSelectionTypeIssue;
//
//    RACSignal* loading = [[FetchProxy fetchCatalogModelUsingIssueModel:issue] deliverOn:[RACScheduler mainThreadScheduler]];
//    [loading subscribeNext:^(CatalogModel* catalogModel) {
//        c.catalog = catalogModel;
//        [c searchWithText:string inCatalog:c.catalog];
//        c.productDetailViewDelegate = self;
//        c.itemSelectionDelegate = self;
//        c.searchViewControllerDelegate = self;
//        UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:c];
//        [self completionhandler_pushViewController:c animated:YES completion:^{
//            [self setNavigationItems];
//        }];
//    }];
}

- (void)cancel:(id)sender{
    [self setNavigationItems];
}


@end
