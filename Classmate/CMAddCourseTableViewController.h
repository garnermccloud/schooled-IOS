//
//  CMAddCourseTableViewController.h
//  Classmate
//
//  Created by Garner McCloud on 1/24/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMTableViewController.h"

@interface CMAddCourseTableViewController : CMTableViewController <UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic, strong) NSArray *courses;

@property (nonatomic, strong) NSDictionary *currentUser;

@property (nonatomic, strong) NSMutableArray *searchResults;

@property (nonatomic, copy) NSString *savedSearchTerm;

- (void)handleSearchForTerm:(NSString *)searchTerm;


@end
