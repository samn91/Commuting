//
//  RouteInfo.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-09-08.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation
class RouteInfo : CustomStringConvertible {

    var description: String {
        return from.name! + " ➜ " +  to.name!
    }
    
    let from : BussStop
    let to : BussStop
    init(from f : BussStop,to t:BussStop) {
        from=f
        to=t
    }
    
   
}
