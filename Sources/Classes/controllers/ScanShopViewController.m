//
//  ScanShopViewController.m
//  Syndeca iOS Apps
//
//  Created by Kurt Guenther.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "ScanShopViewController.h"
#import <AVFoundation/AVFoundation.h>
#import <AudioToolbox/AudioServices.h>
#import <Vision/Vision.h>
#import "AFNetworking.h"
#import "AFURLRequestSerialization.h"
#import "AFURLResponseSerialization.h"
#import <Masonry/Masonry.h>
#import "DefaultAppDelegate.h"
#import "WebViewController.h"
#import "MasterConfiguration.h"
#import "Fonts.h"
#import "SyndecaService.h"
#import "FetchProxy.h"
#import "ScanInterstitialView.h"
#import "ScanCameraView.h"
#import "ScanShopResultsViewController.h"
#import "Icons.h"
#import "UIViewHelper.h"
#import "UIImage+SyndecaSDK.h"
#import "FIRTrackProxy.h"
#import <CraftARCloudImageRecognitionSDK/CraftARQueryImage.h>
#import <CraftARCloudImageRecognitionSDK/CraftArSDK.h>
#import <CraftARCloudImageRecognitionSDK/CraftARCloudRecognition.h>

typedef NS_ENUM(NSInteger, ScanShopMode){
    ScanShopModeInterstitial = 0,
    ScanShopModeCamera = 1,
    ScanShopModeResults
};

//Set up our local variables
@interface ScanShopViewController () {
    CraftARSDK *_sdk;
    CraftARCloudRecognition *_crs;
    bool _captureStarted;
    bool _hasStartedStopTimer;
    float scanRate;
    int timeToShowInterstitial;
    int timeToEndInterstitial;
    bool _shouldSearchForCraftARResult;
    bool _shouldSearchForBarcodes;
}

@property (nonatomic) ScanShopMode mode;
@property (readwrite) BOOL isScanning;
@property (readwrite) BOOL scannerSyncd;

@property (readwrite) BOOL isOnClickToScan;
@property (readwrite) BOOL hasFinishedSnapInstructionsScreen;
@property (readwrite) NSTimer *stopContinuousScanTimer;
@property (readwrite) NSTimer *resetShouldScanBoolTimer;
@property (readwrite) UIView *snapPhotoInstructionsView;

@end

NSString* const ScanShopHasDismissedInterstitalKey = @"ScanShopHasDismissedInterstitalKey";

@implementation ScanShopViewController

SYNTHESIZE_DI


#pragma mark - Class methods

static NSString* __apiKey = nil;
+ (void)setScanShopAPIKey:(NSString *)key {
    __apiKey = key;
}

static NSString* __apiSecret = nil;
+ (void)setScanShopAPISecret:(NSString *)secret {
    __apiSecret = secret;
}

static NSString* __apiToken = nil;
+ (void)setScanShopToken:(NSString *)token{
    __apiToken = token;
}

#pragma mark - Instance methods

- (id)init {
    self = [super init];
    if (self) {
        //Set up the craftar cloud recognition with our token that was set from config
        [[CraftARCloudRecognition sharedCloudImageRecognition] setCollectionWithToken:[self scanShopToken] onSuccess:^{
            NSLog(@"Token set!!");
        } andOnError:^(NSError *error) {
            NSLog(@"Error: %@", error);
        }];
        
        [self restart];
    }
    
    return self;
}

- (void)restart {
    self.recognitionDelegate = self;
    
    self.automaticallyHandleProductVideoAndExternalLinks = YES;
    self.isScanning = NO;
    self.isOnClickToScan = NO;
    self.hasFinishedSnapInstructionsScreen = NO;
    
    self.cameraInputView = [[[ScanCameraView DIClass] alloc] initWithFrame:CGRectZero];
    self.cameraInputView.alpha = 0;
    [[self.cameraInputView getInfoButton] addTarget:self action:@selector(showFAQ:) forControlEvents:UIControlEventTouchUpInside];
    
    self.interstitialView = [[[ScanInterstitialView DIClass] alloc] initWithFrame:CGRectZero];
    self.interstitialView.alpha = 0;
    [self.interstitialView.goButton addTarget:self action:@selector(testCameraPermissionAndShowAlert:) forControlEvents:UIControlEventTouchUpInside];
    
    //catachoom views
    self._preview = [[UIView alloc] initWithFrame:CGRectZero];
    __preview.backgroundColor = [UIColor blackColor];
    
    //set the search rate
    scanRate = [[MasterConfiguration sharedConfiguration] scanRate];
    //set the timer intervals
    timeToShowInterstitial = [[MasterConfiguration sharedConfiguration] interstitialTimeToShow];
    timeToEndInterstitial = [[MasterConfiguration sharedConfiguration] interstitialTimeToHide];
    
    //set the search bool
    _shouldSearchForCraftARResult = true;
    _shouldSearchForBarcodes = true;
    
    self.toolbarItems = [[MasterConfiguration sharedConfiguration] toolbarItems];
    self.tabBarItem.image = [Icons sharedIcons].cameraButtonImage();
    self.tabBarItem.title = @"Scan";
    
    //init the snap photo instructions view
    self.snapPhotoInstructionsView = [self stopContinuousScanView];
}

#pragma mark Go Button

- (void)goToCamera:(id)sender {
    self.mode = ScanShopModeCamera;
    // We have to dispatch this because `startCapture` must run from the main thread
    dispatch_async(dispatch_get_main_queue(), ^{
        [self startCapture];
    });
    //If we're not debugging in xcode save that the user has done this action so we never present the interstitial again.
    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:ScanShopHasDismissedInterstitalKey];
}

#pragma mark Info
- (void)showFAQ:(id)sender {
    [self.cameraInputView didSelectInfo];
}

- (void)didRequestDismissalFromWebNavigationController:(WebNavigationController *)controller {
    [self dismissViewControllerAnimated:YES completion:^{}];
}

#pragma mark Mode

- (void)setMode:(ScanShopMode)mode {
    _mode = mode;
    switch (mode) {
        case ScanShopModeCamera:{
            
            dispatch_async(dispatch_get_main_queue(), ^{
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.cameraInputView.alpha = 1;
                self.interstitialView.alpha = 0;
            } completion:^(BOOL finished) { }];
            });
            
            break;
        }
        case ScanShopModeInterstitial:{
            [UIView animateWithDuration:0.5 delay:0 options:UIViewAnimationOptionBeginFromCurrentState animations:^{
                self.interstitialView.alpha = 1;
                self.cameraInputView.alpha = 0;
            } completion:^(BOOL finished) { }];
            break;
        }
        default:
            break;
    }
}

#pragma mark - Catchoom Pixel Buffer
- (void) didReceivePreviewFrame: (VideoFrame*) image{
    CraftARQueryImage* searchImage = [[CraftARQueryImage alloc] initWithVideoFrame:image];
    if(_shouldSearchForCraftARResult == true){
        NSLog(@"Frame Captured");
        //search the new result for a craft ar result
        _shouldSearchForCraftARResult = false;
        
        //if we're not on click to scan, we reset the bool after the scan rate to automatically scan again
        if(self.isOnClickToScan == NO){
            
            dispatch_async(dispatch_get_main_queue(), ^{
                self.resetShouldScanBoolTimer = [NSTimer scheduledTimerWithTimeInterval:scanRate
                                                                                 target:self
                                                                               selector:@selector(resetShouldScanBool)
                                                                               userInfo:nil
                                                                                repeats:NO];
            });
        }
        [self testImageForCraftARResult:searchImage];
    }
    
    if(_shouldSearchForBarcodes == true){
        _shouldSearchForBarcodes = false;
        //get a UIImage from the craftar image
        
        UIImage* testImage = [searchImage getUIImage];
        //test this image for bar and qr codes
        [self testImageForBarcodeResult:testImage];
    }
}

//We reset the scan bool in certain instances
-(void)resetShouldScanBool{
    _shouldSearchForCraftARResult = true;
}

//We test a craftar image object for results or errors
//This is called from onPreviewFrame - either automatically or on a button press
-(void)testImageForCraftARResult:(CraftARQueryImage*)image {
    if(image == nil) {
        return;
    }
    UIImage* innerImage = [image getUIImage];
    CGImageRef cg = CGImageCreateCopy([innerImage CGImage]);
    UIImage* copyImage = [UIImage imageWithCGImage:cg];
    CraftARQueryImage* query = [[CraftARQueryImage alloc] initWithUIImage:copyImage];
    [_crs
     searchWithImage:query
     withOnResults:^(NSArray *results){//if we get results
        [self didGetSearchResults:results];
     }
     andOnError:^(NSError *error){//if there's an error
        [self didFailSearchWithError:error];
     }];
}

//We parse the results from the image search function
- (void)didGetSearchResults:(NSArray *)results {
    // the finder has already been stopped by setting _shouldSearchForCraftARResult = false;
    if ([results count] >= 1) {
        // Found one item, launch its content on a webView:
        CraftARSearchResult* result = [results objectAtIndex:0];
        //we get the item from the result
        CraftARItem *item = result.item;
        //We get the url to the custom json object
        NSString *requestUrl = item.custom;
        
        //we need to load the json objet from the item url
        [self loadCraftDataFromJsonURL:requestUrl andCompletion:^(BOOL success, NSString *catalogId, NSString *pageId) {
            //if the requet was successful
            if(success == true){
                //we stop the reset timer because we don't need to search any more
                [self.resetShouldScanBoolTimer invalidate];
                self.resetShouldScanBoolTimer = nil;
                
                //vibrate the device when we recognize the image
                AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                self.hasShownResult = true;
                
                [self.recognitionDelegate didRecognizeCatalog:catalogId andPage:pageId];
                
            }
            else{//we should present an error alert
                
            }
            
        }];
        return;
    } else {//there are no items found
        //if we're not on search to scan, we don't do anything. The timer is set to reset the scan bool in the onPreviewFrame method
        if(self.isOnClickToScan == NO){
            //  self._scanningOverlay.hidden = NO;
            //   [self._scanningOverlay setNeedsDisplay];
            //  [self customStartFinder];
        }
        else{//we should show an alert saying that nothing is found
            //but first,
            //we want to make sure the scanner isn't on finder mode, and that we have finished showing the instructions
            if(self.hasFinishedSnapInstructionsScreen == YES){//if we're good, we show the alert
                UIAlertView *alert = [[UIAlertView alloc] init];
                [alert setTitle:@"We didn’t recognize this particular lookbook or catalog. Please try again."];
                [alert setDelegate:self];
                [alert addButtonWithTitle:@"OK"];
                [alert show];
                //self._scanningOverlay.hidden = YES;
            }
        }
    }
}

-(void)didFailSearchWithError:(NSError *)error{
    // Check the error type
    NSLog(@"Error calling CRS: %@", [error localizedDescription]);
    if(self.isOnClickToScan == YES){
        // [[_sdk getCamera] restartCapture];
    }
}

//a method to return Syndeca specifc data from a craftar html linking to a custom json object
- (void)loadCraftDataFromJsonURL:(NSString *)requestString andCompletion:(void (^)(BOOL success, NSString *catalogNum, NSString *pageNum))completionBlock{
    NSURLRequest *request = [NSURLRequest requestWithURL:
                             [NSURL URLWithString:requestString]];
    
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    operation.responseSerializer = [AFJSONResponseSerializer serializer];
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if(completionBlock!= nil){
            NSNumber *catalogNumber = [responseObject objectForKey:@"c"];
            NSString *catalogString = [catalogNumber stringValue];

            NSNumber *pageNumber = [responseObject objectForKey:@"n"];
            NSString *pageString = [pageNumber stringValue];

            completionBlock(true, catalogString, pageString);
        }

    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if(completionBlock!= nil){
            completionBlock(true, nil, nil);
        }
    }];
    // start the operation we just set up
    [operation start];
}

-(void)testImageForBarcodeResult:(UIImage*)image{
    NSAssert(image.size.width > 0, @"barcode scan image is zero-width");
    NSAssert(image.size.height > 0, @"barcode scan image is zero-height");
    dispatch_async(dispatch_get_main_queue(), ^{
        VNDetectBarcodesRequest *k =
            [[VNDetectBarcodesRequest alloc]
             initWithCompletionHandler:^(VNRequest * _Nonnull request, NSError * _Nullable error) {
                NSArray* results = request.results;
                if(error != nil) {
                    NSLog(@"%@", error);
                }
                if(results.count == 0){
                    _shouldSearchForBarcodes = true;
                } else {
                     _shouldSearchForBarcodes = false;
                    VNBarcodeObservation *barcode = results.firstObject;
                    NSString *resultURL = barcode.payloadStringValue;
                    BOOL canOpenGivenURL = [[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:resultURL]];
                    
                    //if this url is valid, then we open a webview with this url instead of presenting a catalog view controller
                    if(canOpenGivenURL == true){
                        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                        [self.recognitionDelegate didRecognizeQRCode:resultURL];
                        return;
                    } else if (barcode.symbology == VNBarcodeSymbologyQR) {
                        _shouldSearchForBarcodes = false;
                        self.hasShownResult = false;
                        UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:@"Could Not Read QR Code" message:@"Please make sure this QR code contians a valid url." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
                        [alertView show];
                        return;
                    }
                    
                    //if the result is not a url, then it must be a product id from a barcode
                    AudioServicesPlaySystemSound(kSystemSoundID_Vibrate);
                    [self.recognitionDelegate didRecognizeBarCode:resultURL];
                }
            }];
        
        VNImageRequestHandler *handler =
            [[VNImageRequestHandler alloc]
             initWithCGImage:image.CGImage
             options:@{}];
        NSArray* reqArr = [[NSArray alloc] initWithObjects:k, nil];
        [handler performRequests:reqArr error:nil];
    });
}

//The onPreviewFrame method requires image rotation to optimize the view ratio
- (UIImage *)imageRotatedByDegrees:(UIImage*)oldImage deg:(CGFloat)degrees{
    //Calculate the size of the rotated view's containing box for our drawing space
    
    __block UIImage *newImage;
    dispatch_async(dispatch_get_main_queue(), ^{
        UIView* rotatedViewBox = [[UIView alloc] initWithFrame:CGRectMake(0,0,oldImage.size.width, oldImage.size.height)];
        CGAffineTransform t = CGAffineTransformMakeRotation(degrees * M_PI / 180);
        rotatedViewBox.transform = t;
        CGSize rotatedSize = rotatedViewBox.frame.size;
        
        //Create the bitmap context
        UIGraphicsBeginImageContext(rotatedSize);
        CGContextRef bitmap = UIGraphicsGetCurrentContext();
        
        //Move the origin to the middle of the image so we will rotate and scale around the center.
        CGContextTranslateCTM(bitmap, rotatedSize.width/2, rotatedSize.height/2);
        
        //Rotate the image context
        CGContextRotateCTM(bitmap, (degrees * M_PI / 180));
        
        //Now, draw the rotated/scaled image into the context
        CGContextScaleCTM(bitmap, 1.0, -1.0);
        CGContextDrawImage(bitmap, CGRectMake(-oldImage.size.width / 2, -oldImage.size.height / 2, oldImage.size.width, oldImage.size.height), [oldImage CGImage]);
        
        newImage = UIGraphicsGetImageFromCurrentImageContext();
        UIGraphicsEndImageContext();
    });
    
    
    return newImage;
}

#pragma mark view lifecycle

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    self.view.backgroundColor = [UIColor whiteColor];
    
    self.hasShownResult = false;
    // setup the CraftAR SDK
    _sdk = [CraftARSDK sharedCraftARSDK];
    //set the sdk delegate to this view controller. We should conform to the protocol
    _sdk.delegate = self;

    //We first set the snap photo button to invisible. We'll use this later on
    self.snapPhotoButton.alpha = 0.0;
    //we add the snap photo button
    [self.view addSubview:self.snapPhotoButton];
    //We add the view that shows the camera feed
    [self.view addSubview:__preview];
    
    [self.view addSubview:self.cameraInputView];
    [self.view addSubview:self.interstitialView];
    
    //Preview and Overlay constraints
    void (^constraints)(MASConstraintMaker*) = ^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width);
        make.height.equalTo(self.view.mas_height);
        make.centerX.equalTo(self.view.mas_centerX);
        make.centerY.equalTo(self.view.mas_centerY);
    };
    
    //set the camera preview constraints
    [__preview mas_makeConstraints:constraints];
    
    [self.interstitialView mas_makeConstraints:constraints];
    [self.cameraInputView mas_makeConstraints:constraints];
            
    //snap picture button constraint
    void (^buttonConstraints)(MASConstraintMaker*) = ^(MASConstraintMaker *make) {
        make.width.equalTo(self.view.mas_width).multipliedBy(0.12);
        make.height.equalTo(self.view.mas_width).multipliedBy(0.12);
        make.centerX.equalTo(self.view.mas_centerX);
        make.bottom.equalTo(self.view.mas_bottom).offset(-20.0);
    };
    [self.snapPhotoButton mas_makeConstraints:buttonConstraints];
    
    UIView* titleView = [[MasterConfiguration sharedConfiguration] navigationBarTitleView];
    
    self.navigationItem.titleView = titleView;
    [self.navigationItem.backBarButtonItem setCustomView:titleView];
    
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
        
    if([[NSUserDefaults standardUserDefaults] boolForKey:ScanShopHasDismissedInterstitalKey]){
        self.mode = ScanShopModeCamera;
    } else {
        self.mode = ScanShopModeInterstitial;
    }
    
    //protects the view will appear method when we return from results view controller
    if(self.hasShownResult == true){
        return;
    }
    
    if(self.mode == ScanShopModeCamera){
        _shouldSearchForCraftARResult = true;
        _shouldSearchForBarcodes = true;
        [self startCapture];
    }
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    self.view.backgroundColor = [UIColor redColor];
    NSLog(@"%@", NSStringFromCGRect(self.view.frame));
    self.navigationItem.leftItemsSupplementBackButton = NO;
    UIImage* image = [[Icons sharedIcons].backButtonImage() imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIBarButtonItem* backItem = [[UIBarButtonItem alloc]
                                 initWithImage:image
                                 style:UIBarButtonItemStylePlain
                                 target:self
                                 action:@selector(popMyself:)];
    if (@available(iOS 13.0, *)) {
        [backItem setTintColor:[UIColor labelColor]];
    }
    self.navigationItem.leftBarButtonItem = backItem;
}

- (void)popMyself:(id)thing {
    NSLog(@"should pop");
    [self.navigationController popViewControllerAnimated:true];
}

- (void) viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //this method resets all the booleans and timers
    [self revertToOriginalState];
}

- (void)revertToOriginalState{
    //stop the sdk while we reset
    [_sdk stopCapture];
    
    //invalidate all the timers
    [self.stopContinuousScanTimer invalidate];
    self.stopContinuousScanTimer = nil;
    [self.resetShouldScanBoolTimer invalidate];
    self.resetShouldScanBoolTimer = nil;
    self.hasFinishedSnapInstructionsScreen = NO;
    [self.cameraInputView resetViewToNormal];
    
    //reset relevant booleans to their original state
    _hasStartedStopTimer = false;
    _shouldSearchForCraftARResult = true;
    _shouldSearchForBarcodes = true;
    
    //if we have started the transition to click to scan
    if(self.isOnClickToScan == YES){
        //we immediately set this to no, this will make sure the instructions methods don't get called
        self.isOnClickToScan = NO;
        //check if our snap photo instructions view is on our view
        if([self.snapPhotoInstructionsView isDescendantOfView:self.view] == true){
            //we remove this view
            [self.snapPhotoInstructionsView removeFromSuperview];
        }
    }
}

- (void)testCameraPermissionAndShowAlert:(id)sender {
    if([[AVCaptureDevice class] respondsToSelector:@selector(authorizationStatusForMediaType:)]){
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        if(status == AVAuthorizationStatusDenied){
            dispatch_async(dispatch_get_main_queue(), ^{
            UIAlertView* alertView = [[UIAlertView alloc] initWithTitle:nil message:@"Please give this app permission to access your device's camera in your settings!" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
            [alertView show];
            });
            return;
        }
        else if(status == AVAuthorizationStatusNotDetermined)
        {
            NSLog(@"%@", @"Camera access not determined. Ask for permission.");
            
            [AVCaptureDevice requestAccessForMediaType:AVMediaTypeVideo completionHandler:^(BOOL granted) {
                if(granted){
                    NSLog(@"Granted access to %@", AVMediaTypeVideo);
                    [self testCameraPermissionAndShowAlert:sender];
                } else {
                    NSLog(@"Not granted access to %@", AVMediaTypeVideo);
                    [self testCameraPermissionAndShowAlert:sender];
                }
            }];
                    return;
        }
    }
    
    [self goToCamera:sender];
}

#pragma mark Orientation changes
- (void)viewWillLayoutSubviews {
    [self updateInterfaceOrientation:self.interfaceOrientation];
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)orientation duration:(NSTimeInterval)duration {
    [super willAnimateRotationToInterfaceOrientation:orientation duration:duration];
    [self updateInterfaceOrientation:orientation];
}

- (void)updateInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    //    [self.scannerSession setInterfaceOrientation:interfaceOrientation];
    
    //    AVCaptureVideoPreviewLayer *captureLayer = (AVCaptureVideoPreviewLayer *) [self.scannerSession captureLayer];
    
    //    captureLayer.frame = self.view.bounds;
    
    // AVCapture orientation is the same as UIInterfaceOrientation
    //    switch (interfaceOrientation) {
    //        case UIInterfaceOrientationPortrait:
    //            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortrait];
    //            break;
    //        case UIInterfaceOrientationPortraitUpsideDown:
    //            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationPortraitUpsideDown];
    //            break;
    //        case UIInterfaceOrientationLandscapeLeft:
    //            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeLeft];
    //            break;
    //        case UIInterfaceOrientationLandscapeRight:
    //            [[captureLayer connection] setVideoOrientation:AVCaptureVideoOrientationLandscapeRight];
    //            break;
    //        default:
    //            break;
    //    }
}

//#pragma mark MSAutoScannerSessionDelegate
//- (void)session:(id)scannerSession didEncounterWarning:(NSString *)warning {
//    NSLog(@"%s %@",__func__, warning);
//    //[[TrackProxy sharedProxy] trackScanError];
//}

//#pragma mark - Handling Results

#pragma mark Displaying Scan Results

- (UIViewController*)loadScanResultsForBarcode:(NSString*)barcode {
    [ProductGroupModel setIsScanAndShop:YES];
    // We need to clear the product cache so that remapping can occur.
    [FetchProxy clearProductModelCache];
    // SYN-339
    // Scan + Shop - Allow archived catalogs to be "Scan and Shopped"
    [SyndecaService sharedService].config.isArchive = YES;
    
    ScanShopResultsViewController* results = [[[ScanShopResultsViewController DIClass] alloc] initWithBarcode:barcode];
    results.handleProductVideoAndExternalLinkSelection = YES;
    results.selectionDelegate = self.selectionDelegate;
    results.delegate = self;
    return results;
}


- (UIViewController*)loadScanResultsForCatalog:(NSString*)catalogID pageNumber:(NSInteger)pageNumber {
    
    [ProductGroupModel setIsScanAndShop:YES];
    // We need to clear the product cache so that remapping can occur.
    [FetchProxy clearProductModelCache];
    
    // Construct a one-off issue model.
    IssueModel* issue = [[IssueModel alloc] init];
    // SYN-339
    // Scan + Shop - Allow archived catalogs to be "Scan and Shopped"
    [SyndecaService sharedService].config.isArchive = YES;
    NSDictionary* info = @{ @"data" : @{ @"catalogID" : catalogID, @"buildNum" : @"" } };
    issue.info = info;
    NSInteger pageNdx = pageNumber - 1;
    
    ScanShopResultsViewController* results = [[[ScanShopResultsViewController DIClass] alloc] initWithCatalog:issue andPageIndex:pageNdx];
    
    results.handleProductVideoAndExternalLinkSelection = self.automaticallyHandleProductVideoAndExternalLinks;
    results.delegate = self;
    results.selectionDelegate = self.selectionDelegate;
    return results;
    
}

#pragma mark User Selection Results Handling

- (void)didDismissResultsController:(id)results {
    self.mode = ScanShopModeCamera;
    self.hasShownResult = NO;
    _shouldSearchForBarcodes = YES;
}

- (void)didSelectResult:(ScanShopResult *)result inResultController:(id)controller {
    if (self.delegate && [self.delegate respondsToSelector:@selector(didSelectResult:inResultController:)]) {
        if (result.resultType == ScanShopResultTypeError) {
            self.mode = ScanShopModeCamera;
            [self dismissViewControllerAnimated:YES completion:^{}];
        } else{
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.delegate didSelectResult:result inResultController:self];
                [self dismissViewControllerAnimated:YES completion:^{
                }];
            });
        }
        
    }
}

#pragma mark - Scan+Shop Credentials

- (NSString*)scanShopAPIKey {
    return __apiKey;
}

- (NSString*)scanShopAPISecret {
    return __apiSecret;
}

- (NSString*)scanShopToken{
    return __apiToken;
}

#pragma mark - Garbage collection

- (void)dealloc {
    //    [self.scannerSession stopRunning];
    self.isScanning = NO;
}



#pragma mark Snap Photo mode implementation

//this called by the CraftAR Delegate
- (void)didStartCapture {
    
    _captureStarted=YES;
    //self._previewOverlay.hidden = NO;
    
    _crs = [CraftARCloudRecognition sharedCloudImageRecognition];
    _crs.delegate = self;
    
    _sdk.searchControllerDelegate = _crs.mSearchController;
    
    [_sdk getCamera].delegate = self;
    self.shouldScanForBarcodes = true;
}

//we call this method during ViewDidAppear to setup the craftar sdk and timers
- (void)startCapture {
    if(![MasterConfiguration sharedConfiguration].shouldShowContinuousScan){
        //this is where we make sure we don't send an error alert if the process of the app automatically scanning and not finding anything started before the timer was called.
        self.hasFinishedSnapInstructionsScreen = YES;
        self.isOnClickToScan = YES;
        [_sdk startCaptureWithView:self._preview];
        
        [self.cameraInputView makeViewsShow];
        [self.cameraInputView makePhotoButtonShow];
        
        [[self.cameraInputView getSnapPhotoButton] addTarget:self action:@selector(snapPhotoToSearch:) forControlEvents:UIControlEventTouchUpInside];
        return;
    }
    
    //if we're on click to scan, we don't need to set up the timer
    if(self.isOnClickToScan == YES){
        return;
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        //we have the sdk start the capture on our preview view
        //we don't need to initiate the other craftar delegate methods because we're manually using the camera pixel buffer to search for images
        [_sdk startCaptureWithView:self._preview];
    });

    //We do want to set up the timer to stop automatic scanning after a set period of time
    if(_hasStartedStopTimer == false){
        _hasStartedStopTimer = true;
        CGFloat time = timeToShowInterstitial;
        self.stopContinuousScanTimer = [NSTimer scheduledTimerWithTimeInterval:time
                                                                        target:self
                                                                      selector:@selector(stopContinuousScan:)
                                                                      userInfo:nil
                                                                       repeats:NO];
    }
    [[FIRTrackProxy sharedProxy] trackScanAttempt];
}


/** Removes camera feed scanning, shows interstitial view, sets up click button to scan photo*/
- (void)stopContinuousScan:(id)sender {
    //the finder may still be finding, but will only present information when the hasFinishedSnapInstructions bool is set to yes.
    self.isOnClickToScan = YES;
    
    dispatch_async(dispatch_get_main_queue(), ^{
        [self.view insertSubview:self.snapPhotoInstructionsView aboveSubview:self.cameraInputView];
        
        void (^constraints)(MASConstraintMaker*) = ^(MASConstraintMaker *make) {
            make.width.equalTo(self.view.mas_width);
            make.height.equalTo(self.view.mas_height);
            make.centerX.equalTo(self.view.mas_centerX);
            make.centerY.equalTo(self.view.mas_centerY);
        };
        
        [self.snapPhotoInstructionsView mas_makeConstraints:constraints];
        
        [UIView animateWithDuration:0.2 animations:^{
            [self.snapPhotoInstructionsView setAlpha:1.0];
            [self.cameraInputView makeViewsTransparent];
        } completion:^(BOOL finished){
            [self performSelector:@selector(setUpClickToScan:)
                       withObject:self.snapPhotoInstructionsView
                       afterDelay:timeToEndInterstitial];
        }];
    });
}

- (void)setUpClickToScanContinueButton:(id)sender{
    dispatch_async(dispatch_get_main_queue(), ^{
    UIView* interstitialInfoBackground = [sender superview];
    UIView* parentView = [interstitialInfoBackground superview];
    
    [self setUpClickToScan:parentView];
    });
}

- (void)setUpClickToScan:(UIView*)view {
    dispatch_async(dispatch_get_main_queue(), ^{
    //this will be no if the user has clicked to a different screen during the instructions dialoge
    if(self.isOnClickToScan == NO){
        return;
    }
    
    [UIView animateWithDuration:0.2 animations:^{
        [view setAlpha:0.0];
        [self.cameraInputView makeViewsShow];
        [self.cameraInputView makePhotoButtonShow];
        
    } completion:^(BOOL finished){
        
        [view removeFromSuperview];
        
        //this is where we make sure we don't send an error alert if the process of the app automatically scanning and not finding anything started before the timer was called.
        self.hasFinishedSnapInstructionsScreen = YES;
        
        [[self.cameraInputView getSnapPhotoButton] addTarget:self action:@selector(snapPhotoToSearch:) forControlEvents:UIControlEventTouchUpInside];
        
    }];
    });
    
}

//We generate an interstitial view
//This view has a lable telling the user we haven't found anything. We also tell them they'll now have to press a button to search.
//This interstitial disapears about a set amount of time.
- (UIView*)stopContinuousScanView {
    Fonts* fonts = [Fonts fonts];
    
    
    
    MasterConfiguration* config = [MasterConfiguration sharedConfiguration];
    
    
    
    UIView *optionsView = [[UIView alloc] initWithFrame:CGRectZero];
    optionsView.alpha = 0;
    
    //
    //    if (!UIAccessibilityIsReduceTransparencyEnabled()) {
    //        self.view.backgroundColor = [UIColor clearColor];
    //
    //        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    //        UIVisualEffectView *blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    //        blurEffectView.frame = self.view.bounds;
    //        blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    //
    //        [optionsView addSubview:blurEffectView];
    //    } else {
    //        optionsView.backgroundColor = [UIColor blackColor];
    //    }
    //
    //
    //
    //    NSString *label1String = [[MasterConfiguration sharedConfiguration] snapPhotoDialogue1];
    //    NSString *label2String = [[MasterConfiguration sharedConfiguration] snapPhotoDialogue2];
    //
    //
    //    UILabel *label1 = [[UILabel alloc] init];
    //    [label1 setFont:[[MasterConfiguration sharedConfiguration] scanInterstitialLabelFont]];
    //    [label1 setTextColor:[UIColor whiteColor]];
    //    [label1 setTextAlignment:NSTextAlignmentCenter];
    //    [label1 setText:label1String];
    //    [label1 setNumberOfLines:0];
    //    [optionsView addSubview:label1];
    //
    //    UILabel *label2 = [[UILabel alloc] init];
    //    [label2 setFont:[[MasterConfiguration sharedConfiguration] scanInterstitialLabelFont]];
    //    [label2 setTextColor:[UIColor whiteColor]];
    //    [label2 setTextAlignment:NSTextAlignmentCenter];
    //    [label2 setText:label2String];
    //    [label2 setNumberOfLines:0];
    //    [optionsView addSubview:label2];
    //
    //    if(IS_IPAD){
    //        [label1 setFont:[[MasterConfiguration sharedConfiguration] scanInterstitialLabelFontiPad]];
    //        [label2 setFont:[[MasterConfiguration sharedConfiguration] scanInterstitialLabelFontiPad]];
    //    }
    //
    //    CGFloat padding = -36.0;
    //    CGFloat paddingTop = 120.0;
    //    void (^label1Constraints)(MASConstraintMaker*) = ^(MASConstraintMaker *make) {
    //        make.width.equalTo(optionsView.mas_width).offset(padding);
    //        make.centerX.equalTo(optionsView.mas_centerX);
    //        make.centerY.equalTo(optionsView.mas_top).offset(paddingTop);
    //    };
    //    [label1 mas_makeConstraints:label1Constraints];
    //
    //    void (^label2Constraints)(MASConstraintMaker*) = ^(MASConstraintMaker *make) {
    //        make.width.equalTo(optionsView.mas_width).offset(padding);
    //        make.centerX.equalTo(optionsView.mas_centerX);
    //        make.centerY.equalTo(optionsView.mas_centerY).offset(0);
    //    };
    //    [label2 mas_makeConstraints:label2Constraints];
    
    
    
    UIView* infoInterstitialView = [[UIView alloc] initWithFrame:CGRectZero];
    [infoInterstitialView setAlpha:1.0];
    [optionsView addSubview:infoInterstitialView];
    
    UIView* infoBackgroundView = [[UIView alloc] initWithFrame:CGRectZero];
    [infoBackgroundView setBackgroundColor:[UIColor blackColor]];
    [infoBackgroundView setAlpha:0.8];
    [infoInterstitialView addSubview:infoBackgroundView];
    
    UILabel* instructions = [[UILabel alloc] init];
    instructions.numberOfLines = 0;
//    instructions.text = @"Hold your camera over a catalog, lookbook or mailer and take a picture.";
    instructions.text = @"Please align the page and hold steady.";
    instructions.textAlignment = NSTextAlignmentCenter;
    instructions.textColor = [UIColor whiteColor];
    instructions.font = [Fonts fontType:FontTypeNormal
                               withSize:FontSizeBig];
    instructions.font = config.scanInterstitialLabelFont;
    [infoInterstitialView addSubview:instructions];
    
    UILabel* instructions2 = [[UILabel alloc] init];
    instructions2.numberOfLines = 0;
//    instructions2.text = @"Oh Snap!\n\nWe didn't recognize anything in the scene.";
    instructions2.text = @"😢\n\nWe didn't recognize this page.";
    instructions2.textAlignment = NSTextAlignmentCenter;
    instructions2.textColor = [UIColor whiteColor];
    instructions2.font = config.scanInterstitialLabelFont;
    [infoInterstitialView addSubview:instructions2];
    
    UIButton* continueButton = [[UIButton alloc] initWithFrame:CGRectZero];
    [continueButton addTarget:self action:@selector(setUpClickToScanContinueButton:) forControlEvents:UIControlEventTouchUpInside];
    continueButton.userInteractionEnabled = YES;
    continueButton.accessibilityLabel = @"continue-now";
    continueButton.layer.cornerRadius = 2;
    continueButton.backgroundColor = [UIColor colorWithRed:0.05 green:0.05 blue:0.05 alpha:1];
    continueButton.layer.borderColor = [[UIColor colorWithRed:0.9 green:0.9 blue:0.9 alpha:1] CGColor];
    continueButton.layer.masksToBounds = YES;
    continueButton.layer.borderWidth = 1.0;
    continueButton.titleLabel.textColor = [UIColor whiteColor];
    continueButton.titleLabel.font = config.scanInterstitialLabelFont;
    
    
    [continueButton setTitle:@"OK"
                    forState:UIControlStateNormal];
    
    [infoInterstitialView addSubview:continueButton];
    
    
    
    UIButton* infoButton = [[UIButton alloc] init];
    [infoButton setImage:[UIImage SDKImageNamed:@"Info"] forState:UIControlStateNormal];
    
    [optionsView addSubview:infoButton];
    
    
    UIImage* topLeft = [[UIImage SDKImageNamed:@"topLeftBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
    UIImageView* topLeftBracket = [[UIImageView alloc] initWithImage:topLeft];
    [optionsView addSubview:topLeftBracket];
    
    UIImage* topRight = [[UIImage SDKImageNamed:@"topRightBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
    UIImageView* topRightBracket = [[UIImageView alloc] initWithImage:topRight];
    [optionsView addSubview:topRightBracket];
    
    UIImage* bottomLeft = [[UIImage SDKImageNamed:@"bottomLeftBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
    UIImageView* bottomLeftBracket = [[UIImageView alloc] initWithImage:bottomLeft];
    [optionsView addSubview:bottomLeftBracket];
    
    UIImage* bottomRight = [[UIImage SDKImageNamed:@"bottomRightBracket"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 16, 0, 16) resizingMode:UIImageResizingModeStretch];
    UIImageView* bottomRightBracket = [[UIImageView alloc] initWithImage:bottomRight];
    [optionsView addSubview:bottomRightBracket];
    
    
    
    
    
    //    [optionsView mas_remakeConstraints:^(MASConstraintMaker *make){
    //         make.top.bottom.left.right.equalTo(self.view);
    //    }];
    //
    //
    [infoInterstitialView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.top.bottom.left.right.equalTo(optionsView);
    }];
    
    [infoBackgroundView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.top.bottom.left.right.equalTo(infoInterstitialView);
    }];
    
    [instructions mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(infoInterstitialView.mas_centerY);
        make.width.equalTo(optionsView.mas_width);
        make.centerX.equalTo(optionsView.mas_centerX);
    }];
    
    [instructions2 mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(instructions.mas_top).offset(-12);
        make.width.equalTo(optionsView.mas_width);
        make.centerX.equalTo(optionsView.mas_centerX);
    }];
    [continueButton mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.centerX.equalTo(infoInterstitialView.mas_centerX);
        make.width.equalTo(@115);
        make.top.equalTo(instructions.mas_bottom).offset(25);
        make.height.equalTo(@42);
    }];
    
    
    
    
    [infoButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(@(38));
        make.right.equalTo(@(0)).offset(-10);
        make.width.equalTo(@(38));
        make.height.equalTo(@(38));
    }];
    
    [topLeftBracket mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoButton.mas_bottom).offset(30);
        make.width.height.equalTo(@52);
        make.left.equalTo(@12);
    }];
    [topRightBracket mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(infoButton.mas_bottom).offset(30);
        make.width.height.equalTo(@52);
        make.right.equalTo(@0).offset(-12);
    }];
    
    int bottomOffset = -72;
    if (@available(iOS 8.0, *)) {
        if(IS_IPHONE_X){
            bottomOffset = bottomOffset - 32;
        }
    } else {
        // Fallback on earlier versions
    }
    
    [bottomLeftBracket mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(optionsView.mas_bottom).offset(bottomOffset);
        make.width.height.equalTo(@52);
        make.left.equalTo(@12);
    }];
    [bottomRightBracket mas_makeConstraints:^(MASConstraintMaker *make) {
        make.bottom.equalTo(optionsView.mas_bottom).offset(bottomOffset);
        make.width.height.equalTo(@52);
        make.right.equalTo(@0).offset(-12);
    }];
    
    
    return optionsView;
    
}


- (IBAction)snapPhotoToSearch:(id)sender {
    _shouldSearchForCraftARResult = true;
    _shouldSearchForBarcodes = true;
     [[FIRTrackProxy sharedProxy] trackScanAttempt];
}



- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex{
    
    //barcode scanner alert
    if(alertView.tag == 200){
        self.shouldScanForBarcodes = true;
    }
    
    if(self.isOnClickToScan == YES){
        //  self._previewOverlay.hidden = NO;
        [[_sdk getCamera] restartCapture];
    }
}


#pragma MARK - Scan Shop Recognition Delegate Methods
- (void)didRecognizeBarCode:(NSString*)productId {
    UIViewController *catalogViewController = [self loadScanResultsForBarcode:productId];
    self.hasShownResult = true;
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:catalogViewController];
    [self presentViewController:nav animated:YES completion:^{}];
}

- (void)didRecognizeQRCode:(NSString *)urlString{
    NSURL* url = [NSURL URLWithString:urlString];
    NSURLRequest* req = [NSURLRequest requestWithURL:url];
    WebViewController* webViewController = [[WebViewController alloc] initWithRequest:req];
    webViewController.shouldReloadOnViewDidAppear = true;
    webViewController.shouldShowBackButton = YES;
    webViewController.isFromScanView = YES;
    webViewController.scanShopDelegate = self;
    self.hasShownResult = true;
    //                [self.navigationController pushViewController:webViewController animated:true];
    //                [self presentViewController:webViewController animated:YES completion:^{}];
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:webViewController];
    [self presentViewController:nav animated:YES completion:^{}];
}

- (void)didRecognizeCatalog:(NSString*)catalogId andPage:(NSString*)pageId{
    //we initiate a product view controller with the information
    UIViewController *catalogViewController = [self loadScanResultsForCatalog:catalogId pageNumber:[pageId intValue]];
    
    //We present this view controller on our global navigation
    UINavigationController* nav = [[UINavigationController alloc] initWithRootViewController:catalogViewController];
    [self presentViewController:nav animated:YES completion:^{}];
//    [self.navigationController pushViewController:catalogViewController animated:YES];
}

- (void) didValidateToken {
    // Token valid, do nothing
}




@end

