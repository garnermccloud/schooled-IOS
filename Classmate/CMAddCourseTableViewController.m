//
//  CMAddCourseTableViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/24/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMAddCourseTableViewController.h"

@interface CMAddCourseTableViewController ()

@end

@implementation CMAddCourseTableViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view.
    
    
    self.listName = @"Available Courses";
    
    // Restore search term
    if ([self savedSearchTerm])
    {
        [[[self searchDisplayController] searchBar] setText:[self savedSearchTerm]];
    }
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    
    // Save the state of the search UI so that it can be restored if the view is re-created.
    [self setSavedSearchTerm:[[[self searchDisplayController] searchBar] text]];

    [self setSearchResults:nil];
}

- (void)handleSearchForTerm:(NSString *)searchTerm
{
    [self setSavedSearchTerm:searchTerm];

    
    if ([self searchResults] == nil)
    {
        NSMutableArray *array = [[NSMutableArray alloc] init];
        [self setSearchResults:array];
    }
    
    [[self searchResults] removeAllObjects];
    
    if ([[self savedSearchTerm] length] != 0)
    {
        for (NSDictionary *course in self.courses)
        {
            NSString *currentString = course[@"title"];
            if ([currentString rangeOfString:searchTerm options:NSCaseInsensitiveSearch].location != NSNotFound)
            {
                [[self searchResults] addObject:course];
            }
        }
    }
}

- (BOOL)searchDisplayController:(UISearchDisplayController *)controller
shouldReloadTableForSearchString:(NSString *)searchString
{
    [self handleSearchForTerm:searchString];
    
    return YES;
}

- (void)searchDisplayControllerWillEndSearch:(UISearchDisplayController *)controller
{
    [self setSavedSearchTerm:nil];
    
    [self.tableView reloadData];
}




#pragma mark - Meteor Collection Querying

- (NSDictionary *)currentUser
{
    return [self.meteor.collections[@"users"] firstObject];
}



- (NSArray *)courses
{
    NSSortDescriptor *sort= [NSSortDescriptor sortDescriptorWithKey:@"title" ascending:YES];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"NOT (_id IN %@)", self.currentUser[@"courses"]];
    return [[self.meteor.collections[@"courses"] filteredArrayUsingPredicate:pred]sortedArrayUsingDescriptors:@[sort]];
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
    NSInteger rows;
    
    if (tableView == [[self searchDisplayController] searchResultsTableView])
    {
        rows = [self.searchResults count];
    }
    else
        rows =  [self.courses count];
    
    return rows;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    static NSString *CellIdentifier = @"Course Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier forIndexPath:indexPath];
    
    // Configure the cell...
    NSDictionary *course = nil;

    if (tableView == [[self searchDisplayController] searchResultsTableView])
        course = self.searchResults[indexPath.row];

    else
        course = self.courses[indexPath.row];
    
    
    cell.textLabel.text = course[@"title"];
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *course = nil;
    if (tableView == [[self searchDisplayController] searchResultsTableView]) {
        course = self.searchResults[indexPath.row];
    }
    else {
        course = self.courses[indexPath.row];
    }

    if (course) {
        [self.meteor callMethodName:@"addCourse" parameters:@[course] responseCallback:^(NSDictionary *response, NSError *error) {
            if (error) {
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Classmate - Add Course Error"
                                                                message:[error localizedDescription]
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try Again"
                                                      otherButtonTitles:nil];
                [alert show];

            }
        }];
        [self.navigationController popViewControllerAnimated: YES];
    }
}

// In a story board-based application, you will often want to do a little preparation before navigation
/*- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([sender isKindOfClass:[UITableViewCell class]]) {
        
        NSIndexPath *indexPath = [self.tableView indexPathForCell:sender];
        if (indexPath) {
 
                }
            }
        }
    }
}
*/


@end
