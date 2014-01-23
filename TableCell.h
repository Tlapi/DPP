//
//  TableCell.h
//  Dpp
//
//  Created by Tlapi on 20/01/14.
//  Copyright (c) 2014 Jan Tlapák. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TableCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *lineNumber;
@property (weak, nonatomic) IBOutlet UILabel *via;
@property (weak, nonatomic) IBOutlet UILabel *direction;
@property (weak, nonatomic) IBOutlet UILabel *departureTimeIn;
@property (weak, nonatomic) IBOutlet UIImageView *lineIcon;

@end
