//
//  Actron6.swift
//  HomeMonitor
//
//  Created by Darren Oster on 11/8/16.
//  Copyright © 2016 Criterion Software Services. All rights reserved.
//

import Foundation
import Gloss

public struct Actron6: Decodable {
    
    public let isOn: Bool?
    public let mode: Int?
    public let fanSpeed: Int?
    public let setPoint: Float?
    public let roomTemp: Float?
    public let isInEspMode: Bool?
    public let fanIsCont: Int?
    public let compressorActivity: Int?
    public let errorCode: String?
    
    public init?(json: JSON) {
        isOn = "isOn" <~~ json
        mode = "mode" <~~ json
        fanSpeed = "fanSpeed" <~~ json
        setPoint = "setPoint" <~~ json
        roomTemp = "roomTemp_oC" <~~ json
        isInEspMode = "isInESP_Mode" <~~ json
        fanIsCont = "fanIsCont" <~~ json
        compressorActivity = "compressorActivity" <~~ json
        errorCode = "errorCode" <~~ json
    }
    
}
