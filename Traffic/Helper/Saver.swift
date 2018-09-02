//
//  Saver.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-09-01.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation
class Saver {
    
    static let KEY_STOPS = "KEY_STOPS"
    static let userDefault : UserDefaults = UserDefaults.standard
    
    static  func saveBussStops(list:Array<BussStop>) {
        userDefault.set(Parser.bussStopToString(bussStops: list), forKey: KEY_STOPS)
    }
    
    static func addBussStop(stop:BussStop) {
        var list = getBussStop()
        list.append(stop)
        saveBussStops(list: list)
    }
    
    
    static func getBussStop()->Array<BussStop>{
        //userDefault.removeObject(forKey: KEY_STOPS)
        let string = userDefault.value(forKey: KEY_STOPS) as? String
        return Parser.parseStringToBusStops(text: string)
    }
    
}
