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
    static let KEY_ROUTE = "KEY_ROUTE"
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
    
    
    static func removeBussStop(stop:BussStop) {
        let list = getBussStop()
        saveBussStops(list: list.filter({ $0.id != stop.id }))
    }
    
    static func removeRoute(route:RouteInfo) {
        let list = getRoutes()
        saveRoutes(list: list.filter({ $0.description != route.description }))
    }
    
    static  func saveRoutes(list:Array<RouteInfo>) {
        userDefault.set(Parser.routeToString(list: list), forKey: KEY_ROUTE)
    }
    
    static func addRoute(route:RouteInfo) {
        var list = getRoutes()
        list.append(route)
        saveRoutes(list: list)
    }
    
    static func getRoutes()->Array<RouteInfo>{
        let string = userDefault.value(forKey: KEY_ROUTE) as? String
        return Parser.parseStringToRoutes(text: string)
    }
    
    
    
    
}
