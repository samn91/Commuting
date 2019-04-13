//
//  Downloader.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-08-27.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation
class Downloader {
    
    static func downloadBussInfo(stop:BussStop,executeAfter:@escaping (_ list:Array<BussTimeInfo>) -> Void) {
        let url=URL(string: "http://www.labs.skanetrafiken.se/v2.2/stationresults.asp?selPointFrKey=" + stop.id)!
        download(url) { (data) in
            let parser = Parser.getBussStopInfo(data: data,stopName: stop.name)
            //    .sorted(by: { $0.time.compare($1.time) == .orderedAscending })
            print(parser)
            DispatchQueue.main.async{
                executeAfter(parser)
            }
            
        }
        
    }
    
    static func downloadBussStop(_ place:String,executeAfter:@escaping (_ list:Array<BussStop>) -> Void) {
        let urlString  = "http://www.labs.skanetrafiken.se/v2.2/querystation.asp?inpPointfr=\(place)".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url=URL(string: urlString)!
        download(url) { (data) in
            let parser = Parser.getBussStops(data: data)
            print(parser)
            DispatchQueue.main.async {
                executeAfter(parser)
            }
        }
    }
    
    static func downloadBussStopForPoint(_ lat:String,_ lon:String,executeAfter:@escaping (_ list:Array<BussStop>) -> Void) {
        let url=URL(string: "http://www.labs.skanetrafiken.se/v2.2/neareststation.asp?x=\(lat)&y=\(lon)&Radius=300")!
        download(url) { data in
            let parser = Parser.getBussStopsForPoint(data: data)
            print(parser)
            DispatchQueue.main.async {
                executeAfter(parser)
            }
        }
    }
    
    static func downloadRoute(_ route:RouteInfo , executeAfter : @escaping (_ list:Array<BussTimeInfo>) -> Void){
        
        let urlString  = "http://www.labs.skanetrafiken.se/v2.2/resultspage.asp?cmdaction=next&selPointFr=\(route.from)|\(route.from.id)|0&selPointTo=\(route.to)|\(route.to.id)|0".addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!
        let url=URL(string: urlString)!
        download(url) { (data) in
            let parser = Parser.getBussStopInfoForRoute(data: data, stopName: route.from.name)
            print(parser)
            DispatchQueue.main.async {
                executeAfter(parser)
            }
        }
        
        
    }
    
    static  func download(_ url:URL, executeAfter:@escaping (_ data:Data) -> Void) {
        let task = URLSession.shared.dataTask(with: url) { data, response, error in
            guard let data = data, error == nil else {
                print(error ?? "Unknown error")
                return
            }
            executeAfter(data)
        }
        task.resume()
    }
    
    
    
    
}
