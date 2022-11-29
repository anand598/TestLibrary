//
//  HamburgerMenuViewController.m
//  Pods
//
//  Created by Rijul Gupta on 3/10/17.
//
//
#import "HamburgerMenuViewController.h"
#import "SyndecaRevealViewController.h"
#import "Fonts.h"
#import <Masonry/Masonry.h>
#import "UIImageView+AFNetworking.h"
#import <ReactiveCocoa/RACEXTScope.h>
#import "NLS.h"
#import "Icons.h"
#import "MasterConfiguration.h"
#import "WebViewController.h"
#import "FIRTrackProxy.h"

@interface HamburgerMenuViewController()
{
    NSInteger _presentedRow;
    int headerViewHeight;
    int footerViewHeight;
}
@end

@implementation HamburgerMenuViewController

@synthesize rearTableView = _rearTableView;
@synthesize syndecaFooterView = _syndecaFooterView;

BOOL _userAccounts = false;

static Class __hamburgerMenuViewControllerDIClass = nil;
+ (Class)DIClass {
    if (!__hamburgerMenuViewControllerDIClass) {
        __hamburgerMenuViewControllerDIClass = [HamburgerMenuViewController class];
    }
    return __hamburgerMenuViewControllerDIClass;
}

+ (void)setDIClass:(Class)c {
    if ([c isSubclassOfClass:[HamburgerMenuViewController class]]) {
        __hamburgerMenuViewControllerDIClass = c;
    } else {
        [NSException raise:@"Class is not a subclass of HamburgerMenuController" format:@""];
    }
}



#pragma mark - View lifecycle


- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = NSLocalizedString(@"Rear View", nil);
    self.edgesForExtendedLayout = false;


//set up a background view for the top layout guide
#pragma mark - UITableView Styles
    headerViewHeight = 30;
    footerViewHeight = 50;


    self.rearTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
    self.rearTableView.delegate = self;
    self.rearTableView.dataSource = self;
    [self.rearTableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    [self.view addSubview:self.rearTableView];
    [self.rearTableView mas_remakeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.view.mas_top).offset(20);
        make.left.equalTo(self.view.mas_left);
        make.right.equalTo(self.view.mas_right);
        make.bottom.equalTo(self.view.mas_bottom);//-52 for the bottom tabbar
    }];
}


#pragma marl - UITableView Data Source
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 0;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

#pragma mark Sticky Footer View
-(UIView *)customFooterView {
    UIView* footerView = [[UIView alloc] initWithFrame:CGRectZero];
    [self.view addSubview:footerView];
    footerView.backgroundColor = self.view.backgroundColor;

    UILabel* poweredLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    poweredLabel.font = [UIFont fontWithName:@"HelveticaNeue" size:12];
    poweredLabel.textColor = [UIColor colorWithWhite:0.55 alpha:1.0];
    poweredLabel.text = @"Powered By";
    [footerView addSubview:poweredLabel];

    NSBundle* bundle = [NSBundle bundleWithURL:[[NSBundle bundleForClass:[self class]] URLForResource:@"SyndecaSDK" withExtension:@"bundle"]];
    UIImage* logoImage = [UIImage imageNamed:@"syndeca.png" inBundle:bundle compatibleWithTraitCollection:nil];
    UIImageView* logoView = [[UIImageView alloc] initWithFrame:CGRectZero];
    [logoView setImage:logoImage];
    [logoView setContentMode:UIViewContentModeScaleAspectFit];
    [footerView addSubview:logoView];

    [footerView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.right.bottom.equalTo(self.view);
        make.height.equalTo(@(footerViewHeight));
    }];

    [poweredLabel sizeToFit];
    [poweredLabel mas_remakeConstraints:^(MASConstraintMaker *make){
        make.centerY.equalTo(footerView.mas_centerY);
        make.left.equalTo(footerView.mas_left).offset(12);
    }];

    [logoView mas_remakeConstraints:^(MASConstraintMaker *make){
        make.top.equalTo(footerView.mas_top).offset(12);
        make.bottom.equalTo(footerView.mas_bottom).offset(-12);
        make.left.equalTo(poweredLabel.mas_right).offset(2);
        make.width.lessThanOrEqualTo(@72);
    }];

    [footerView setAlpha:0.0];
    return footerView;
}


-(UIView *)customHeaderForTableView{
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, headerViewHeight)];
    [headerView setBackgroundColor:self.rearTableView.backgroundColor];


    UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
    headerLabel.text = @"Menu";
    headerLabel.font = [Fonts fontType:FontTypeNormal withSize:FontSizeMedium];
    headerLabel.textColor = [UIColor colorWithWhite:0.32 alpha:1.0];
    headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:([Fonts fontType:FontTypeNormal withSize:FontSizeMedium].pointSize + 4)];
    [headerView addSubview:headerLabel];

    [headerLabel mas_remakeConstraints:^(MASConstraintMaker *make){
        make.left.equalTo(headerView.mas_left).offset(10);
        make.top.equalTo(headerView.mas_top).offset(2);
    }];
    return headerView;
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    if (section == 0 && _userAccounts == false){
        UIView *view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, tableView.frame.size.width, headerViewHeight)];
        [view setBackgroundColor:self.rearTableView.backgroundColor];


        UILabel* headerLabel = [[UILabel alloc] initWithFrame:CGRectZero];
        headerLabel.text = @"Menu";
        headerLabel.font = [Fonts fontType:FontTypeNormal withSize:FontSizeMedium];
        headerLabel.textColor = [UIColor colorWithWhite:0.32 alpha:1.0];
        headerLabel.font = [UIFont fontWithName:@"HelveticaNeue-Medium" size:([Fonts fontType:FontTypeNormal withSize:FontSizeMedium].pointSize + 4)];
        [view addSubview:headerLabel];

        [headerLabel mas_remakeConstraints:^(MASConstraintMaker *make){
            make.left.equalTo(view.mas_left).offset(10);
            make.top.equalTo(view.mas_top).offset(2);
        }];

        return view;
    }

    return nil;
}


- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if(section == 0){
        return headerViewHeight;
    }
    else{
        return headerViewHeight;
    }

}

#pragma mark - MailCompose Delegation

- (void)mailComposeController:(MFMailComposeViewController *)controller
          didFinishWithResult:(MFMailComposeResult)result
                        error:(NSError *)error {
    NSLog(@"%s %i %@",__func__,result,error);
    dispatch_async(dispatch_get_main_queue(), ^{
        [self dismissViewControllerAnimated:YES completion:^{
            self.mailController = [[MFMailComposeViewController alloc] init];
            self.mailController.mailComposeDelegate = self;
        }];
    });
}



- (void)sendEmail:(NSString *)headline {
    if ([MFMailComposeViewController canSendMail]) {
        if (headline == nil || [headline isEqualToString:@""]) {
            headline = [MasterConfiguration sharedConfiguration].clientFeedbackEmailSubject;
        }
        MFMailComposeViewController *mail = [[MFMailComposeViewController alloc] init];
        mail.mailComposeDelegate = self;
        [mail setSubject:headline];
        [mail setMessageBody:@"" isHTML:NO];
        [mail setToRecipients:@[[MasterConfiguration sharedConfiguration].clientFeedbackEmail]];
        if([[MasterConfiguration sharedConfiguration] clientFeedbackEmail]){
            [mail setToRecipients:@[[[MasterConfiguration sharedConfiguration] clientFeedbackEmail]]];
        }
        dispatch_async(dispatch_get_main_queue(), ^{
            [self presentViewController:mail animated:YES completion:^{}];
        });
    }
    else
    {
        NSLog(@"This device cannot send email");
    }
}


- (void)didPressHeaderView:(id)sender {
    dispatch_async(dispatch_get_main_queue(), ^{
        UIAlertView *alert = [[UIAlertView alloc] init];
        [alert setTitle:@"Not Available"];
        [alert setMessage:@"This feature is coming soon"];
        [alert setDelegate:self];
        [alert addButtonWithTitle:@"Okay"];
        [alert show];
    });
}

#pragma mark - UITableView Cell Design

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    if(indexPath.section == 1){
        return 50.0;
    }
    return 64.0;
}

- (BOOL)tableView:(UITableView *)tableView shouldHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView didHighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Add your Colour.
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:[UIColor colorWithWhite:0.961 alpha:1.000] ForCell:cell];  //highlight colour

}

- (void)tableView:(UITableView *)tableView didUnhighlightRowAtIndexPath:(NSIndexPath *)indexPath {
    // Reset Colour.
    UITableViewCell *cell = (UITableViewCell *)[tableView cellForRowAtIndexPath:indexPath];
    [self setCellColor:self.rearTableView.backgroundColor ForCell:cell]; //normal color
}

- (void)setCellColor:(UIColor *)color ForCell:(UITableViewCell *)cell {
    dispatch_async(dispatch_get_main_queue(), ^{
        cell.contentView.backgroundColor = color;
        cell.backgroundColor = color;
    });
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
     static NSString *cellIdentifier = @"Cell";
     UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];

     if (nil == cell)
     {
         cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
     }

     // Remove seperator inset
     if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
         [cell setSeparatorInset:UIEdgeInsetsZero];
     }

     // Prevent the cell from inheriting the Table View's margin settings
     if ([cell respondsToSelector:@selector(setPreservesSuperviewLayoutMargins:)]) {
         [cell setPreservesSuperviewLayoutMargins:NO];
     }

     // Explictly set your cell's layout margins
     if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
         [cell setLayoutMargins:UIEdgeInsetsZero];
     }

     cell.selectionStyle = UITableViewCellSelectionStyleNone;
     cell.contentView.backgroundColor = self.rearTableView.backgroundColor;
     cell.textLabel.textColor = [UIColor colorWithRed:(172.0/255.0) green:(172.0/255.0) blue:(172.0/255.0) alpha:1.0];

    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Grab a handle to the reveal controller, as if you'd do with a navigtion controller via self.navigationController.
    SyndecaRevealViewController *revealController = self.revealViewController;

    // selecting row
    NSInteger row = indexPath.row;

    UITableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    NSString* item = cell.textLabel.text;
    if (item) {
        [[FIRTrackProxy sharedProxy] trackNavTap:item];
    }
}

- (ShoppingCartController*)newWishlistController {

    self.mailController     = [[MFMailComposeViewController alloc] init];
    self.mailController.mailComposeDelegate = self;

    @weakify(self);
    ShoppingCartController* screen = [[ShoppingCartController alloc] init];
    NSString* wishlistStr = [[NLS nls] stringFor:@"wishlist.title" default:@"*wishlist title*"];
    screen.tabBarItem.title = wishlistStr;
    screen.tabBarItem.image = [Icons sharedIcons].heartIconImage();
    screen.tabBarItem.accessibilityLabel = @"wishlist";
    screen.productDetailViewDelegate = self.syndecaTabBarController;
    screen.shoppingCartScreen.titleLabel.text = wishlistStr;
    [screen.shoppingCartScreen.exportButton
     setTitle:[[NLS nls] stringFor:@"wishlist.shareEmailText"
                           default:@"*shareEmailText"]
     forState:UIControlStateNormal];
    screen.shoppingCartScreen.emptyBagLabel.text = [[NLS nls]
                                                    stringFor:@"wishlist.emptyText"
                                                    default:@"Your wish list is currently empty."];

    // TODO: Move shopping cart export aciton into MasterConfiguration.
    screen.shoppingCartScreen.exportAction = ^(ShoppingCart* cart) {
        @strongify(self);

        // TODO: Change this so Mary Kay messaging isn't in the SDK.
        [self.mailController setSubject:[@"Mary Kay -" stringByAppendingString:wishlistStr]];
        NSString* wishpath = [[NSBundle mainBundle] pathForResource:@"wishlist" ofType:@"html"];
        NSString* wishtmpl = [[NSString alloc] initWithContentsOfFile:wishpath
                                                             encoding:NSUTF8StringEncoding
                                                                error:NULL];
        NSArray* products = @[];
        for (ProductGroupModel* pm in [cart array]) {
            NSString* dollars = [NSString stringWithFormat:@"%i", (int)pm.priceFloat];
            NSInteger cent = (int)(pm.priceFloat - (int)pm.priceFloat) * 100;
            NSString* cents = [NSString stringWithFormat:@"%li", (long)cent];
            if (cent < 10) {
                cents = [@"0" stringByAppendingString:cents];
            }

            products = [products arrayByAddingObject:@{ @"src" : [pm.previewURL absoluteString],
                                                        @"title" : pm.title,
                                                        @"name" : pm.name,
                                                        @"quantity": @([cart quantityOfItem:pm]),
                                                        @"dollars" : dollars,
                                                        @"cents" : cents}];
        }
        CGFloat total = [cart totalPrice];
        NSString* dollars = [NSString stringWithFormat:@"%i", (int)total];
        NSInteger cent = (int)(total - (int)total) * 100;
        NSString* cents = [NSString stringWithFormat:@"%li", (long)cent];
        if (cent < 10) {
            cents = [@"0" stringByAppendingString:cents];
        }

        NSString* wishlist = @"";
//        [HBHandlebars renderTemplateString:wishtmpl
//                                                    withContext:@{ @"products" : products,
//                                                                   @"totalDollars" : dollars,
//                                                                   @"totalCents" : cents}
//                                                          error:NULL];
        [self.mailController setMessageBody:wishlist isHTML:YES];

        [self presentViewController:self.mailController animated:YES completion:^{}];
    };

    [screen.view layoutIfNeeded];
    return screen;
}


- (ScanShopViewController*)newScanShopController {
    ScanShopViewController* retVal = [[[ScanShopViewController DIClass] alloc] init];
    return retVal;
}

@end
