//
//  CMCourseTasksTableViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/23/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMCourseTasksTableViewController.h"
#import "CMTaskDetailViewController.h"
#import "CMTaskAddViewController.h"

@interface CMCourseTasksTableViewController ()

@end

@implementation CMCourseTasksTableViewController



-(void)viewWillAppear:(BOOL)animated
{
    self.listName = self.course[@"title"];
    [super viewWillAppear:YES];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pressedAdd)];

}

-(void)loadSubscriptions
{
    [super loadSubscriptions];
    [self.meteor addSubscription:@"tasks" withParameters:@[self.course[@"_id"]]];
}


#pragma mark - Meteor Collection Querying


- (NSArray *)tasks
{
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(courseId like %@)", self.course[@"_id"]];
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
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *task = self.tasks[indexPath.row];
    NSDictionary *mostRecentCommit = [task[@"commits"] lastObject];
    cell.textLabel.text = mostRecentCommit[@"title"];
    double dateInSeconds = [mostRecentCommit[@"dueDate"] doubleValue] / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: dateInSeconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    cell.detailTextLabel.text = [dateFormatter  stringFromDate:date];
    return cell;
}

-(void)pressedAdd
{
    [self performSegueWithIdentifier:@"Add Task" sender:self];
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
                    cmtdvc.course = self.course;
                }
            }
        }
    }
    else if ([segue.identifier isEqualToString:@"Add Task"])
              {
                  if ([segue.destinationViewController isKindOfClass:[CMTaskAddViewController class]]) {
                      CMTaskAddViewController *cmtavc = (CMTaskAddViewController *) segue.destinationViewController;
                      cmtavc.course = self.course;
                  }
              }
}






@end
