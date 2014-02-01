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
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (strong, nonatomic) NSDictionary *currentUser;

@end

@implementation CMMyAccountViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    NSLog(@"currentUser = %@", self.currentUser);
    
    self.emailLabel.text = [self.currentUser[@"emails"] firstObject][@"address"];
    
    self.schoolLabel.text = self.currentUser[@"school"];
}

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
