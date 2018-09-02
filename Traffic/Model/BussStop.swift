//
//  BussStop.swift
//  Traffic
//
//  Created by Samer Naoura on 2018-08-28.
//  Copyright © 2018 Samer Naoura. All rights reserved.
//

import Foundation
struct BussStop {
    /*
     <Point>
     <Id>80120</Id>
     <Name>Malmö Södervärn</Name>
     <Type>STOP_AREA</Type>
     <X>6165692</X>
     <Y>1323579</Y>
     </Point>
     */
    var id:String
    var name:String?
    init(i:String,n:String?) {
        id=i
        name=n
    }
    
    
}
