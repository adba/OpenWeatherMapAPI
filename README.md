# Open Weather Map iOS Api #

This projects allows you to quickly and easily fetch data
from [openweathermap.org](http://openweathermap.org/ "OpenWeatherMap.org").

## Usage ##

### Installation ###

1. Include the header `#import "OWMWeatherAPI.h"`.
2. Setup the api:
    
        // Setup weather api
        OWMWeatherAPI *weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"YOUR-API-KEY"];


3. Select the default temperature format (defaults to Celcius)
    [weatherAPI setTemperatureFormat:kOWMTempCelcius];


### Getting data ###

The api is at this time just simple wrapper for the http-api. So to get the current weather for
the city [`Odense`](http://en.wikipedia.org/wiki/Odense "Odense") you can call it like this:

    [weatherAPI currentWeatherByCityName:@"Odense" withCallback:^(NSError *error, NSDictionary *result) {
        if (error) {
            // handle the error
            return;
        }

        // The data is ready

        NSString *cityName = result[@"name"];
        NSNumber *currentTemp = result[@"main"][@"temp"];

    }]

The result data is a `NSDictionary` that looks like 
this ([json](http://api.openweathermap.org/data/2.5/weather?q=Odense "JSON data")):
    
    {
        coord: {
            lon: 10.38831,
            lat: 55.395939
        },
        sys: {
            country: "DK",
            sunrise: 1371695759, // this is an NSDate
            sunset: 1371758660   // this is also converted to a NSDate
        },
        weather: [
            {
                id: 800,
                main: "Clear",
                description: "Sky is Clear",
                icon: "01d"
            }
        ],
        base: "global stations",
        main: {
            temp: 295.006,      // this is the the temperature format you´ve selected
            temp_min: 295.006,  //                 --"--
            temp_max: 295.006,  //                 --"--
            pressure: 1020.58,
            sea_level: 1023.73,
            grnd_level: 1020.58,
            humidity: 80
        },
        wind: {
            speed: 6.47,
            deg: 40.0018
        },
        clouds: {
            all: 0
        },
        dt: 1371756382,
        id: 2615876,
        name: "Odense",
        cod: 200
    }

See an example in the `OWMViewController.m` file.

## Methods ##
The following methods are availabe at this time:

current weather by city name:

    -(void) currentWeatherByCityName:(NSString *) name
                        withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;


current weather by coordinate:

    -(void) currentWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                          withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

current weather by city id:

    -(void) currentWeatherByCityId:(NSString *) cityId
                      withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;


forcast by city name:

    -(void) forecastWeatherByCityName:(NSString *) name
                         withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

forcast by coordinate:

    -(void) forecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                           withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

forcast by city id:

    -(void) forecastWeatherByCityId:(NSString *) cityId
                       withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

