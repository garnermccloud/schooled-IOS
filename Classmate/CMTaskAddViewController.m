//
//  CMTaskAddViewController.m
//  Classmate
//
//  Created by Garner McCloud on 1/27/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMTaskAddViewController.h"

@interface CMTaskAddViewController ()
@property (weak, nonatomic) IBOutlet UITextField *titleField;
@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;
@property (weak, nonatomic) IBOutlet UITextView *notesTextView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *submitBarButtonItem;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation CMTaskAddViewController

-(void)loadSubscriptions
{
    [super loadSubscriptions];
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
    self.navigationItem.title = @"Add Task";
}


#pragma mark - Meteor Collection Querying



- (IBAction)pressedSubmitBarButton:(id)sender
{
    NSMutableDictionary *task = [[NSMutableDictionary alloc] init];
    [task setValue:self.titleField.text forKeyPath:@"title"];
     [task setValue:self.course[@"_id"] forKeyPath:@"courseId"];
    NSCalendar *calendar = [NSCalendar currentCalendar];
    [calendar setTimeZone:[NSTimeZone timeZoneWithName:@"GMT"]];
    NSDateComponents* comps = [calendar components:NSYearCalendarUnit|NSMonthCalendarUnit|NSDayCalendarUnit fromDate:self.datePicker.date];
    double dateInSecondsSince1970 = [[calendar dateFromComponents:comps] timeIntervalSince1970];
    
    //date is off by a day for some reason, quick fix, correct later
    //dateInSecondsSince1970 = dateInSecondsSince1970 - (60*60*24);
    
    double dateInMillisecondsSince1970 = dateInSecondsSince1970 * 1000;
    NSNumber *date = [[NSNumber alloc] initWithDouble:dateInMillisecondsSince1970];
    [task setValue:date forKeyPath:@"dueDate"];
    [task setValue:self.notesTextView.text forKeyPath:@"notes"];

    
    [self.meteor callMethodName:@"addTask" parameters:@[task] responseCallback:^(NSDictionary *response, NSError *error) {
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
