//
//  InverterRealTimeData.swift
//  HomeMonitor
//
//  Created by Darren Oster on 12/8/16.
//  Copyright © 2016 Criterion Software Services. All rights reserved.
//

import Foundation
import Gloss

public struct InverterRealTimeData: Decodable {
    
    public let body: InverterRealTimeDataBody?
    
    public init?(json: JSON) {
        body = "Body" <~~ json
    }
    
}

public struct InverterRealTimeDataBody : Decodable {

    public let data: InverterRealTimeDataData?
    
    public init?(json: JSON) {
        data = "Data" <~~ json
    }
}

public struct InverterRealTimeDataData : Decodable {
    
    public let pac: InverterRealTimeDataDetail?
    public let dayEnergy: InverterRealTimeDataDetail?
    public let yearEnergy: InverterRealTimeDataDetail?
    public let totalEnergy: InverterRealTimeDataDetail?
    
    public init?(json: JSON) {
        pac = "PAC" <~~ json
        dayEnergy = "DAY_ENERGY" <~~ json
        yearEnergy = "YEAR_ENERGY" <~~ json
        totalEnergy = "TOTAL_ENERGY" <~~ json
    }
}

public struct InverterRealTimeDataDetail : Decodable {
    
    public let unit: String?
    public let value: Float?
    
    public init?(json: JSON) {
        unit = "Unit" <~~ json
        value = "Values" <~~ json
    }
}

/*
http://10.0.0.92/solar_api/v1/GetInverterRealtimeData.cgi?Scope=Device&DeviceId=1&DataCollection=CommonInverterData
{
    "Head": {
        "RequestArguments": {
            "DataCollection": "CommonInverterData",
            "DeviceClass": "Inverter",
            "DeviceId": "1",
            "Scope": "Device"
        },
        "Status": {
            "Code": 0,
            "Reason": "",
            "UserMessage": ""
        },
        "Timestamp": "2016-08-12T15:21:01+09:30"
    },
    "Body": {
        "Data": {
            "DAY_ENERGY": {
                "Value": 14559,
                "Unit": "Wh"
            },
            "FAC": {
                "Value": 50.01,
                "Unit": "Hz"
            },
            "IAC": {
                "Value": 3.14,
                "Unit": "A"
            },
            "IDC": {
                "Value": 4.66,
                "Unit": "A"
            },
            "PAC": {
                "Value": 756,
                "Unit": "W"
            },
            "TOTAL_ENERGY": {
                "Value": 87983.01,
                "Unit": "Wh"
            },
            "UAC": {
                "Value": 247.5,
                "Unit": "V"
            },
            "UDC": {
                "Value": 209.5,
                "Unit": "V"
            },
            "YEAR_ENERGY": {
                "Value": 87983.7,
                "Unit": "Wh"
            },
            "DeviceStatus": {
                "StatusCode": 7,
                "MgmtTimerRemainingTime": -1,
                "ErrorCode": 0,
                "LEDColor": 2,
                "LEDState": 0,
                "StateToReset": false
            }
        }
    }
}
*/