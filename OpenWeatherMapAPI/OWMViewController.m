//
//  OWMViewController.m
//  OpenWeatherMapAPI
//
//  Created by Adrian Bak on 20/6/13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import "OWMViewController.h"
#import "OWMWeatherAPI.h"

@interface OWMViewController ()

@property OWMWeatherAPI *weatherAPI;
@property NSArray *forecast;
@property NSDateFormatter *dateFormatter;

@property NSInteger downloadCount;

@end

@implementation OWMViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.downloadCount = 0;
    
    NSString *dateComponents = @"H:m yyMMMMd";
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale systemLocale]];
    self.dateFormatter = [NSDateFormatter new];
    self.dateFormatter.dateFormat = dateFormat;
    
    self.forecast = @[];
    
    self.weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"1111111111"]; // Replace the key with your own
    
    // We want localized strings according to the prefered system language
    [self.weatherAPI setLangWithPreferredLanguage];
    
    // We want the temperatures in celcius, you can also get them in farenheit.
    self.weatherAPI.measurementSystem = OWMWeatherMeasurementSystemMetrics;

    [self.activityIndicator startAnimating];
    [self.weatherAPI currentWeatherByCityName:@"Odense" callback:^(NSError *error, NSDictionary *result) {
        self.downloadCount++;
        if (self.downloadCount > 1) {
            [self.activityIndicator stopAnimating];
        }
        
        if (error) {
            // Handle the error
            return;
        }
        
        self.cityName.text = [NSString stringWithFormat:@"%@, %@",
                              result[@"name"],
                              result[@"sys"][@"country"]];
        
        self.currentTemp.text = [NSString stringWithFormat:@"%.1f℃",
                                 [result[@"main"][@"temp"] floatValue]];
        
        self.currentTimestamp.text =  [self.dateFormatter stringFromDate:result[@"dt"]];
        
        self.weather.text = result[@"weather"][0][@"description"];
    }];
    
    [self.weatherAPI forecastWeatherByCityName:@"Odense" callback:^(NSError *error, NSDictionary *result) {
        self.downloadCount++;
        if (self.downloadCount > 1) [self.activityIndicator stopAnimating];
        
        if (error) {
            // Handle the error;
            return;
        }
        
        _forecast = result[@"list"];
        [self.forecastTableView reloadData];
    }];
    
    [self.weatherAPI searchForCityName:@"Buenos Aires" callback:^(NSError *error, NSDictionary *result) {
        NSLog(@"found: %@", result);
    }];
    
}

#pragma mark - TableView DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.forecast.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"SimpleCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:cellIdentifier];
    }
    
    NSDictionary *forecastData = [_forecast objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"%.1f℃ - %@",
                            [forecastData[@"main"][@"temp"] floatValue],
                            forecastData[@"weather"][0][@"main"]];
    cell.detailTextLabel.text = [_dateFormatter stringFromDate:forecastData[@"dt"]];
    
    return cell;
}

@end
