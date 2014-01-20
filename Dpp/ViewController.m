//
//  ViewController.m
//  Dpp
//
//  Created by Jan Tlapák on 19/01/14.
//  Copyright (c) 2014 Jan Tlapák. All rights reserved.
//

#import "ViewController.h"
#import "GMDirectionService.h"

@interface ViewController () <CLLocationManagerDelegate>

@end

@implementation ViewController

@synthesize locationManager;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"View did load");
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    //[self.locationManager startUpdatingLocation];
	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)okButtonClicked:(id)sender
{
    [self.view endEditing:YES];
    self.resultView.text = @"loading";
    [self.locationManager startUpdatingLocation];
}

- (void)locationManager:(CLLocationManager *)manager
    didUpdateToLocation:(CLLocation *)newLocation
           fromLocation:(CLLocation *)oldLocation
{
    NSLog(@"LAT: %f", newLocation.coordinate.latitude);
    NSLog(@"LON: %f", newLocation.coordinate.longitude);
    
    NSString* origin = [[NSString stringWithFormat:@"%f,%f", newLocation.coordinate.latitude, newLocation.coordinate.longitude] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    NSString* destination = [[NSString stringWithFormat:@"%@, Praha", self.queryInput.text] stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    
    [[GMDirectionService sharedInstance] getDirectionsFrom:origin to:destination succeeded:^(GMDirection *directionResponse) {
        if ([directionResponse statusOK]){
            //NSLog(@"Legs : %@", [directionResponse legs]);
            //NSLog(@"Duration : %@", [directionResponse durationHumanized]);
            //NSLog(@"Distance : %@", [directionResponse distanceHumanized]);
            
            //NSDictionary *leg = [directionResponse firstLeg];
            
            for (id leg in [directionResponse legs]) {
                
                self.resultView.text = @"";
                
                self.resultView.text = [self.resultView.text stringByAppendingString:[NSString stringWithFormat:@"DURATION: %@", [[leg objectForKey:@"duration"] objectForKey:@"text"]]];
                
                self.resultView.text = [self.resultView.text stringByAppendingString:[NSString stringWithFormat:@"\n\nLEG STEPS:\n\n"]];
                
                NSArray* steps = [leg objectForKey:@"steps"];
                
                for (id object in steps) {
                    // do something with object
                    //NSLog(@"STEP");
                    //NSLog(@"%@", object);
                    
                    NSString* travelMode = [object objectForKey:@"travel_mode"];
                    
                    self.resultView.text = [self.resultView.text stringByAppendingString:[NSString stringWithFormat:@"%@\n", [object objectForKey:@"html_instructions"]]];
                    
                    if([travelMode isEqualToString:@"TRANSIT"]){
                        self.resultView.text = [self.resultView.text stringByAppendingString:[NSString stringWithFormat:@"%@ | ODJEZD: %@\n",
                                                                                              [[[object objectForKey:@"transit_details"] objectForKey:@"departure_time"] objectForKey:@"text"],
                                                                                              [[[object objectForKey:@"transit_details"] objectForKey:@"departure_stop"] objectForKey:@"name"]
                                                                                              ]];
                        self.resultView.text = [self.resultView.text stringByAppendingString:[NSString stringWithFormat:@"LINKA: %@\n", [[[object objectForKey:@"transit_details"] objectForKey:@"line"] objectForKey:@"short_name"]]];
                        self.resultView.text = [self.resultView.text stringByAppendingString:[NSString stringWithFormat:@"%@ | PŘÍJEZD: %@\n",
                                                                                              [[[object objectForKey:@"transit_details"] objectForKey:@"arrival_time"] objectForKey:@"text"],
                                                                                              [[[object objectForKey:@"transit_details"] objectForKey:@"arrival_stop"] objectForKey:@"name"]
                                                                                              ]];
                    }
                    if([travelMode isEqualToString:@"WALKING"]){
                        self.resultView.text = [self.resultView.text stringByAppendingString:[NSString stringWithFormat:@"DOBA CHŮZE: %@\n", [[object objectForKey:@"duration"] objectForKey:@"text"]]];
                    }
                    
                    self.resultView.text = [self.resultView.text stringByAppendingString:[NSString stringWithFormat:@"\n"]];
                }
                    
            }
            
            self.resultView.text = [self.resultView.text stringByAppendingString:[NSString stringWithFormat:@"\n\n\n"]];
        }
    } failed:^(NSError *error) {
        NSLog(@"%@", error);
        NSLog(@"Can't reach the server");
    }];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)dealloc
{
    [self.locationManager stopUpdatingLocation];
}

@end
