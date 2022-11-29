//
//  TrackingPanel.m
//  Justice
//
//  Created by Schell Scivally on 12/8/15.
//  Copyright © 2015 Schell Scivally. All rights reserved.
//

#import "TrackingPanel.h"
#import "FIRTrackProxy.h"
#import "Icons.h"

@implementation TrackingPanel

- (id)init {
    self = [super initWithStyle:UITableViewStylePlain];
    if (self) {
        [[FIRTrackProxy sharedProxy] collectResponses];
        
        self.tabBarItem = [[UITabBarItem alloc] initWithTitle:@"Tracking Panel" image:[Icons sharedIcons].cogIconImage() tag:0];
        self.tableView.contentInset = UIEdgeInsetsMake(64, 0, 44, 0);
    }
    return self;
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self.tableView reloadData];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    NSArray* responses = [[FIRTrackProxy sharedProxy] getResponses];
    return [responses count];
}

- (UITableViewCell*)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSArray* responses = @[];
    for (FIRTrackingConclusion* c in [[[FIRTrackProxy sharedProxy] getResponses] reverseObjectEnumerator]) {
        responses = [responses arrayByAddingObject:c];
    }
    
    FIRTrackingConclusion* c = [responses objectAtIndex:indexPath.row];
    
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:@"tracking-panel"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"tracking-panel"];
    }
    
    cell.textLabel.text = [c name];
    cell.detailTextLabel.numberOfLines = 0;
    cell.detailTextLabel.text = [c detail];
    cell.accessoryType = [c wasSaved] ? UITableViewCellAccessoryCheckmark : UITableViewCellAccessoryDetailDisclosureButton;
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

@end
