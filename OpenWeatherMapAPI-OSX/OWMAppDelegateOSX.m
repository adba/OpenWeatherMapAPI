//
//  OWMAppDelegate.m
//  OpenWeatherMapAPI-OSX
//
//  Created by rick on 06.08.13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import "OWMAppDelegateOSX.h"
#import "OWMWeatherAPI.h"

@interface OWMAppDelegateOSX ()

@property (nonatomic, strong) OWMWeatherAPI *weatherAPI;

@property (nonatomic, strong) NSDateFormatter *dateFormatter;

@property (weak) IBOutlet NSTextField *cityName;

@property (weak) IBOutlet NSTextField *currentTemp;

@property (weak) IBOutlet NSTextField *currentTimestamp;

@property (weak) IBOutlet NSTextField *weather;

@end


@implementation OWMAppDelegateOSX

- (void)applicationDidFinishLaunching:(NSNotification *)aNotification
{
    NSString *dateComponents = @"H:m yyMMMMd";
    NSString *dateFormat = [NSDateFormatter dateFormatFromTemplate:dateComponents options:0 locale:[NSLocale systemLocale] ];
    _dateFormatter = [[NSDateFormatter alloc] init];
    [_dateFormatter setDateFormat:dateFormat];
    
    
    _weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"1111111111"];
    
    // We want localized strings according to the prefered system language
    [_weatherAPI setLangWithPreferedLanguage];
    
    // We want the temperatures in celcius, you can also get them in farenheit.
    [_weatherAPI setTemperatureFormat:kOWMTempCelcius];
    
    
    [_weatherAPI currentWeatherByCityName:@"Leipzig" withCallback:^(NSError *error, NSDictionary *result) {

        
        if (error) {
            // Handle the error
            return;
        }
        
        self.cityName.stringValue = [NSString stringWithFormat:@"%@, %@",
                              result[@"name"],
                              result[@"sys"][@"country"]
                              ];
        
        self.currentTemp.stringValue = [NSString stringWithFormat:@"%.1f℃",
                                 [result[@"main"][@"temp"] floatValue] ];
        
        self.currentTimestamp.stringValue =  [_dateFormatter stringFromDate:result[@"dt"]];
        
        self.weather.stringValue = result[@"weather"][0][@"description"];
    }];
}

@end
