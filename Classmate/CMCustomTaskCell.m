//
//  CMCustomTaskCell.m
//  Classmate
//
//  Created by Garner McCloud on 1/24/14.
//  Copyright (c) 2014 Classmate. All rights reserved.
//

#import "CMCustomTaskCell.h"

@implementation CMCustomTaskCell

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
