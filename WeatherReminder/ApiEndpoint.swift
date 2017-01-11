//
//  ApiEndpoint.swift
//  WeatherReminder
//
//  Created by Cassius Chen on 2017/1/11.
//  Copyright © 2017年 Cassius Chen. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
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
