//
//  CMAllTasksTableViewController.h
//  Classmate
//
//  Created by Garner McCloud on 1/23/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMTableViewController.h"

@interface CMAllTasksTableViewController : CMTableViewController

@property (nonatomic, strong) NSArray *courses;

@property (nonatomic, strong) NSDictionary *currentUser;

@property (nonatomic, strong) NSArray *tasks;


@end
