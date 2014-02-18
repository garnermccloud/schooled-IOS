//
//  CMTaskDetailViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/24/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMTaskDetailViewController.h"
#import "CMTaskEditViewController.h"
#import "GAIDictionaryBuilder.h"


@interface CMTaskDetailViewController ()

@property (weak, nonatomic) IBOutlet UILabel *dueDateLabel;
@property (weak, nonatomic) IBOutlet UITextView *NotesTextView;
@property (weak, nonatomic) IBOutlet UILabel *editedByLabel;

@end

@implementation CMTaskDetailViewController


-(void)loadSubscriptions
{
    [super loadSubscriptions];
  //  [self.meteor addSubscription:@"tasks" withParameters:@[self.course[@"_id"]]];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    
#pragma mark Google Analytics
    // returns the same tracker you created in your app delegate
    // defaultTracker originally declared in AppDelegate.m
    id tracker = [[GAI sharedInstance] defaultTracker];
    
    // This screen name value will remain set on the tracker and sent with
    // hits until it is set to a new value or to nil.
    [tracker set:kGAIScreenName
           value:@"Task Detail"];
    
    // manual screen tracking
    [tracker send:[[GAIDictionaryBuilder createAppView] build]];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"tasks_ready"
                                               object:nil];
    
    [self reloadUI];
    
}

-(void)reloadUI
{
    self.navigationItem.title = [self.task[@"commits"] lastObject][@"title"];
    
    self.dueDateLabel.text = [self dueDate];
    self.NotesTextView.text = [self.task[@"commits"] lastObject][@"notes"];
    self.editedByLabel.text = [NSString stringWithFormat:@"Last Edited By: %@", [self.task[@"commits"] lastObject][@"email"]];
}

- (NSString *)dueDate
{
    double dateInSeconds = ([[self.task[@"commits"] lastObject][@"dueDate"] doubleValue] / 1000) - [[NSTimeZone systemTimeZone] secondsFromGMT];
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: dateInSeconds];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"MM/dd/yyyy"];
    
    return [NSString stringWithFormat:@"Due on: %@",
            [dateFormatter  stringFromDate:date]];

}


#pragma mark - Meteor Collection Querying


- (NSDictionary *) task
{
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(_id like %@)", self.taskId];
    return [[self.meteor.collections[@"tasks"] filteredArrayUsingPredicate:pred] firstObject];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([segue.identifier isEqualToString:@"Edit Task"]) {
        if ([segue.destinationViewController isKindOfClass:[CMTaskEditViewController class]]) {
                CMTaskEditViewController * cmtevc = (CMTaskEditViewController *) segue.destinationViewController;
                cmtevc.task = self.task;
                cmtevc.taskId = self.taskId;
                cmtevc.course = self.course;
            }
    }
}





@end
