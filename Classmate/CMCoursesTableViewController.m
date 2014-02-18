//
//  CMCoursesTableViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/22/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMCoursesTableViewController.h"
#import "CMCourseTasksTableViewController.h"
#import "CMAddCourseTableViewController.h"
#import <ObjectiveDDP/MeteorClient.h>
#import "GAIDictionaryBuilder.h"



@interface CMCoursesTableViewController ()

@end

@implementation CMCoursesTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.editButtonItem setImage:[UIImage imageNamed:@"trash"]];
    self.editButtonItem.title = nil;
    self.navigationItem.leftBarButtonItem = self.editButtonItem;
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(pressedAdd)];
    
}


- (void)viewWillAppear:(BOOL)animated
{
    self.listName = @"My Courses";
    [super viewWillAppear:NO];
    
#pragma mark Google Analytics
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"My Courses"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    [self.tableView reloadData];
   


}

-(void)loadSubscriptions {
        [super loadSubscriptions];
}


#pragma mark - Meteor Collection Querying

- (NSDictionary *)currentUser
{
    return [self.meteor.collections[@"users"] firstObject];
}

- (NSArray *)courses
{
    NSSortDescriptor *sort= [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(_id IN %@)", self.currentUser[@"courses"]];
    return [[self.meteor.collections[@"courses"] filteredArrayUsingPredicate:pred] sortedArrayUsingDescriptors:@[sort]];
}



#pragma mark - Table view data source

-(void)setEditing:(BOOL)editing animated:(BOOL)animated {
    
    [super setEditing:editing animated:animated];
    
    if(editing) {
        //Do something for edit mode
        [self.editButtonItem setImage:nil];
    }
    
    else {
        self.editButtonItem.title = nil;
        [self.editButtonItem setImage:[UIImage imageNamed:@"trash"]];
        //Do something for non-edit mode
    }
    
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"Remove";
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{

    // Return the number of sections.
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{

    // Return the number of rows in the section.
    return [self.courses count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"Course Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *course = self.courses[indexPath.row];
    cell.textLabel.text = course[@"title"];
    return cell;
}

-(void)pressedAdd
{
    [self performSegueWithIdentifier:@"Add Course" sender:self];
}

// In a story board-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
            if ([segue.identifier isEqualToString:@"Select Course"]) {
                if ([segue.destinationViewController isKindOfClass:[CMCourseTasksTableViewController class]]) {
                    CMCourseTasksTableViewController * cmcttvc = (CMCourseTasksTableViewController *) segue.destinationViewController;
                    cmcttvc.course = self.courses[indexPath.row];
                }
            }
        }
    }
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    // If row is deleted, remove it from the list.
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *course = self.courses[indexPath.row];
        if (course) {
            [self.meteor callMethodName:@"removeCourse" parameters:@[course[@"_id"]] responseCallback:^(NSDictionary *response, NSError *error) {
                if (error) {
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Classmate - Remove Course Error"
                                                                    message:[error localizedDescription]
                                                                   delegate:nil
                                                          cancelButtonTitle:@"Try Again"
                                                          otherButtonTitles:nil];
                    [alert show];
                    
                }
            }];
        }
    }
}



@end
