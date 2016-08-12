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
    
    let statusItem = NSStatusBar.systemStatusBar().statusItemWithLength(NSVariableStatusItemLength)
    var temperature: Float = 0.0;
    var power: String = "-- (--)";
    
    var tempTimer: NSTimer!;

    func applicationDidFinishLaunching(aNotification: NSNotification) {
        // Insert code here to initialize your application
        
        let icon = NSImage(named: "home_logo")
        icon?.template = true // best for dark mode
        statusItem.image = icon
        
        statusItem.menu = statusMenu
        
        tempTimer = NSTimer.scheduledTimerWithTimeInterval(5.0, target: self, selector: #selector(AppDelegate.downloadTemperature), userInfo: nil, repeats: true)
        
        downloadTemperature()
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
        tempTimer.invalidate()
    }
    
    func updateTemperature(value: Float) {
        self.temperature = value
        self.updateText()
    }
    
    func updatePower(value: String) {
        self.power = value
        self.updateText()
    }
    
    func updateText() {
        statusItem.title = " \(temperature.string(1))\u{00B0}C \(power)"
    }
    
    
    @IBAction func onQuit(sender: AnyObject) {
        exit(0)
    }
    
    func downloadTemperature() {
        let requestURL: NSURL = NSURL(string: "http://10.0.0.97/6.json")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                var json: [String: AnyObject]!
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String: AnyObject]
                } catch {
                    print(error)
                    return
                }
                
                guard let actron6 = Actron6(json: json!) else {
                    print("Error initializing object")
                    return
                }
                
                guard let roomTemp = actron6.roomTemp else {
                    print("Unable to get room temp")
                    return
                }
                    
                self.updateTemperature(roomTemp)
            }
        }
        
        task.resume()
    }
    
    func downloadPower() {
        let requestURL: NSURL = NSURL(string: "http://10.0.0.92/solar_api/v1/GetInverterRealtimeData.cgi?Scope=Device&DeviceId=1&DataCollection=CommonInverterData")!
        let urlRequest: NSMutableURLRequest = NSMutableURLRequest(URL: requestURL)
        let session = NSURLSession.sharedSession()
        let task = session.dataTaskWithRequest(urlRequest) {
            (data, response, error) -> Void in
            
            let httpResponse = response as! NSHTTPURLResponse
            let statusCode = httpResponse.statusCode
            
            if (statusCode == 200) {
                var json: [String: AnyObject]!
                do {
                    json = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions()) as? [String: AnyObject]
                } catch {
                    print(error)
                    return
                }
                
                guard let powerData = InverterRealTimeData(json: json!) else {
                    print("Error initializing object")
                    return
                }
                
                guard let currentPower = powerData.body?.data?.pac,
                      let dayPower = powerData.body?.data?.dayEnergy else {
                    print("Unable to get power")
                    return
                }
                
                let formattedPower = "\(currentPower.value!.string(0))\(currentPower.unit) (\(dayPower.value!.string(0))\(dayPower.unit))"
                self.updatePower(formattedPower)
            }
        }
        
        task.resume()
    }

}

extension Float {
    func string(fractionDigits:Int) -> String {
        let formatter = NSNumberFormatter()
        formatter.minimumFractionDigits = fractionDigits
        formatter.maximumFractionDigits = fractionDigits
        return formatter.stringFromNumber(self) ?? "\(self)"
    }
}
