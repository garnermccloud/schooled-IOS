//
//  CMViewController.h
//  Classmate
//
//  Created by Garner McCloud on 1/23/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <ObjectiveDDP/MeteorClient.h>

@interface CMViewController : UIViewController


@property (nonatomic, strong) MeteorClient *meteor;

@property (copy, nonatomic) NSString *userId;

-(void)loadSubscriptions;

@end
