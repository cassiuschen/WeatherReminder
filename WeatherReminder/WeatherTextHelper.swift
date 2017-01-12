//
//  WeatherTextHelper.swift
//  WeatherReminder
//
//  Created by Cassius Chen on 2017/1/12.
//  Copyright © 2017年 Cassius Chen. All rights reserved.
//

import Foundation
import UIKit

class WeatherTextHelper {
    // 入口，生成全部文字
    static func generateText(weatherData data: WeatherData.CurrentWeather) -> NSMutableAttributedString {
        return self.generateCurrentWeatherText(currentWeatherData: data)
    }
    
    // 字体样式
    private static let normalTextStyle = [NSForegroundColorAttributeName: UIColor(red: 63 / 255, green: 63 / 255, blue: 63 / 255, alpha: 1), NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightThin)]
    private static let maxTemperatureTextStyle = [NSForegroundColorAttributeName: UIColor(red: 1, green: 163 / 255, blue: 77 / 255, alpha: 1), NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightRegular)]
    private static let minTemperatureTextStyle = [NSForegroundColorAttributeName: UIColor(red: 58 / 255, green: 206 / 255, blue: 172 / 255, alpha: 1), NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightRegular)]
    private static let weatherConditionTextStyle = [NSForegroundColorAttributeName: UIColor(red: 170 / 255, green: 177 / 255, blue: 1, alpha: 1), NSFontAttributeName: UIFont.systemFont(ofSize: 28, weight: UIFontWeightRegular)]
    
    // 翻译天气状况
    private static func getWeatherConditionTraslate(_ condition: WeatherData.WeatherCondition) -> String {
        return WeatherData.WeatherConditionTranslation[condition.rawValue]!
    }
    
    // 生成当前天气状况
    private static func generateCurrentWeatherText(currentWeatherData data: WeatherData.CurrentWeather) -> NSMutableAttributedString {
        let conditionText : String = getWeatherConditionTraslate(data.condition)
        let temperatureText : [String] = [String(data.fellTemperature), String(data.wetDegree)]
        let rawText = concatCurrentWeatherInfo(weatherData: data)
        let windText : String = "\(data.wind.level)级风"
        
        let resultText = NSMutableAttributedString(string: rawText, attributes: normalTextStyle)
        resultText.addAttributes(weatherConditionTextStyle, range: (rawText as NSString).range(of: conditionText))
        resultText.addAttributes(weatherConditionTextStyle, range: (rawText as NSString).range(of: windText))
        
        for str in temperatureText {
            resultText.addAttributes(minTemperatureTextStyle, range: (rawText as NSString).range(of: str + "℃"))
        }
        
        return resultText
    }
    
    private static func concatCurrentWeatherInfo(weatherData data: WeatherData.CurrentWeather) -> String {
        let conditionText : String = weatherConditionText(weatherData: data.condition)
        
        return "现在\(conditionText)，体表温度\(data.fellTemperature)℃\(windConditionText(windCondition: data.wind))。\n\(data.comfortable)"
    }
    
    // 天气情况拼接片段
    private static func weatherConditionText(weatherData data: WeatherData.WeatherCondition) -> String {
        switch data {
        case .sunny, .calm, .hot, .cold, .unknown:
            return "天气\(getWeatherConditionTraslate(data))"
        case .windy, .moderate, .freshBreeze, .strongBreeze, .highWind, .gale, .strongGale, .storm, .violentStorm, .hurricane, .tornado, .tropicalStorm, .showerRain, .heavyShowerRain, .thundershower, .heavyThunderstorm, .hail, .lightRain, .moderateRain, .heavyRain, .extremeRain, .drizzleRain, .stormRain, .heavyStorm, .severeStorm, .freezingRain, .lightSnow, .moderateSnow, .heavySnow, .snowstorm, .sleet, .showerSnow, .snowFlurry, .mist, .foggy, .haze, .sand, .dust, .duststorm, .sandstorm:
            return "有\(getWeatherConditionTraslate(data))"
        case .rainAndSnow:
            return "\(getWeatherConditionTraslate(data))天气"
        default:
            return getWeatherConditionTraslate(data)
        }
    }
    
    private static func windConditionText(windCondition data: WeatherData.WindCondition) -> String {
        switch true {
        case (data.speed > 12):
            return "，有\(data.level)级风"
        default:
            return ""
        }
    }
}
