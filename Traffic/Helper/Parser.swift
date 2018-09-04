//
//  Parser.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-08-27.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation
import SWXMLHash
class Parser {
    
    static var formatter:DateFormatter{
        get{
            let x=DateFormatter()
            x.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
            return x
        }
    }
    
    
    static var timeFormatter :DateFormatter{
        get{
            let x=DateFormatter()
            x.dateFormat = "HH:mm"
            return x
        }
    }
    
    
    static func getBussStops(data:Data) -> Array<BussStop> {
        return SWXMLHash.parse(data)["soap:Envelope"]["soap:Body"]["GetStartEndPointResponse"]["GetStartEndPointResult"]["StartPoints"]["Point"].all.map{ point in BussStop(i: point.getText(id: "Id"),n: point.getText(id: "Name")) }
        
    }
    
    static func getBussStopsForPoint(data:Data) -> Array<BussStop> {
        return SWXMLHash.parse(data)["soap:Envelope"]["soap:Body"]["GetNearestStopAreaResponse"]["GetNearestStopAreaResult"]["NearestStopAreas"]["NearestStopArea"].all.map{ point in BussStop(i: point.getText(id: "Id"),n: point.getText(id: "Name")) }
        
    }
    
    static func getBussStopInfo(data:Data,stopName:String? ) -> Array<BussTimeInfo> {
        
        return SWXMLHash.parse(data)["soap:Envelope"]["soap:Body"]["GetDepartureArrivalResponse"]["GetDepartureArrivalResult"]["Lines"]["Line"].all.map{ data in
            let name = data.getText(id: "Name") + " " + data.getText(id: "Towards")
            let dateString = data.getText(id: "JourneyDateTime")
            var arrivalTime=formatter.date(from: dateString )
            var addedMinute = 0.0
            let isRealTime = data["RealTime"].children.count > 0
            if data["RealTime"].children.count > 0 {
                //print(data["RealTime"]["RealTimeInfo"]["DepTimeDeviation"].element?.text)
                addedMinute =  60 * Double(data["RealTime"]["RealTimeInfo"]["DepTimeDeviation"].element?.text ?? "0")!
            }
            arrivalTime?.addTimeInterval(addedMinute)
            return BussTimeInfo(n: name,t: arrivalTime!,s:stopName, r:isRealTime)
            
        }
        
    }
    
    static func parseStringToBusStops(text:String?)->Array<BussStop>{
        if text == nil || text!.isEmpty {
            return []
        }
        let xml=SWXMLHash.parse(text!)["List"]["Stop"]
        return xml.all.map { point in BussStop(i: point.getText(id: "Id"),n: point.getText(id: "Name")) }
    }
    
    static func bussStopToString(bussStops:Array<BussStop>) -> String {
        return "<List>" + bussStops.map { "<Stop><Id>\($0.id)</Id><Name>\($0.name!)</Name></Stop>"}.joined(separator: "") + "</List>"
    }
    
    
}

extension XMLIndexer{
    func getText(id:String)->String {
        return self[id].element!.text
    }
}

