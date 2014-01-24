//
//  CMTableViewController.h
//  Classmate
//
//  Created by Garner McCloud on 1/22/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>

@interface CMTableViewController : UITableViewController

@property (nonatomic, strong) MeteorClient *meteor;

@property (copy, nonatomic) NSString *userId;

@property (nonatomic, strong) NSString *listName;

@end
