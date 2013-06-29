<center>![OpenWeatherMapAPI](https://raw.github.com/adba/OpenWeatherMapAPI/master/hero.png)</center>

# Open Weather Map iOS API #

This projects allows you to quickly and easily fetch data
from [openweathermap.org](http://openweathermap.org/ "OpenWeatherMap.org").

## API Changes ##

### Version 0.0.5 ###

The methods for getting the daily forecast have changed names. So instead of: `dailyForecastWeatherByCityName:withCount:withCallback:`
they are now called: `dailyForecastWeatherByCityName:withCount:andCallback:`

Added new methods for setting the `lang` parameter to the api:
    
     - (void) setLangWithPreferedLanguage;
     - (void) setLang:(NSString *) lang;
     - (NSString *) lang;

The method `setLangWithPreferedLanguage` sets the lang parameter according to the prefered language on the phone.

## Usage ##

### Installation ###

Using the API is really simple if you have [CocoaPods](http://cocoapods.org/ "CocoaPods.org") installed.

1. Add the dependency to your `Podfile`
    
    ```Ruby
    pod 'OpenWeatherMapAPI', '~> 0.0.4'
    ```

2. Include the header `#import "OWMWeatherAPI.h"`.
3. Setup the api:
    
    ```Objective-c
    // Setup weather api
    OWMWeatherAPI *weatherAPI = [[OWMWeatherAPI alloc] initWithAPIKey:@"YOUR-API-KEY"];
    ```

4. Select the default temperature format (defaults to Celsius)

    ```Objective-c
    [weatherAPI setTemperatureFormat:kOWMTempCelcius];
    ```

### Getting data ###

The api is at this time just simple wrapper for the http-api. So to get the current weather for
the city [`Odense`](http://en.wikipedia.org/wiki/Odense "Odense") you can call it like this:

```Objective-c
[weatherAPI currentWeatherByCityName:@"Odense" withCallback:^(NSError *error, NSDictionary *result) {
    if (error) {
        // handle the error
        return;
    }

    // The data is ready

    NSString *cityName = result[@"name"];
    NSNumber *currentTemp = result[@"main"][@"temp"];

}]
```

The result data is a `NSDictionary` that looks like 
this ([json](http://api.openweathermap.org/data/2.5/weather?q=Odense "JSON data")):

```JavaScript
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
```

See an example in the `OWMViewController.m` file.

## Methods ##
The following methods are availabe at this time:

### current weather ###

current weather by city name:
```Objective-c
    -(void) currentWeatherByCityName:(NSString *) name
                        withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;
```

current weather by coordinate:
```Objective-c
    -(void) currentWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                          withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;
```

current weather by city id:
```Objective-c
    -(void) currentWeatherByCityId:(NSString *) cityId
                      withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;
```

### forecasts (3 hour intervals) ###

forecast by city name:
```Objective-c
    -(void) forecastWeatherByCityName:(NSString *) name
                         withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;
```

forecast by coordinate:
```Objective-c
    -(void) forecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                           withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;
```

forecast by city id:
```Objective-c
    -(void) forecastWeatherByCityId:(NSString *) cityId
                       withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;
```

### daily forecasts ###

daily forecast by city name:
```Objective-c
    -(void) dailyForecastWeatherByCityName:(NSString *) name
                                 withCount:(int) count
                              withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;
```

daily forecast by coordinates:
```Objective-c
    -(void) dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D) coordinate
                                   withCount:(int) count
                                withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;

```

daily forecast by city id:
```Objective-c
   -(void) dailyForecastWeatherByCityId:(NSString *) cityId
                              withCount:(int) count
                           withCallback:( void (^)( NSError* error, NSDictionary *result ) )callback;
```
