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
            debugPrint(newValue)
            locationInfoStruct = newValue
            getCurrentWeatherData()
        }
    }
    
    enum ErrorType: Int {
        case unauthorized = 401
        case notFound = 404
        case others = 0
    }
    
    // 天气状况及其代号，基于和风天气的文档：http://www.kancloud.cn/hefengyun/weather/224292 有少许修改
    enum WeatherCondition: Int {
        case sunny = 100
        case cloudy = 101
        case fewClouds = 102
        case partlyCloudy = 103
        case overcast = 104
        case windy = 200
        case calm = 201
        case lightBreeze = 202
        case moderate = 203
        case freshBreeze = 204
        case strongBreeze = 205
        case highWind = 206
        case gale = 207
        case strongGale = 208
        case storm = 209
        case violentStorm = 210
        case hurricane = 211
        case tornado = 212
        case tropicalStorm = 213
        case showerRain = 300
        case heavyShowerRain = 301
        case thundershower = 302
        case heavyThunderstorm = 303
        case hail = 304
        case lightRain = 305
        case moderateRain = 306
        case heavyRain = 307
        case extremeRain = 308
        case drizzleRain = 309
        case stormRain = 310
        case heavyStorm = 311
        case severeStorm = 312
        case freezingRain = 313
        case lightSnow = 400
        case moderateSnow = 401
        case heavySnow = 402
        case snowstorm = 403
        case sleet = 404
        case rainAndSnow = 405
        case showerSnow = 406
        case snowFlurry = 407
        case mist = 500
        case foggy = 501
        case haze = 502
        case sand = 503
        case dust = 504
        case duststorm = 507
        case sandstorm = 508
        case hot = 900
        case cold = 901
        case unknown = 999
    }
    
    static let WeatherConditionTranslation : [Int: String] = [100: "晴", 101: "多云", 102: "少云", 103: "晴间多云", 104: "阴", 200: "有风", 201: "平静", 202: "微风", 203: "和风", 204: "清风", 205: "强风/劲风", 206: "疾风", 207: "大风", 208: "烈风", 209: "风暴", 210: "狂爆风", 211: "飓风", 212: "龙卷风", 213: "热带风暴", 300: "阵雨", 301: "强阵雨", 302: "雷阵雨", 303: "强雷阵雨", 304: "雷阵雨伴有冰雹", 305: "小雨", 306: "中雨", 307: "大雨", 308: "极端降雨", 309: "毛毛雨/细雨", 310: "暴雨", 311: "大暴雨", 312: "特大暴雨", 313: "冻雨", 400: "小雪", 401: "中雪", 402: "大雪", 403: "暴雪", 404: "雨夹雪", 405: "雨雪天气", 406: "阵雨夹雪", 407: "阵雪", 500: "薄雾", 501: "雾", 502: "霾", 503: "扬沙", 504: "浮尘", 507: "沙尘暴", 508: "强沙尘暴", 900: "热", 901: "冷", 999: "未知"]
    
    struct CurrentWeather {
        var fellTemperature : Int // 体感温度
        var temperature : Int // 温度
        var wetDegree : Int  // 相对湿度
        var visibility : Int // 能见度
        var condition : WeatherCondition // 天气状况
    }
    
    var currentWeatherData : CurrentWeather? = nil
    
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
    
    private func getCurrentWeatherData() {
        WeatherData.request(ApiEndpoint.currentWeather(locationInfo.locationId), successCallback: {(responseData) -> Void in
            //debugPrint(responseData!)
            if let result = responseData?["HeWeather5"] {
                let currentData = result[0]["now"]
                debugPrint(currentData)
                let weatherConditionVal = currentData["cond"]["code"].intValue
                self.currentWeatherData = CurrentWeather(fellTemperature: currentData["fl"].intValue, temperature: currentData["tmp"].intValue, wetDegree: currentData["hum"].intValue, visibility: currentData["vis"].intValue, condition: WeatherCondition(rawValue: weatherConditionVal)!)
                debugPrint(self.currentWeatherData!)
            } else {
                debugPrint("NO JSON CONTENT!")
            }
        }, failCallback: {(errorType, errorBody, error) -> Void in
            switch errorType {
            default:
                debugPrint(errorBody ?? "NO ERROR CONTENT!")
            }
        })
    }
    
    func loadData(province provName: String, city cityName: String, success successCallback: (() -> Void)?) {
        findCity(province: provName, city: cityName)
        let _ : Timer! = Timer.scheduledTimer(withTimeInterval: 1, repeats: true, block: { (t) -> Void in
            if self.currentWeatherData != nil {
                successCallback?()
                t.invalidate()
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
    
    private func findCity(province provName: String, city cityName: String) {
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
