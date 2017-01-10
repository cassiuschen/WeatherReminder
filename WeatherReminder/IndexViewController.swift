//
//  ViewController.swift
//  WeatherReminder
//
//  Created by Cassius Chen on 2017/1/5.
//  Copyright © 2017年 Cassius Chen. All rights reserved.
//

import UIKit
import CoreLocation

class IndexViewController: UIViewController, AMapLocationManagerDelegate {
    let lcManager = AMapLocationManager()
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
        lcManager.desiredAccuracy = kCLLocationAccuracyKilometer // 设置定位精确度为一公里左右的精度，以加快定位速度
        lcManager.locationTimeout = 4
        lcManager.reGeocodeTimeout = 4
        lcManager.distanceFilter = 10000.0
        //lcManager.requestAlwaysAuthorization() // 申请定位权限
        //lcManager.startUpdatingLocation()
        getLocation()
    }
    /* Using Core Location
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
    }*/
    
    func amapLocationManager(_ manager: AMapLocationManager!, didUpdate location: CLLocation!, reGeocode: AMapLocationReGeocode!) {
        locationLabel.text = "\(reGeocode) - \(location.coordinate.latitude), \(location.coordinate.longitude)"
    }
    
    func getLocation() {
        lcManager.requestLocation(withReGeocode: true, completionBlock: {(location : CLLocation?, reGeocode : AMapLocationReGeocode?, error : Error?) in
            if((error) != nil) {
                print(error!)
                return
            } else {
                if((reGeocode) != nil) {
                    self.locationLabel.text = "\(reGeocode!.poiName!)"
                    print(reGeocode!)
                    print(" ----------------- 获得定位： \(location?.coordinate.latitude), \(location?.coordinate.longitude)，\(reGeocode!.formattedAddress!)")
                }
            }
        })
    }
    
    
    
    
    // UI 相关
    func makeRoundedCorror() {
        let cornerRadius : CGFloat = 15.0
        let roundedLayer = self.view.layer
        roundedLayer.masksToBounds = true
        roundedLayer.cornerRadius = cornerRadius
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }

}

