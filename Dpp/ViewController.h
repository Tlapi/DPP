//
//  ViewController.h
//  Dpp
//
//  Created by Jan Tlapák on 19/01/14.
//  Copyright (c) 2014 Jan Tlapák. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface ViewController : UIViewController

@property (weak, nonatomic) IBOutlet UITextView *resultView;
@property (weak, nonatomic) IBOutlet UITextField *queryInput;
@property (weak, nonatomic) IBOutlet UIButton *okButton;

@property (nonatomic, retain) CLLocationManager *locationManager;

- (IBAction)okButtonClicked:(id)sender;

@end
