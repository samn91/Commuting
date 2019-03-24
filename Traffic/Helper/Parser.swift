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
    
    static let prefix = ["Malmö","Lund"]
    
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
    
    
    static func getBussStopInfoForRoute(data:Data) -> Array<BussTimeInfo> {
        return SWXMLHash.parse(data)["soap:Envelope"]["soap:Body"]["GetJourneyResponse"]["GetJourneyResult"]["Journeys"]["Journey"].all
            .filter({ $0["RouteLinks"]["RouteLink"].all.count == 1 })
            .map{journy in
                let dateString = journy.getText(id: "DepDateTime")
                let route = journy["RouteLinks"]["RouteLink"]
                let line=route["Line"]
                let name = line.getText(id: "Name") + " " + line.getText(id: "Towards")
                var arrivalTime = Parser.formatter.date(from: dateString )
                var addedMinute = 0.0
                let isRealTime = route["RealTime"].children.count > 0
                if isRealTime {
                    addedMinute =  60 * Double(route["RealTime"]["RealTimeInfo"]["DepTimeDeviation"].element?.text ?? "0")!
                }
                arrivalTime?.addTimeInterval(addedMinute)
                return BussTimeInfo(n: name,t: arrivalTime!,s:nil, r:isRealTime)
        }
    }
    
    
    static func getBussStopInfo(data:Data,stopName:String? ) -> Array<BussTimeInfo> {
        
        return SWXMLHash.parse(data)["soap:Envelope"]["soap:Body"]["GetDepartureArrivalResponse"]["GetDepartureArrivalResult"]["Lines"]["Line"].all.map{ data in
            let dateString = data.getText(id: "JourneyDateTime")
            let name = data.getText(id: "Name") + " " + data.getText(id: "Towards")
            var arrivalTime = Parser.formatter.date(from: dateString )
            var addedMinute = 0.0
            let isRealTime = data["RealTime"].children.count > 0
            if data["RealTime"].children.count > 0 {
                addedMinute =  60 * Double(data["RealTime"]["RealTimeInfo"]["DepTimeDeviation"].element?.text ?? "0")!
            }
            arrivalTime?.addTimeInterval(addedMinute)
            return BussTimeInfo(n: name,t: arrivalTime!,s:stopName, r:isRealTime)
        }
        
    }
    
    static func lineFromXmlToBussTimeInfo(data:XMLIndexer,arrival dateString:String, stopName :String?)-> BussTimeInfo  {
        let name = data.getText(id: "Name") + " " + data.getText(id: "Towards")
        var arrivalTime = Parser.formatter.date(from: dateString )
        var addedMinute = 0.0
        let isRealTime = data["RealTime"].children.count > 0
        if data["RealTime"].children.count > 0 {
            addedMinute =  60 * Double(data["RealTime"]["RealTimeInfo"]["DepTimeDeviation"].element?.text ?? "0")!
        }
        arrivalTime?.addTimeInterval(addedMinute)
        return BussTimeInfo(n: name,t: arrivalTime!,s:stopName, r:isRealTime)
        
    }
    
    static func parseStringToBusStops(text:String?)->Array<BussStop>{
        if text == nil || text!.isEmpty {
            return []
        }
        let xml=SWXMLHash.parse(text!)["List"]["Stop"]
        return xml.all.map { point in BussStop.fromXml(point) }
    }
    
    static func bussStopToString(bussStops:Array<BussStop>) -> String {
        return "<List>" + bussStops.map { $0.toXmlString() }.joined(separator: "") + "</List>"
    }
    
    static func routeToString(list:Array<RouteInfo>) -> String {
        return "<List>" + list.map { "<Route><From>\($0.from.toXmlString())</From><To>\($0.to.toXmlString())</To></Route>"}.joined(separator: "") + "</List>"
    }
    
    
    static func parseStringToRoutes(text:String?)->Array<RouteInfo>{
        if text == nil || text!.isEmpty {
            return []
        }
        let xml=SWXMLHash.parse(text!)["List"]["Route"]
        return xml.all.map { point in RouteInfo(from: BussStop.fromXml(point["From"]["Stop"]), to: BussStop.fromXml(point["To"]["Stop"])) }
    }
    
    
    static func removeKnownPrifix(stops: Array<BussStop>) -> Array<BussStop> {
        return stops.map {
            Parser.removeKnownPrifix(forStop: $0)
        }
    }
    
    static func removeKnownPrifix(forStop stop : BussStop) -> BussStop {
        if var name = stop.name {
            for px in Parser.prefix {
                if name.starts(with: px) {
                    if name.count > px.count+3 {
                        name =  name.components(separatedBy: " ").dropFirst(1).joined()
                    }
                    return BussStop(i: stop.id, n: name)
                }
            }
        }
        return stop
    }
    
}

extension XMLIndexer{
    func getText(id:String)->String {
        return self[id].element!.text
    }
}

