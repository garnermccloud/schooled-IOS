//
//  CMTaskEditViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/26/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMTaskEditViewController.h"

@interface CMTaskEditViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;



@end

@implementation CMTaskEditViewController


-(void)loadSubscriptions
{
    [super loadSubscriptions];
  //  [self.meteor addSubscription:@"tasks" withParameters:@[self.course[@"_id"]]];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
UITapGestureRecognizer *tapScroll = [[UITapGestureRecognizer alloc]initWithTarget:self     action:@selector(tapped)];
tapScroll.cancelsTouchesInView = NO;
[self.scrollView addGestureRecognizer:tapScroll];
}

- (void) tapped
{
    [self.view endEditing:YES];
}


-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    [self reloadUI];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(didReceiveUpdate:)
                                                 name:@"tasks_ready"
                                               object:nil];
    
}

-(void)reloadUI
{
    self.navigationItem.title = @"Edit Task";
    self.titleField.text = [self.task[@"commits"] lastObject][@"title"];
    
    self.datePicker.date = [self dueDate];
    self.notesTextView.text = [self.task[@"commits"] lastObject][@"notes"];
}

- (NSDate *)dueDate
{
    double dateInSeconds = [[self.task[@"commits"] lastObject][@"dueDate"] doubleValue] / 1000;
    NSDate *date = [NSDate dateWithTimeIntervalSince1970: dateInSeconds];
    return date;
    
}


#pragma mark - Meteor Collection Querying


- (NSDictionary *) task
{
    
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"(_id like %@)", self.taskId];
    return [[self.meteor.collections[@"tasks"] filteredArrayUsingPredicate:pred] firstObject];
}

- (IBAction)pressedSubmitBarButton:(id)sender
{
    NSMutableDictionary *task = [[NSMutableDictionary alloc] init];
    [task setValue:self.taskId forKeyPath:@"_id"];
    [task setValue:self.titleField.text forKeyPath:@"title"];
    double dateInMillisecondsSince1970 = [self.datePicker.date timeIntervalSince1970];
    dateInMillisecondsSince1970 = dateInMillisecondsSince1970 * 1000;
    NSNumber *date = [[NSNumber alloc] initWithDouble:dateInMillisecondsSince1970];
    [task setValue:date forKeyPath:@"dueDate"];
    [task setValue:self.notesTextView.text forKeyPath:@"notes"];


        [self.meteor callMethodName:@"updateTask" parameters:@[task] responseCallback:^(NSDictionary *response, NSError *error) {
            if (error) {
                NSString *errorMessage;
                if ([[error localizedDescription] isKindOfClass:[NSString class]])
                {
                    errorMessage = [error localizedDescription];
                } else {
                    id errorId = [error localizedDescription];
                    NSDictionary *errorDictionary = (NSDictionary *)errorId;
                    errorMessage = errorDictionary[@"reason"];
                }
                NSLog(@"Error = %@", error);
                //NSDictionary *errorDictionary = (NSDictionary *)errorId;
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:errorMessage
                                                               delegate:nil
                                                      cancelButtonTitle:@"Try Again"
                                                      otherButtonTitles:nil];
                [alert show];
                
            }
            else {
                [self.navigationController popViewControllerAnimated: YES];
            }
        }];

}






@end
