//
//  CMTaskDetailViewController.h
//  Classmate
//
//  Created by Garner McCloud on 1/24/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMViewController.h"

@interface CMTaskDetailViewController : CMViewController

@property (nonatomic, strong) NSDictionary *course;

@property (nonatomic, strong) NSDictionary *task;

@property (nonatomic, strong) NSString *taskId;



@end
