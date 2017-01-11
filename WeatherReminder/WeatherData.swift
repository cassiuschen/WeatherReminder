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
    static let ApiKey : String = "a5804a55058f44cb8309f95619b7c489"
    static var cityList : [Location] = []
    
    private var locationInfoStruct : Location = Location()
    var locationInfo : Location {
        get {
            return locationInfoStruct
        }
        set {
            print(newValue)
        }
    }
    
    enum ErrorType: Int {
        case unauthorized = 401
        case notFound = 404
        case others = 0
    }
    
    private static func request(_ request: URLRequestConvertible, successCallback success: ((JSON?) -> Void)?, failCallback failure: ((ErrorType, JSON?, Error) -> Void)?) {
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
        var cityName : String = ""
        var provinceName : String = ""
        var locationId : String = ""
    }
    
    init() {
        loadCityList()
    }
    
    private func loadCityList() {
        let path : String = Bundle.main.path(forResource: "CityList", ofType: "json")!
        let nsUrl = NSURL(fileURLWithPath: path)
        let nsData : NSData = NSData(contentsOf: nsUrl as URL)!
        
        let json = JSON(data: nsData as Data)
        
        for (_, subJson) : (String, JSON) in json {
            let newCityInfo : Location = Location(cityName: subJson["cityZh"].string!, provinceName: subJson["provinceZh"].string!, locationId: subJson["id"].string!)
            WeatherData.cityList.append(newCityInfo)
        }
    }
    
    func findCity(province provName: String, city cityName: String) {
        let data = ["province": removeLocationSuffix(string: provName), "city": removeLocationSuffix(string: cityName)]
        let searchResult = WeatherData.cityList.first(where: { $0.provinceName == data["province"] && $0.cityName == data["city"]})
        
        if searchResult != nil {
            self.locationInfo = searchResult!
        } else {
            self.locationInfo.locationId = data["city"]!
        }
    }
    
    private func removeLocationSuffix(string rawStr: String) -> String {
        var str = rawStr
        if (str.characters.last == "区" || str.characters.last == "市" || str.characters.last == "省") {
            str.remove(at: str.index(before: str.endIndex))
        }
        
        return str
    }
}
