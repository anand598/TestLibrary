//
//  VerticalPublicationController.m
//  Pods
//
//  Created by Rijul Gupta on 6/26/17.
//
//


#import "VerticalPublicationController.h"
#import <Masonry/Masonry.h>
#import "Icons.h"
#import "NLS.h"
#import "Fonts.h"
#import "MasterConfiguration.h"
#import "SearchViewController.h"
#import "VerticalPageTableViewCell.h"

@interface VerticalPublicationController ()
@property (readwrite) NSURLRequest* request;
@property (readwrite) UITableView* pageTableView;

@end

@implementation VerticalPublicationController


- (void)viewWillAppear:(BOOL)animated {
    

}

-(void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    //    [self.webview reload];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.pageTableView = [[UITableView alloc] initWithFrame:CGRectZero];
    self.pageTableView.delegate = self;
    self.pageTableView.dataSource = self;
    
    [self.pageTableView mas_remakeConstraints:^(MASConstraintMaker* make){
        make.top.left.right.bottom.equalTo(self.view);
    }];
    
}

#pragma mark - Setters

- (void)setCatalogModel:(CatalogModel*)catalogModel {
    _catalogModel = nil;
    [self.pageTableView reloadData];
    _catalogModel = catalogModel;
   // [self setNavigationItems];
}


#pragma mark - Getters
- (CatalogModel*)catalogModel {
    return _catalogModel;
}



- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.catalogModel.pageModels.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VerticalPageTableViewCell* cell = (VerticalPageTableViewCell*)[tableView dequeueReusableCellWithIdentifier:[VerticalPageTableViewCell identifier]];

    return cell;
}



- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
        return 0;
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
   
}


@end
