//
//  ViewController.swift
//  WeatherReminder
//
//  Created by Cassius Chen on 2017/1/5.
//  Copyright © 2017年 Cassius Chen. All rights reserved.
//

import UIKit
import CoreLocation

class IndexViewController: UIViewController, CLLocationManagerDelegate {
    let lcManager : CLLocationManager = CLLocationManager()
    @IBOutlet var locationLabel: UILabel!
    @IBOutlet var datetimeLabel: UILabel!
    override func viewDidLoad() {
        super.viewDidLoad()
        makeRoundedCorror() // 定义圆角
        locationServerInit() // 初始化定位服务
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // 定位相关
    func locationServerInit() {
        lcManager.delegate = self
        lcManager.requestAlwaysAuthorization() // 申请定位权限
        lcManager.desiredAccuracy = kCLLocationAccuracyBest // 设置定位精确度为最佳精确度
        lcManager.distanceFilter = 10000.0
        
        lcManager.startUpdatingLocation()
    }
    
    func checkIfLocationServerAuthorized() {
        switch CLLocationManager.authorizationStatus() {
            case .authorizedAlways:
                return
            case .notDetermined, .authorizedWhenInUse:
                lcManager.requestAlwaysAuthorization()
            case .denied, .restricted:
                let alertController = UIAlertController(title: "定位服务被禁止", message: "很抱歉，程序在获取你的定位信息是出了一点小问题，还请你收手动在系统设置中开放本程序的定位权限。", preferredStyle: .alert)
                let canelAction = UIAlertAction(title: "我就不！", style: .cancel, handler: nil)
                let gotoSystemSettingsAction = UIAlertAction(title: "这就去！", style: .default, handler: {(action) in
                    if let url = URL(string: UIApplicationOpenSettingsURLString) {
                        UIApplication.shared.open(url, options: [:], completionHandler: nil)
                    }
                })
            
                alertController.addAction(canelAction)
                alertController.addAction(gotoSystemSettingsAction)
            
                self.present(alertController, animated: true, completion: nil)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let location: CLLocation = locations.last!
        
        if(location.horizontalAccuracy > 0) {
            locationLabel.text = "\(location.coordinate.latitude), \(location.coordinate.longitude)}"
            
            lcManager.stopUpdatingLocation()
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(error)
    }
    
    
    // UI 相关
    func makeRoundedCorror() {
        let cornerRadius : CGFloat = 15.0
        let roundedLayer = self.view.layer
        roundedLayer.masksToBounds = true
        roundedLayer.cornerRadius = cornerRadius
    }

}

