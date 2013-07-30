//
//  OWMViewController.m
//  OpenWeatherMapAPI
//
//  Created by Adrian Bak on 20/6/13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import "OWMViewController.h"
#import "OWMWeatherAPI.h"

@interface OWMViewController () {
    OWMWeatherAPI *_weatherAPI;
    NSArray *_forecast;
    NSDateFormatter *_dateFormatter;
    
    int downloadCount;
    
}
@end

@implementation OWMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    downloadCount = 0;
    
    NSString *dateComponents = @"H:m yyMMMMd";
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale systemLocale] ];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:dateFormat];
    
    _forecast = @[];
    
    _weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"1111111111"]; // Replace the key with your own
    
    // We want localized strings according to the prefered system language
    [_weatherAPI setLangWithPreferedLanguage];
    
    // We want the temperatures in celcius, you can also get them in farenheit.
    [_weatherAPI setTemperatureFormat:kOWMTempCelcius];

    [self.activityIndicator startAnimating];
    
    [_weatherAPI currentWeatherByCityName:@"Odense" withCallback:^(NSError *error, NSDictionary *result) {
        downloadCount++;
        if (downloadCount > 1) [self.activityIndicator stopAnimating];
        
        if (error) {
            // Handle the error
            return;
        }
        
        self.cityName.text = [NSString stringWithFormat:@"%@, %@",
                              result[@"name"],
                              result[@"sys"][@"country"]
                              ];
        
        self.currentTemp.text = [NSString stringWithFormat:@"%.1f℃",
                                 [result[@"main"][@"temp"] floatValue] ];
        
        self.currentTimestamp.text =  [_dateFormatter stringFromDate:result[@"dt"]];
        
        self.weather.text = result[@"weather"][0][@"description"];
    }];
    
    [_weatherAPI forecastWeatherByCityName:@"Odense" withCallback:^(NSError *error, NSDictionary *result) {
        downloadCount++;
        if (downloadCount > 1) [self.activityIndicator stopAnimating];        
        
        if (error) {
            // Handle the error;
            return;
        }
        
        _forecast = result[@"list"];
        [self.forecastTableView reloadData];
        
    }];
    
    [_weatherAPI searchForCityName:@"Buenos Aires" withCallback:^(NSError *error, NSDictionary *result) {
        NSLog(@"found: %@", result);
    }];
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - tableview datasource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _forecast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell"];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:@"Cell"];
    }
    
    NSDictionary *forecastData = [_forecast objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%.1f℃ - %@",
                            [forecastData[@"main"][@"temp"] floatValue],
                            forecastData[@"weather"][0][@"main"]
                           ];

    cell.detailTextLabel.text = [_dateFormatter stringFromDate:forecastData[@"dt"]];
    
    return cell;
    
}

@end
