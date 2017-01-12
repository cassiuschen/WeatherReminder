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
        let rawText = "现在\(conditionText)，体表温度\(data.fellTemperature)℃\n请注意保暖。"
        
        let resultText = NSMutableAttributedString(string: rawText, attributes: normalTextStyle)
        resultText.addAttributes(weatherConditionTextStyle, range: (rawText as NSString).range(of: conditionText))
        
        for str in temperatureText {
            resultText.addAttributes(minTemperatureTextStyle, range: (rawText as NSString).range(of: str + "℃"))
        }
        
        return resultText
    }
    
}
