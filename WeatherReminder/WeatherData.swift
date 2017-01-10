//
//  Api.swift
//  WeatherReminder
//
//  Created by Cassius Chen on 2017/1/10.
//  Copyright © 2017年 Cassius Chen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

class WeatherData {
    static let URL = "https://free-api.heweather.com/v5"
    static let ApiNamespace = "v5"
    static let ApiKey : String = "a5804a55058f44cb8309f95619b7c489"
    static var cityList : [Location] = []
    
    enum ErrorType: Int {
        case unauthorized = 401
        case notFound = 404
        case others = 0
    }
    
    static func request(_ request: URLRequestConvertible, successCallback success: ((JSON?) -> Void)?, failCallback failure: ((ErrorType, JSON?, Error) -> Void)?) {
        Alamofire.request(request)
                 .validate()
            .responseJSON(completionHandler: {(response) in
                debugPrint(response)
                switch response.result {
                case .success :
                    if let value = response.result.value {
                        success?(JSON(value))
                    } else {
                        success?(nil)
                    }
                case .failure(let error) :
                    let errorType = ErrorType(rawValue: response.response?.statusCode ?? 0) ?? .others
                    if let value = response.data {
                        failure?(errorType, JSON(data: value), error)
                    } else {
                        failure?(errorType, nil, error)
                    }
                }
            })
    }
    
    struct Location {
        var cityName : String
        var provinceName : String
        var locationId : String
    }
    
    init() {
        loadCityList()
    }
    
    func loadCityList() {
        let path : String = Bundle.main.path(forResource: "CityList", ofType: "Json")!
        let nsUrl = NSURL(fileURLWithPath: path)
        let nsData : NSData = NSData(contentsOf: nsUrl as URL)!
        
        let json = JSON(data: nsData as Data)
        
        for (_, subJson) : (String, JSON) in json {
            let newCityInfo : Location = Location(cityName: subJson["cityZh"].string!, provinceName: subJson["provinceZh"].string!, locationId: subJson["id"].string!)
            WeatherData.cityList.append(newCityInfo)
        }
    }
    
}


// 和风天气 API 服务路由
enum ApiEndpoint : URLRequestConvertible {
    static let baseURL = WeatherData.URL
    
    case currentWeather(String)
    case futureWeather(String)
    
    var method : Alamofire.HTTPMethod {
        switch self {
        case .currentWeather(_), .futureWeather(_):
            return .get
        }
    }
    
    var path : String {
        switch self {
        case .currentWeather(_):
            return "/now"
        case .futureWeather(_):
            return "/forecast"
        }
    }
    
    var parameters : Parameters {
        switch self {
        case .currentWeather(let city):
            return ["city": city, "key": WeatherData.ApiKey]
        case .futureWeather(let city):
            return ["city": city, "key": WeatherData.ApiKey]
        default:
            return ["city": "北京", "key": WeatherData.ApiKey]
        }
    }
    
    // MARK: URLRequestConvertible
    func asURLRequest() throws -> URLRequest {
        let result: (path: String, parameters: Parameters) = (path, parameters)
        
        let url = try ApiEndpoint.baseURL.asURL()
        var urlRequest = URLRequest(url: url.appendingPathComponent(result.path))
        urlRequest.httpMethod = method.rawValue
        
        switch self {
        case .currentWeather, .futureWeather:
            urlRequest = try URLEncoding.default.encode(urlRequest, with: parameters)
        default:
            break
        }
        
        return urlRequest
    }
}
