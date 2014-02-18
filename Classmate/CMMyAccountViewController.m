//
//  CMMyAccountViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/29/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMMyAccountViewController.h"
#import "GAIDictionaryBuilder.h"

@interface CMMyAccountViewController ()
@property (weak, nonatomic) IBOutlet UIButton *LogOutButton;
@property (weak, nonatomic) IBOutlet UILabel *emailLabel;
@property (weak, nonatomic) IBOutlet UILabel *schoolLabel;
@property (strong, nonatomic) NSDictionary *currentUser;

@end

@implementation CMMyAccountViewController

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:NO];
    
    self.emailLabel.text = [self.currentUser[@"emails"] firstObject][@"address"];
    
    self.schoolLabel.text = self.currentUser[@"school"];
    
#pragma mark Google Analytics
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"My Account"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
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
