//
//  TOCScreenController.m
//  Syndeca iOS SDK
//
//  Created by Schell on 4/30/14.
//  Copyright (c) 2014 Schell Scivally. All rights reserved.
//

#import "TOCController.h"
#import "Icons.h"
#import "MasterConfiguration.h"
#import "UIViewHelper.h"
#import "FIRTrackProxy.h"
#import "NLS.h"
#import "UIViewHelper.h"
#import "PageThumbCollectionViewController.h"

@interface TOCController ()
@property (readwrite) PageThumbCollectionViewController* collectionController;
@end

@implementation TOCController

- (id)init {
    self = [super init];
    if (self) {
        self.collectionController = [[PageThumbCollectionViewController alloc] initWithCollectionViewLayout:[self thumbLayout]];
        self.collectionController.delegate = self;
        [self setViewControllers:@[self.collectionController] animated:YES];
        
        self.imageCache = [[NSCache alloc] init];
        // The tab bar item.
        // Shows a 'thumbnails' icon and a title.
        UIImage* tocImg = [[Icons sharedIcons].thLargeIconImage()
                           imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        UITabBarItem* thumbsItem = [[UITabBarItem alloc] initWithTitle:[[NLS nls]
                                                                        stringFor:@"catalog.tableOfContents" default:@"Pages"]
                                                                 image:tocImg
                                                                   tag:2];
        thumbsItem.accessibilityLabel = @"table-of-contents";
        thumbsItem.enabled = YES;
        self.tabBarItem = thumbsItem;
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    UIEdgeInsets insets = self.collectionController.collectionView.contentInset;
    insets.left = 10;
    insets.right = 10;
    self.collectionController.collectionView.contentInset = insets;
}


- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [[FIRTrackProxy sharedProxy] trackTOCShow];
}

- (void)viewDidDisappear:(BOOL)animated {
    [super viewDidDisappear:animated];
    [[FIRTrackProxy sharedProxy] trackTOCClose];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Layout

- (UICollectionViewLayout*)thumbLayout {
    UICollectionViewFlowLayout* layout = [[UICollectionViewFlowLayout alloc] init];
    layout.scrollDirection = UICollectionViewScrollDirectionVertical;
    layout.itemSize = CGSizeMake(100, 200);
    layout.minimumLineSpacing = 5;
    layout.minimumInteritemSpacing = 5;
    return layout;
}

#pragma mark - Updating the Pages

- (void)loadPages:(NSArray *)pageModels {
    [self.collectionController setPageModels:pageModels];
    //self.view;
}

#pragma mark - Showing a specific page

- (void)showPageWithModel:(PageModel *)pm {
    [self.collectionController highlightPageWithModel:pm];
}


#pragma mark - User Selection

- (void)itemContainer:(id)container didMakeSelection:(ItemSelection *)selection {
    if (self.itemSelectionDelegate && [self.itemSelectionDelegate respondsToSelector:@selector(itemContainer:didMakeSelection:)]) {
        PageModel* page = (PageModel*)selection.selection;
        [FIRTrackProxy sharedProxy].pageModels = @[page];
        [[FIRTrackProxy sharedProxy] trackTOCSelection];
        [self.itemSelectionDelegate itemContainer:self didMakeSelection:selection];
    }
}

@end
