//
//  ViewController.m
//  Dpp
//
//  Created by Jan Tlapák on 19/01/14.
//  Copyright (c) 2014 Jan Tlapák. All rights reserved.
//

#import "ViewController.h"
#import "GMDirectionService.h"
#import "TFHpple.h"

@interface ViewController () <CLLocationManagerDelegate,UITableViewDataSource,UITableViewDelegate>

@end

@implementation ViewController

@synthesize locationManager;

bool called = false;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"View did load");
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    self.locationManager.delegate = self;
    
    NSLog(@"%@", [self getCurrentTimetableForStaion:@"Maniny"]);
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
    if(called==false){
        called = true;
        [self.locationManager stopUpdatingLocation];
        NSLog(@"LAT: %f", newLocation.coordinate.latitude);
        NSLog(@"LON: %f", newLocation.coordinate.longitude);
        
        NSString *path = [[NSBundle mainBundle] pathForResource:@"stops" ofType:@"plist"];
        NSDictionary *stops = [NSDictionary dictionaryWithContentsOfFile:path];
        
        //NSMutableDictionary *stopDeltas = [[NSMutableDictionary alloc] init];
        NSMutableArray *stopDeltasStops = [[NSMutableArray alloc] init];
        NSMutableArray *stopsRegistered = [[NSMutableArray alloc] init];
        //[stopDeltas setObject:stopDeltasStops forKey:@"stops"];
        
        // Get closest stop
        for (NSDictionary *stop in [stops objectForKey:@"Stops"]) {
            //NSLog(@"%@", stop);
            //[[stop objectForKey:@"stop_lat"] floatValue]
            float delta = fabsf(newLocation.coordinate.latitude - [[stop objectForKey:@"stop_lat"] floatValue]) + fabsf(newLocation.coordinate.longitude - [[stop objectForKey:@"stop_lon"] floatValue]);
            //NSLog(@"%f", delta);
            
            if(delta < 0.005){ // filter stations closer than 0.005 delta
                if(![stopsRegistered containsObject:[stop objectForKey:@"stop_name"]]){ // filter duplicate station names
                    NSMutableDictionary *deltaStop = [[NSMutableDictionary alloc] initWithDictionary:stop];
                    [deltaStop setObject:[NSNumber numberWithFloat:delta] forKey:@"delta"];
                    [stopDeltasStops addObject:deltaStop];
                    [stopsRegistered addObject:[stop objectForKey:@"stop_name"]];
                }
            }
        }
        
        NSSortDescriptor *deltaDescriptor = [[NSSortDescriptor alloc] initWithKey:@"delta" ascending:YES];
        NSArray *sortDescriptors = [NSArray arrayWithObject:deltaDescriptor];
        // sort stations by closest
        NSArray *sortedArray = [stopDeltasStops sortedArrayUsingDescriptors:sortDescriptors];
        
        NSLog(@"%@", sortedArray);
        
        // Get timetables for each station
        
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
    }
}

- (NSMutableArray*)getCurrentTimetableForStaion:(NSString*)station
{
    AFHTTPClient *client = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:@"http://spojeni.dpp.cz/"]];
    //[client setDefaultHeader:@"X-Parse-Application-Id" value:@"Q82knolRSmsGKKNK13WCvISIReVVoR3yFP3qTF1J"];
    //[client setDefaultHeader:@"X-Parse-REST-API-Key" value:@"iHiN4Hlw835d7aig6vtcTNhPOkNyJpjpvAL2aSoL"];
    [client registerHTTPOperationClass:[AFJSONRequestOperation class]];
    
    NSDate *currDate = [NSDate date];
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc]init];
    [dateFormatter setDateFormat:@"d.M.YYYY"];
    NSString *dateString = [dateFormatter stringFromDate:currDate];
    [dateFormatter setDateFormat:@"HH"];
    NSString *timeString = [dateFormatter stringFromDate:currDate];
    
    NSMutableArray *response = [[NSMutableArray alloc] init];
    
    NSLog(@"URL %@", [NSString stringWithFormat:@"DepForm.aspx?date=%@&time=14%%3a08&from=Maniny%%7c30103%%7c1739&isdep=1&sp=0&combidabs=UElEXDAwODNiMmY4YThiNjQ5OWY4N2NjZjhkY2M1NWEwZjg0IzU-&reftime=%@%%3a00", dateString, timeString]);
    
    [client getPath:[NSString stringWithFormat:@"DepForm.aspx?date=%@&time=14%%3a08&from=Maniny%%7c30103%%7c1739&isdep=1&sp=0&combidabs=UElEXDAwODNiMmY4YThiNjQ5OWY4N2NjZjhkY2M1NWEwZjg0IzU-&reftime=%@%%3a00", dateString, timeString]
         parameters:nil
            success:^(AFHTTPRequestOperation *operation, id responseObject) {
                //NSLog(@"Success %@", operation.responseString);
                
                TFHpple *doc       = [[TFHpple alloc] initWithHTMLData:operation.responseData];
                NSArray *elements  = [doc searchWithXPathQuery:@"//div[@id='column-vypis']/table/tr"];
                
                //NSLog(@"%@", elements);
                
                for (TFHppleElement *element in elements) {
                    //NSLog(@"%@", [element childrenWithTagName:@"td"]);
                    
                    NSArray *timetableCols = [element childrenWithTagName:@"td"];
                    int i = 0;
                    NSMutableDictionary *timetable = [[NSMutableDictionary alloc] init];
                    for (TFHppleElement *column in timetableCols) {
                        if(i==0){
                            [timetable setObject:[column text] forKey:@"dep_time"];
                        }
                        if(i==1){
                            [timetable setObject:[[column firstChildWithTagName:@"p" ] text] forKey:@"destination"];
                        }
                        if(i==3){
                            [timetable setObject:[[column firstChildWithTagName:@"a" ] text] forKey:@"line"];
                        }
                        i++;
                    }
                    NSLog(@"%@", timetable);
                    [response addObject:timetable];
                    //NSMutableDictionary *timetable = [[NSMutableDictionary alloc] init];
                    
                    //[element childrenWithTagName:@"td"];
                }
                
            } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
                NSLog(@"Failed %@", error);
            }];
    
    return response;
}

- (void)dealloc
{
    [self.locationManager stopUpdatingLocation];
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;    //count of section
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 1;    //count number of row from counting array hear cataGorry is An Array
}



- (UITableViewCell *)tableView:(UITableView *)tableView
         cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *MyIdentifier = @"Cell";
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:MyIdentifier];
    
    if (cell == nil)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                       reuseIdentifier:MyIdentifier];
    }
    
    // Here we use the provided setImageWithURL: method to load the web image
    // Ensure you use a placeholder image otherwise cells will be initialized with no image
    /*
    [cell.imageView setImageWithURL:[NSURL URLWithString:@"http://example.com/image.jpg"]
                   placeholderImage:[UIImage imageNamed:@"placeholder"]];
    cell.textLabel.text = @"My Text";*/
    return cell;
}

@end
