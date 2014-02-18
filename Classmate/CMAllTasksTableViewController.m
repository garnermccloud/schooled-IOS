//
//  CMAllTasksTableViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/23/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMAllTasksTableViewController.h"
#import "CMTaskDetailViewController.h"
#import "CMCustomTaskCell.h"
#import "GAIDictionaryBuilder.h"

@interface CMAllTasksTableViewController ()

@end

@implementation CMAllTasksTableViewController


-(void)viewWillAppear:(BOOL)animated
{
    self.listName = @"Upcoming Tasks";
    
    [super viewWillAppear:NO];
    
#pragma mark Google Analytics
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Upcoming Tasks"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"tasks_ready"
                                               object:nil];
    [self.tableView reloadData];

    
}


#pragma mark - Meteor Collection Querying

-(void)loadSubscriptions
{
        [super loadSubscriptions];
   // for (NSDictionary *course in self.courses) {
   //     [self.meteor addSubscription:@"tasks" withParameters:@[course[@"_id"]]];
   // }

}

- (NSDictionary *)currentUser
{
    return [self.meteor.collections[@"users"] firstObject];
}

- (NSArray *)courses
{
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(_id IN %@)", self.currentUser[@"courses"]];
    return [self.meteor.collections[@"courses"] filteredArrayUsingPredicate:pred];
}

- (NSArray *)tasks
{
    NSPredicate *pred = [NSPredicate predicateWithBlock:^BOOL(id evaluatedObject, NSDictionary *bindings) {
        NSDictionary *task = evaluatedObject;
        id date = [task[@"commits"] lastObject][@"dueDate"];
        id valid = [task[@"commits"] lastObject][@"valid"];
        double dateDouble = [date doubleValue] / 1000;
        NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
        dateComponents.day = 0;
        NSCalendar *calendar = [NSCalendar currentCalendar];
        [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
        NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:[NSDate date]];
        double todayInSecondsSince1970 = [[calendar dateFromComponents:comps] timeIntervalSince1970];
        NSNumber *validNumber = (NSNumber *) valid;
        if ([self.currentUser[@"courses"] containsObject:task[@"courseId"]] && [validNumber isEqual: @(YES)]  && !(dateDouble < todayInSecondsSince1970)) {
            return YES;
        } else {
            return NO;
        }
    }];
    NSSortDescriptor *sort = [NSSortDescriptor sortDescriptorWithKey:@"commits" ascending:YES comparator:^NSComparisonResult(id obj1, id obj2) {
        id mostRecentCommit1 = [obj1 lastObject];
        id mostRecentCommit2 = [obj2 lastObject];
        double date1 = [mostRecentCommit1[@"dueDate"] doubleValue];
        double date2 = [mostRecentCommit2[@"dueDate"] doubleValue];
        if (date1 < date2)
        {
            return (NSComparisonResult)NSOrderedAscending;
        } else if (date1 > date2)
        {
         return (NSComparisonResult)NSOrderedDescending;
        } else
        {
            return (NSComparisonResult)NSOrderedSame;
        }
    }];
    return [[self.meteor.collections[@"tasks"] filteredArrayUsingPredicate:pred] sortedArrayUsingDescriptors:@[sort]];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    
    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    
    // Return the number of rows in the section.
    return [self.tasks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Task Cell";
    CMCustomTaskCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *task = self.tasks[indexPath.row];
    NSDictionary *mostRecentCommit = [task[@"commits"] lastObject];
    cell.titleLabel.text = mostRecentCommit[@"title"];
    double dateInSeconds = [mostRecentCommit[@"dueDate"] doubleValue] / 1000 - [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: dateInSeconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    cell.dueDateLabel.text = [dateFormatter  stringFromDate:date];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(_id like %@)", task[@"courseId"]];
    NSDictionary *course = [[self.meteor.collections[@"courses"] filteredArrayUsingPredicate:pred] firstObject];
    cell.courseLabel.text = course[@"title"];
    
    return cell;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Select Task"]) {
                if ([segue.destinationViewController isKindOfClass:[CMTaskDetailViewController class]]) {
                    CMTaskDetailViewController * cmtdvc = (CMTaskDetailViewController *) segue.destinationViewController;
                    NSDictionary *task = self.tasks[indexPath.row];
                    cmtdvc.taskId = task[@"_id"];
                    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(_id like %@)", task[@"courseId"]];

                    
                    cmtdvc.course = [[self.meteor.collections[@"courses"] filteredArrayUsingPredicate:pred] firstObject];
                }
            }
        }
    }
}





@end
