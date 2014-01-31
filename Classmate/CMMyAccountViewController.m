//
//  CMMyAccountViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/29/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMMyAccountViewController.h"

@interface CMMyAccountViewController ()
@property (weak, nonatomic) IBOutlet UIButton *LogOutButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;

@end

@implementation CMMyAccountViewController



- (NSDictionary *)currentUser
{
    return [self.meteor.collections[@"users"] firstObject];
}

- (IBAction)didTapLogOutButton:(id)sender
{
    [self.meteor logout];
    [self.tabBarController setSelectedIndex:0];
}


@end
