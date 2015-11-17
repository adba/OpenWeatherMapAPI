//
//  OWMWeatherAPI.h
//  OpenWeatherMapAPI
//
//  Created by Adrian Bak on 20/6/13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

typedef NS_ENUM(NSUInteger, OWMWeatherMeasurementSystem) {
    OWMWeatherMeasurementSystemMetrics,
    OWMWeatherMeasurementSystemImperial
};

typedef void (^OWMWeatherAPICallback)(NSError* error, NSDictionary *result);

@interface OWMWeatherAPI : NSObject

/**
 * Creates API helper instance with speciefied API-key.
 * @param APIKey Represents key used for access to API. http://openweathermap.org/appid
 **/
- (instancetype)initWithAPIKey:(NSString *)APIKey;

/**
 * Represents key currently used for request.
 */
@property (nonatomic, readonly) NSString *APIKey;

/**
 * Indicates version currently used for requests.
 */
@property (nonatomic, readonly) NSString *APIVersion;

/**
 * Indicates how dates will be represented. If 'YES' NSDate will be used in callbacks. By default 'NO'.
 */
@property (nonatomic) BOOL shouldConvertDates;

/**
 * Shows which measurement system will used in server responses.
 */
@property (nonatomic) OWMWeatherMeasurementSystem measurementSystem;

/**
 * Shows lang used for forecast weather conditions.
 */
@property (nonatomic) NSString *lang;

/**
 * Sets lang according to current user device settings.
 **/
- (void)setLangWithPreferredLanguage;

#pragma mark - Current weather

- (void)currentWeatherByCityName:(NSString *)name
                        callback:(OWMWeatherAPICallback)callback;

- (void)currentWeatherByCoordinate:(CLLocationCoordinate2D)coordinate
                          callback:(OWMWeatherAPICallback)callback;

- (void)currentWeatherByCityID:(NSString *)cityID
                      callback:(OWMWeatherAPICallback)callback;

#pragma mark - Forecast

- (void)forecastWeatherByCityName:(NSString *)name
                         callback:(OWMWeatherAPICallback)callback;

- (void)forecastWeatherByCoordinate:(CLLocationCoordinate2D)coordinate
                           callback:(OWMWeatherAPICallback)callback;

- (void)forecastWeatherByCityID:(NSString *)cityID
                       callback:(OWMWeatherAPICallback)callback;

#pragma mark - Forecast for n days

- (void)dailyForecastWeatherByCityName:(NSString *)name
                             withCount:(NSInteger)count
                              callback:(OWMWeatherAPICallback)callback;

- (void)dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D)coordinate
                               withCount:(NSInteger)count
                                callback:(OWMWeatherAPICallback)callback;

- (void)dailyForecastWeatherByCityID:(NSString *)cityID
                           withCount:(NSInteger)count
                            callback:(OWMWeatherAPICallback)callback;

#pragma mark - Search

- (void)searchForCityName:(NSString *)name
                 callback:(OWMWeatherAPICallback)callback;

- (void)searchForCityName:(NSString *)name
                withCount:(NSInteger)count
                 callback:(OWMWeatherAPICallback)callback;

#pragma mark - Core

/**
 * Calls the web API and converts the result. Then it calls the callback on the caller-queue.
 * @param method URL's path.
 * @param params Represents key-value pairs fo request.
 * @param callback Completion block.
 * @warning Should only be used to extend the functionality.
 **/
- (void)callMethod:(NSString *)method
        withParams:(NSDictionary *)params
          callback:(void (^)(NSError *error, NSDictionary *result))callback;

@end
