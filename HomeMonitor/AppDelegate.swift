//
//  AppDelegate.swift
//  HomeMonitor
//
//  Created by Darren Oster on 10/8/16.
//  Copyright © 2016 Criterion Software Services. All rights reserved.
//

import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {

    @IBOutlet weak var window: NSWindow!
    
    @IBOutlet weak var statusMenu: NSMenu!
    
    let statusItem = NSStatusBar.system().statusItem(withLength: NSVariableStatusItemLength)
    var temperature: Float = 0.0
    var power: String = "-- (--)"
    
    var tempTimer: Timer!
    var powerTimer: Timer!

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        
        let icon = NSImage(named: "home_logo")
        icon?.isTemplate = true // best for dark mode
        statusItem.image = icon
        
        statusItem.menu = statusMenu
        
        tempTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(AppDelegate.downloadTemperature), userInfo: nil, repeats: true)
        powerTimer = Timer.scheduledTimer(timeInterval: 5.0, target: self, selector: #selector(AppDelegate.downloadPower), userInfo: nil, repeats: true)
        
        downloadTemperature()
        downloadPower()
    }

    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
        tempTimer.invalidate()
    }
    
    func updateTemperature(_ value: Float) {
        self.temperature = value
        self.updateText()
    }
    
    func updatePower(_ value: String) {
        self.power = value
        self.updateText()
    }
    
    func updateText() {
        statusItem.title = " \(temperature.string(1))\u{00B0}C / \(power)"
    }
    
    
    @IBAction func onQuit(_ sender: AnyObject) {
        exit(0)
    }
    
    func downloadTemperature() {
        let requestURL: URL = URL(string: "http://10.0.0.97/6.json")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            if (response == nil) {
                return
            }

            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                var json: [String: AnyObject]!
                do {
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject]
                } catch {
                    //print(error)
                    return
                }
                
                guard let actron6 = Actron6(json: json!) else {
                    //print("Error initializing object")
                    return
                }
                
                guard let roomTemp = actron6.roomTemp else {
                    //print("Unable to get room temp")
                    return
                }
                    
                self.updateTemperature(roomTemp)
            }
        }) 
        
        task.resume()
    }
    
    func downloadPower() {
        let requestURL: URL = URL(string: "http://10.0.0.92/solar_api/v1/GetInverterRealtimeData.cgi?Scope=Device&DeviceId=1&DataCollection=CommonInverterData")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(url: requestURL)
        let session = URLSession.shared
        let task = session.dataTask(with: urlRequest as URLRequest, completionHandler: {
            (data, response, error) -> Void in
            
            if (response == nil) {
                return
            }

            let httpResponse = response as! HTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                var json: [String: AnyObject]!
                do {
                    json = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions()) as? [String: AnyObject]
                } catch {
                    print(error)
                    return
                }
                
                print(json)
                
                guard let powerData = InverterRealTimeData(json: json!) else {
                    print("Error initializing object")
                    return
                }
                
                guard let currentPower = powerData.body?.data?.pac,
                      let dayPower = powerData.body?.data?.dayEnergy else {
                    print("Unable to get power")
                    return
                }
                
                let formattedPower = "\(currentPower.value!.string(0))\(currentPower.unit!) (\(dayPower.value!.string(0))\(dayPower.unit!))"
                self.updatePower(formattedPower)
            }
        }) 
        
        task.resume()
    }

}

extension Float {
    func string(_ fractionDigits:Int) -> String {
        let formatter = NumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.string(from: NSNumber(value: self)) ?? "\(self)"
    }
}
