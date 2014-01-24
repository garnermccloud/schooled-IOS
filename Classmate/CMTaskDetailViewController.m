//
//  CMTaskDetailViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/24/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMTaskDetailViewController.h"

@interface CMTaskDetailViewController ()

@end

@implementation CMTaskDetailViewController


-(void)loadSubscriptions
{
    [super loadSubscriptions];
    [self.meteor addSubscription:@"tasks" withParameters:@[self.course[@"_id"]]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.navigationItem.title = [self.task[@"commits"] lastObject][@"title"];   
    
}


#pragma mark - Meteor Collection Querying


- (NSDictionary *) task
{
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(_id like %@)", self.taskId];
    return [[self.meteor.collections[@"tasks"] filteredArrayUsingPredicate:pred] firstObject];
}



@end
