//
//  OWMWeatherAPI.m
//  OpenWeatherMapAPI
//
//  Created by Adrian Bak on 20/6/13.
//  Copyright (c) 2013 Adrian Bak. All rights reserved.
//

#import "OWMWeatherAPI.h"
#import "AFJSONRequestOperation.h"

NSString *const OWMWeatherAPIBaseURL = @"http://api.openweathermap.org/data";
NSString *const OWMWeatherAPIDefaultVersion = @"2.5";
NSString *const OWMWeatherAPIQueueName = @"OMWWeatherQueue";

@interface OWMWeatherAPI ()

@property (nonatomic) NSString *baseURL;
@property (nonatomic) NSString *APIKey;
@property (nonatomic) NSString *APIVersion;

@property (nonatomic) NSOperationQueue *weatherQueue;

@end

@implementation OWMWeatherAPI

- (instancetype)initWithAPIKey:(NSString *)APIKey
{
    self = [super init];
    if (self) {
        _baseURL = OWMWeatherAPIBaseURL;
        _APIKey = APIKey;
        _APIVersion = OWMWeatherAPIDefaultVersion;
    
        _weatherQueue = [NSOperationQueue new];
        _weatherQueue.name = OWMWeatherAPIQueueName;
        
        _measurementSystem = OWMWeatherMeasurementSystemMetrics;
    }
    return self;
}

#pragma mark - Helpers

- (NSDate *)convertToDate:(NSNumber *)timestamp
{
    return [NSDate dateWithTimeIntervalSince1970:timestamp.integerValue];
}

#pragma mark - Private Parts

/**
 * Recursivly change timestamps to dates in response data.
 **/
- (NSDictionary *)convertDates:(NSDictionary *)data
{
    NSMutableDictionary *dictionary = [data mutableCopy];
    NSMutableDictionary *sys = [dictionary[@"sys"] mutableCopy];
    if (sys) {
        sys[@"sunrise"] = [self convertToDate:sys[@"sunrise"]];
        sys[@"sunset"] = [self convertToDate:sys[@"sunset"]];
        dictionary[@"sys"] = [sys copy];
    }
    
    NSMutableArray *list = [dictionary[@"list"] mutableCopy];
    if (list) {
        for (NSInteger index = 0; index < list.count; index++) {
            NSDictionary *dictionary = list[index];
            NSDictionary *convertedDictionary = [self convertDates:dictionary];
            [list replaceObjectAtIndex:index withObject:convertedDictionary];
        }
        dictionary[@"list"] = [list copy];
    }
    dictionary[@"dt"] = [self convertToDate:dictionary[@"dt"]];

    return [dictionary copy];
}

- (void)callMethod:(NSString *)method
        withParams:(NSDictionary *)params
          callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSOperationQueue *callerQueue = [NSOperationQueue currentQueue];
    NSMutableDictionary *requestParams = [[NSMutableDictionary alloc] initWithDictionary:params];
    
    // Add metics parameter.
    NSString *units = (self.measurementSystem == OWMWeatherMeasurementSystemMetrics) ? @"metric" : @"imperial";
    requestParams[@"units"] = units;
    
    // Add language parameter.
    if (self.lang.length) {
        requestParams[@"lang"] = self.lang;
    }
    
    // Add API key parameter.
    if (self.APIKey.length) {
        requestParams[@"APIID"] = self.APIKey;
    }
    
    // Combine parameters to string.
    NSMutableArray *keyValuePairs = [NSMutableArray new];
    for (NSString *key in requestParams) {
        id value = requestParams[key];
        if ([value isKindOfClass:[NSString class]]) {
            value = [value stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        }
        NSString *keyValue = [NSString stringWithFormat:@"%@=%@", key, value];
        [keyValuePairs addObject:keyValue];
    }
    NSString *parametersString = [keyValuePairs componentsJoinedByString:@"&"];
    
    // Generate URL.
    NSString *urlString = [NSString stringWithFormat:@"%@/%@/%@", self.baseURL, self.APIVersion, method];
    if (parametersString.length) {
        urlString = [urlString stringByAppendingFormat:@"?%@", parametersString];
    }
    NSURL *url = [NSURL URLWithString:urlString];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    
    // Send request and handle response.
    AFJSONRequestOperation *operation = [AFJSONRequestOperation JSONRequestOperationWithRequest:request success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (self.shouldConvertDates) {
            JSON = [self convertDates:JSON];
        }
        [callerQueue addOperationWithBlock:^{
            callback(nil, JSON);
        }];
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        [callerQueue addOperationWithBlock:^{
            callback(error, nil);
        }];
    }];
    [self.weatherQueue addOperation:operation];
}

#pragma mark - Public API

- (void)setLangWithPreferredLanguage
{
    NSString *preferedLanguage = [[NSLocale preferredLanguages] objectAtIndex:0];
    
    // Convert lang to the format that openweathermap.org accepts.
    NSDictionary *langCodes = @{@"sv" : @"se",
                                @"es" : @"sp",
                                @"en-GB": @"en",
                                @"uk" : @"ua",
                                @"pt-PT" : @"pt",
                                @"zh-Hans" : @"zh_cn",
                                @"zh-Hant" : @"zh_tw"};
    NSString *specialOWMLanguageCode = [langCodes objectForKey:preferedLanguage];
    if (specialOWMLanguageCode) {
        preferedLanguage = specialOWMLanguageCode;
    }
    
    self.lang = preferedLanguage;
}

#pragma mark - Current Weather

- (void)currentWeatherByCityName:(NSString *)name
                        callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"q"] = name;
    [self callMethod:@"weather" withParams:params callback:callback];
}

- (void)currentWeatherByCoordinate:(CLLocationCoordinate2D)coordinate
                          callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"lat"] = @(coordinate.latitude);
    params[@"lon"] = @(coordinate.longitude);
    [self callMethod:@"weather" withParams:params callback:callback];
}

- (void)currentWeatherByCityID:(NSString *)cityID
                      callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"id"] = cityID;
    [self callMethod:@"weather" withParams:params callback:callback];
}


#pragma mark - Forecast

- (void)forecastWeatherByCityName:(NSString *)name
                         callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"q"] = name;
    [self callMethod:@"forecast" withParams:params callback:callback];
}

- (void)forecastWeatherByCoordinate:(CLLocationCoordinate2D)coordinate
                           callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"lat"] = @(coordinate.latitude);
    params[@"lon"] = @(coordinate.longitude);
    [self callMethod:@"forecast" withParams:params callback:callback];
}

- (void)forecastWeatherByCityID:(NSString *)cityID
                       callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"id"] = cityID;
    [self callMethod:@"forecast" withParams:params callback:callback];
}

#pragma mark - Forcast for n days

- (void)dailyForecastWeatherByCityName:(NSString *)name
                             withCount:(NSInteger)count
                              callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"q"] = name;
    params[@"cnt"] = @(count);
    [self callMethod:@"forecast/daily" withParams:params callback:callback];
}

- (void)dailyForecastWeatherByCoordinate:(CLLocationCoordinate2D)coordinate
                               withCount:(NSInteger)count
                                callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"lat"] = @(coordinate.latitude);
    params[@"lon"] = @(coordinate.longitude);
    params[@"cnt"] = @(count);
    [self callMethod:@"forecast/daily" withParams:params callback:callback];
}

- (void)dailyForecastWeatherByCityID:(NSString *)cityID
                           withCount:(NSInteger)count
                            callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"id"] = cityID;
    params[@"cnt"] = @(count);
    [self callMethod:@"forecast/daily" withParams:params callback:callback];
}

#pragma mark - Search

-(void)searchForCityName:(NSString *)name
                callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"q"] = name;
    [self callMethod:@"find" withParams:params callback:callback];
}

- (void)searchForCityName:(NSString *)name
                withCount:(NSInteger)count
                 callback:(void (^)(NSError *error, NSDictionary *result))callback
{
    NSMutableDictionary *params = [NSMutableDictionary new];
    params[@"q"] = name;
    params[@"cnt"] = @(count);
    [self callMethod:@"find" withParams:params callback:callback];
}

@end

