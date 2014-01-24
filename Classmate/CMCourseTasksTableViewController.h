//
//  CMCourseTasksTableViewController.h
//  Classmate
//
//  Created by Garner McCloud on 1/23/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMTableViewController.h"

@interface CMCourseTasksTableViewController : CMTableViewController

@property (nonatomic, strong) NSDictionary *course;

@property (nonatomic, strong) NSArray *tasks;

@end
