//
//  CMCourseTasksTableViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/23/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMCourseTasksTableViewController.h"

@interface CMCourseTasksTableViewController ()

@end

@implementation CMCourseTasksTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    [self.meteor addSubscription:@"tasks" withParameters:@[self.course[@"_id"]]];
    
    
    
}

-(void)viewWillAppear:(BOOL)animated
{
    self.listName = self.course[@"title"];
    [self.meteor addSubscription:@"tasks" withParameters:@[self.course[@"_id"]]];
    
    [super viewWillAppear:YES];

    
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






@end
